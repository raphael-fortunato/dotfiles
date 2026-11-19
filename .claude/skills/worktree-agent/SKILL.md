---
name: worktree-agent
description: Create a git worktree in the parent directory for a new branch, set up its environment using the project's own tooling, then spawn a sub-agent to implement a given GitHub issue or feature description inside that worktree. Use when user wants to work on a feature or issue in an isolated worktree, mentions "worktree", "isolated branch", or asks to "implement issue #N in a worktree".
---

# Worktree Agent

Spin up an isolated worktree, set up its environment, and delegate implementation to a sub-agent.

## Quick Start

```
Implement issue #42 in a new worktree
```

The skill will:
1. Determine branch name from the issue/feature
2. Create `git worktree add ../$(repo)-$(branch) -b $(branch)`
3. Detect and run the project's setup command inside the worktree
4. Spawn a `general-purpose` sub-agent scoped to that directory

---

## Workflow

### Step 1 — Resolve the issue/feature

- If the user gave a GitHub issue number, fetch it with `github-mcp-server-issue_read` (method: `get`) to get the full title, body, and labels.
- If the user gave a free-text description, use it directly as the feature spec.
- Confirm the branch name with the user if ambiguous (format: `feat/short-slug` or `fix/short-slug`).

### Step 2 — Create the worktree

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
WORKTREE_DIR="$(dirname $REPO_ROOT)/$(basename $REPO_ROOT)-${BRANCH//\//-}"
git worktree add "$WORKTREE_DIR" -b "$BRANCH"   # omit -b if branch exists
```

Base branch defaults to current branch / `main` / `master`.

### Step 3 — Set up the environment

Detect the project's own tooling from files present at the worktree root, then run the first match:

| Marker file | Setup command |
|---|---|
| `uv.lock` / `pyproject.toml` (uv) | `uv sync` |
| `poetry.lock` | `poetry install` |
| `requirements.txt` | `python -m venv env && env/bin/pip install -r requirements.txt` |
| `pnpm-lock.yaml` | `pnpm install` |
| `yarn.lock` | `yarn install` |
| `package-lock.json` / `package.json` | `npm install` |
| `go.mod` | `go mod download` |
| `Cargo.toml` | `cargo fetch` |
| `Makefile` with `install`/`setup` target | `make install` or `make setup` |

```bash
cd "$WORKTREE_DIR"
<detected setup command>
```

- If several markers match, prefer the lockfile-backed one.
- If nothing matches, skip setup and tell the user the worktree is unconfigured.
- Show the last 20 lines of setup output so the user can confirm it succeeded.

### Step 4 — Spawn the sub-agent

Launch a `general-purpose` sub-agent with **sync** mode (default) unless the implementation is expected to be long, in which case use **background** mode and tell the user.

Provide the sub-agent with this context block:

```
You are implementing the following issue/feature inside the git worktree at: <WORKTREE_DIR>

## Issue / Feature
<Full issue title + body, or free-text spec>

## Repo context
- Branch: <BRANCH>
- Worktree: <WORKTREE_DIR>
- Environment: set up with <SETUP_COMMAND> — use the same tooling (e.g. `uv run`, activate the venv) for all commands
- Project structure: read CONTEXT.md and STRUCTURE.md at the repo root for domain language and architecture

## Instructions
1. Read CONTEXT.md (and docs/adr/ if present) to understand domain conventions.
2. Plan the implementation, then execute it with TDD where possible.
3. Run the existing test suite to verify nothing is broken.
4. Commit all changes on branch <BRANCH> with a clear commit message.
5. Do NOT push or open a PR — leave that to the user.
```

### Step 5 — Report back

After the sub-agent completes, summarise:
- Worktree path
- Branch name
- What was implemented (files changed, tests added)
- Any manual steps remaining (e.g., open PR, review migrations)

---

## Edge Cases

| Situation | Handling |
|---|---|
| Branch already exists | Use existing branch, skip `-b` |
| No recognised setup marker | Skip setup; warn the user the worktree is unconfigured |
| Setup command fails | Report the error and ask before spawning the sub-agent |
| Issue not found on GitHub | Ask user for description directly |
| Worktree dir already exists | Abort and ask user to clean up or choose a different name |

---

## Example Invocations

```
Implement issue #17 in a new worktree
Implement the GPS spoofing detection feature in an isolated worktree
Fix bug described in issue #88 using a worktree
```
