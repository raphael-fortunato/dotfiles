---
name: my-deploy-personal
description: Deploy a project to the owner's own servers. Covers GHCR image builds, health-gated deploys over Tailscale, the shared proxy-network compose contract, nginx vhost creation, SAN certificate extension, secrets on the box, and backups. Invoked manually with /my-deploy-personal, or by /my-setup-repo when the project is personal. Not for third-party or client deployments.
disable-model-invocation: true
---

# Deploy to personal servers

Applies only to projects deployed to the owner's own VPS or home servers. Anything else stops
and gets decided separately.

Assumes `my-setup-repo` has already run: the repo has a working `make check`, CI, and a
monorepo layout.

## The contract

Every deployed app follows the same shape. Nothing here is negotiable per project.

- Images are built in CI, pushed to GHCR, tagged with the git SHA. Never `latest`, never
  built on the server.
- Apps publish no host ports. They join the external `proxy-network` and nginx reaches
  them by container name on their internal port.
- nginx runs in Docker. Its config lives in `conf.d/`, one file per app.
- TLS is a single multi-domain SAN certificate per domain, issued by certbot in Docker
  over HTTP-01 webroot.
- Secrets live in a root-owned `.env` on the server, placed by hand. CI never sees them.

## Before anything

<step name="confirm">
Establish and state back: which server, which domain and subdomain, the container name,
and the internal port the app listens on.

Then check that server's existing `conf.d/` for whether local SSL vhosts listen on
`443 ssl` or `8443 ssl`. Servers fronted by a `stream {}` SNI router use 8443. Read an
existing config rather than assuming; getting this wrong produces a site that silently
does not resolve.
</step>

<step name="preflight">
Confirm the DNS A record for the subdomain points at the server before touching certbot.
An HTTP-01 challenge against a domain that does not resolve will fail and can burn a Let's
Encrypt rate limit.
</step>

## Compose

<example name="compose">
services:
  &lt;app&gt;:
    image: ghcr.io/&lt;owner&gt;/&lt;app&gt;:${TAG}
    container_name: &lt;app&gt;
    restart: unless-stopped
    env_file: .env
    environment:
      - TZ=Europe/Amsterdam
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://localhost:&lt;port&gt;/health"]
      interval: 10s
      timeout: 3s
      retries: 5
      start_period: 20s
    networks:
      - proxy-network

networks:
  proxy-network:
    external: true
</example>

No `ports:` mapping. The only exception is an internal-only admin tool with no domain,
which binds to `127.0.0.1:<port>` explicitly.

`${TAG}` comes from the environment at deploy time, which is what makes rollback possible.

Every app exposes a `/health` endpoint that checks its own dependencies and returns
non-200 when they are unreachable. Without it the health gate below is decorative.

Postgres and Qdrant, where the project uses them, are compose services on the same stack
with named volumes. They join `proxy-network` only if something outside the stack needs
them; otherwise keep them on the default network.

## CI build job

On push to `main`: build, tag with the git SHA, push to GHCR, then SSH to the server over
Tailscale and run the deploy script with that SHA.

The runner needs a Tailscale auth key and an SSH key, both as repository secrets. It never
receives application secrets.

<example name="deploy-step">
- run: |
    ssh deploy@&lt;tailscale-host&gt; "/srv/&lt;app&gt;/deploy.sh ${{ github.sha }}"
</example>

## Deploy script

Lives on the server at `/srv/<app>/deploy.sh`, not in CI. CI passes a SHA and nothing else.

<example name="deploy-sh">
#!/usr/bin/env bash
set -euo pipefail

cd /srv/&lt;app&gt;
NEW_TAG="$1"
PREV_TAG="$(cat .current_tag 2&gt;/dev/null || echo '')"

export TAG="$NEW_TAG"
docker compose pull
docker compose up -d

for i in $(seq 1 30); do
  if [ "$(docker inspect -f '{{.State.Health.Status}}' &lt;app&gt;)" = "healthy" ]; then
    echo "$NEW_TAG" &gt; .current_tag
    echo "deployed $NEW_TAG"
    exit 0
  fi
  sleep 2
done

echo "unhealthy after 60s, rolling back to ${PREV_TAG:-none}" &gt;&2
if [ -n "$PREV_TAG" ]; then
  export TAG="$PREV_TAG"
  docker compose up -d
fi
exit 1
</example>

A failed deploy must exit non-zero so the CI run goes red. A rollback that reports success
is worse than no rollback.

## nginx vhost

Create `<app>.conf` directly in the server's `conf.d/`. No symlinks, no `sites-available`.

<example name="vhost">
server {
    listen 443 ssl;
    server_name &lt;app&gt;.&lt;domain&gt;;

    ssl_certificate     /etc/letsencrypt/live/&lt;domain&gt;/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/&lt;domain&gt;/privkey.pem;

    resolver 127.0.0.11 valid=30s;

    client_max_body_size 100M;

    location / {
        set $upstream &lt;app-container-name&gt;;
        proxy_pass http://$upstream:&lt;internal-port&gt;;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
</example>

Use `8443 ssl` instead of `443 ssl` on servers behind the SNI stream router.

The `set $upstream` plus `resolver 127.0.0.11` pattern is required, not stylistic. A direct
`proxy_pass http://container:port` makes nginx fail to start or reload whenever that
container is down.

For admin tools, uncomment basic auth:

<example name="basic-auth">
auth_basic "Restricted";
auth_basic_user_file /etc/nginx/.htpasswd;
</example>

Validate and reload, never restart:

<example name="reload">
docker exec nginx nginx -t
docker exec nginx nginx -s reload
</example>

If `nginx -t` fails, fix the config. Never reload past a failed test.

## Certificates

New subdomains extend the existing SAN cert. Do not issue a separate certificate.

<step name="cert">
1. Add `-d <app>.<domain>` to the certbot `command:` list in the management stack's
   `docker-compose.yml`.
2. Confirm the DNS A record resolves to this server.
3. Re-issue: `docker compose run --rm certbot`.
4. Reload nginx.
</step>

Auto-renew runs from cron and needs no action, but it renews the SAN list as it stands in
the compose file. A subdomain that was never added there will silently never be covered.

## Secrets

A `.env` file next to the compose file, root-owned, `chmod 600`, placed by hand once.

`.env.example` in the repo lists every variable with placeholder values, and stays in sync
with `Settings`. When a deploy adds a required variable, say so explicitly in the report,
because the deploy will fail on startup until it is present on the box.

Never print a secret's value, never commit one, never pass one through CI.

## Backups

Wire these up as part of the first deploy, not later.

Nightly `pg_dump` pushed offsite with restic. Weekly Qdrant snapshot at most, since vectors
can be rebuilt from source data. Named volumes for anything else with state.

Document the restore command in the repo's `AGENTS.md`, and run it once against a scratch
database to prove it works. An untested backup is not a backup.

## Public versus internal

Public-facing apps go on the VPS. The home server hosts only what stays internal over
Tailscale. Never expose a home-server service to the public internet.

## Report

State: the SHA deployed, the health check result, the vhost file created, whether the cert
was re-issued, any new environment variable the box needs, and the rollback command.

## Never

- Never build an image on the server.
- Never tag or deploy `latest`.
- Never publish a host port for an app that sits behind nginx.
- Never reload nginx after a failed `nginx -t`.
- Never issue a standalone certificate when a SAN cert for that domain exists.
- Never write, echo, or commit a production secret.
- Never report a deploy as successful without the health check passing.
- Never expose a home-server service publicly.