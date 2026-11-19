---
name: my-setup-repo
description: Scaffold a repository to this codebase's standards, or bring an existing one up to them. Creates the monorepo layout, tooling config, make check, pre-commit, and CI. Invoked manually with /my-setup-repo. Never runs on its own.
disable-model-invocation: true
---

# Setup repo

Scaffolds a new repository, or fills the gaps in an existing one, so that the build loop
in AGENTS.md has something to run against.

The deliverable is a repo where `make check` works and CI runs it on every pull request.
Deployment is out of scope here and belongs to a deployment skill (`my-deploy-personal`).

## Before doing anything

Determine git repository status, existing tooling, and the deployment target. State all
back before writing a file.

<step name="git-check">
Check whether a git repository exists. Run `git rev-parse --is-inside-work-tree` or check
for `.git`.

If it is not a git repository:
Create it together with the user. Ask the user for the necessary information first before
running any git commands:
1. Remote hosting: Is there a remote repository (e.g. GitHub, GitLab, private server), or
   is this local-only for now?
2. If GitHub or hosted remote: Repository name, owner/organization, visibility (private or
   public), and whether to create and link it via `gh repo create` or add an existing
   remote URL as `origin`.
3. Git author identity: Check `git config user.name` and `git config user.email`. If
   either is missing, ask the user for their name and email.
4. Default branch: Standard is `main`.

Once answered, initialize the repo (`git init -b main`), configure user details if needed,
wire the remote if requested, and confirm the clean git state before proceeding.

If it is already a git repository:
State that the git repo exists, reporting current branch and configured remotes.
</step>

<step name="detect">
Is this a fresh repo or an existing one? Check for `pyproject.toml`, `package.json`,
`Makefile`, `.pre-commit-config.yaml`, `.github/workflows/`.

For an existing repo: report what is present and what is missing, and only create what
is missing. Never overwrite a config file that already exists. If an existing file
conflicts with the standard, say so and propose the change rather than applying it.
</step>

<step name="ask">
Is this a personal project deployed to the owner's own servers, or something else?

The answer decides whether the deployment skill (`my-deploy-personal`) runs afterwards and what the CI build
job does. If the answer is "something else", do not guess the target. Set up everything
in this file, then stop and say that deployment needs to be decided separately.
</step>

## Layout

Monorepo, one `make check` at the root covering both sides.

<example name="layout">
  backend/
    pyproject.toml
    src/&lt;package&gt;/
    tests/
  frontend/
    package.json
    src/
  Makefile
  docker-compose.yml
  docker-compose.test.yml
  .pre-commit-config.yaml
  .github/workflows/ci.yml
  AGENTS.md
  CLAUDE.md
  .gitignore
  .env.example
</example>

`AGENTS.md` at the repo root is project-specific: what this service does, its
non-obvious constraints, and anything that departs from the global conventions. It does
not restate the global file. `CLAUDE.md` contains only `@AGENTS.md`.

`.env.example` lists every variable in `Settings` with placeholder values. `.env` is
never committed.

## Templates

Copy these from `templates/` in this skill folder rather than writing them from memory:

- `Makefile`
- `pyproject.toml` ruff and mypy sections
- `.pre-commit-config.yaml`
- `.github/workflows/ci.yml`
- `.gitignore`

Generate the rest: package names, compose services, the app skeleton, `.env.example`.

If a template is missing or clearly out of date, say so rather than improvising a
replacement silently.

## make check

One command, exit non-zero on any failure, and it must cover both sides of the monorepo.

<example name="makefile-targets">
  check: lint typecheck test
  lint:       ruff check backend && npm --prefix frontend run lint
  typecheck:  mypy backend && npm --prefix frontend run typecheck
  test:       pytest backend && npm --prefix frontend run test
  fmt:        ruff format backend && npm --prefix frontend run format
</example>

Real tabs, not spaces.

Target runtime under 30 seconds for a small repo. If it creeps past that, split a slower
`check-full` for CI and keep `check` fast enough for the build loop to run every pass.

## Tooling

**Backend.** `uv` for packaging. `ruff` for lint and format, line length 100. `mypy` with
`check_untyped_defs`, `disallow_incomplete_defs`, `no_implicit_optional` and
`warn_unused_ignores` enabled. `pytest` with `pytest-asyncio` and `time-machine`.

**Frontend.** ESLint and Prettier, `tsc --noEmit` as the typecheck target, Vitest with
React Testing Library. `openapi-typescript` wired as a script that regenerates API types
from the backend's `/openapi.json`.

**Pre-commit.** `ruff`, `ruff-format`, and a secret scanner. Keep hooks fast; pre-commit
is not where the test suite runs. Install with `pre-commit install` and confirm it took.

## Test services

`docker-compose.test.yml` brings up the services the `my-testing` skill expects: Postgres, and
Qdrant with in-memory storage when the project uses it. PocketBase runs from a temp
directory and needs no compose service.

Make these reachable through a `make test-up` and `make test-down` pair, and have the
test target depend on them where that is practical.

## CI

GitHub Actions, on pull requests to `main` and on pushes to `main`.

<step name="test-job">
Always. Checks out, installs, brings up test services, runs `make check`. This is the
gate: a red check means the PR does not merge.
</step>

<step name="build-job">
Only on push to `main`, and only once a deployment target is known. Builds the images
and pushes them to the registry.

For a personal project this is the repo's own container registry and the `my-deploy-personal`
skill wires the rest. For anything else, leave the job out entirely rather than writing
a build that pushes nowhere.
</step>

There is no branch protection on these repos, so CI is advisory by mechanism and binding
by convention. Say this explicitly in the repo's `AGENTS.md`: work happens on a branch,
merges to `main` go through a PR, and a red check is not merged. Never commit directly to
`main`.

## Finishing

Run `make check` yourself before reporting done. A scaffold that does not pass its own
check is not finished.

Report: what was created, what was already present and left alone, anything that
conflicted with the standard, and whether the `my-deploy-personal` skill still needs to run.

## Never

- Never initialize a git repository or configure remotes without asking the user for details first.
- Never overwrite an existing config file without saying so first.
- Never commit `.env` or any real secret.
- Never write a CI job that builds and pushes to an undecided target.
- Never claim setup is complete without running `make check` and showing its output.