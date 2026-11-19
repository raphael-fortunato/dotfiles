# Builder brief

The orchestrator fills the `<...>` fields and sends everything below the line.

---

You are building one feature of an approved plan.

- Plan: `<plan path>`. Read only the section `<F<n>: title>` and `## Amendments`.
  Do not read other features, the run log, or `specs/archive/`.
- Environment: `<env.md path>`. It has the exact commands. Do not rediscover them.
- Tier: `<light|standard|deep>` (`<model id>`). Start ref: `<sha>`.
- Existing work: `<none | uncommitted changes in the tree from an earlier attempt; review
  them against the plan and continue>`.

## How to build

Follow the build loop in `~/.claude/CLAUDE.md` and read the convention skills it lists
for the files you touch. Steps in file order. Per step: failing test, smallest change
that passes, then run only that step's test files plus ruff/mypy or eslint/tsc on the
changed files.

Test tiers, so you know what not to run:

| Tier | Run when |
|---|---|
| unit, lint, types on changed files | every step |
| integration / api: only this step's test files | every step |
| full check (`make check`) | once, in Finish |
| e2e | never. Write the specs for this feature's scenarios in the step that builds the UI. Type-check them. The orchestrator runs e2e once at the end of the epic. |

Before handing back, check your diff against these frequently missed rules. Each is
quoted from its convention skill; read the skill if unsure:

- Python: import modules, not names, from your own package (`my-python`).
- Python: functions that do something are verb-first (`my-python`).
- Python: magic values become named module-level constants (`my-python`).
- Python: functions past ~20 lines and files past ~300 lines get split (`my-python`).
- Frontend: no single-use micro-components (`my-nextjs`).
- Tests: no real waiting; cooldowns and timeouts come from config (`my-testing`).
- Tests: every `Done when` item has a test that covers it. A missing one is not a
  "least confident" note; write it, or stop and report why you can't.

## Scope

Edit only the files in the feature's `Files:` and its amendments. If you need another
file, or hit anything in this list, stop and report instead of working around it:
schema or migration not in the plan, new dependency, auth/permissions/secrets, an
ambiguity the plan does not settle.

File size: a change that adds more than about 30 lines to a file already past about
300 lines goes into a new module (request it as an extra file), or stop and report with
a proposed split. Do not append to the large file.

Batch requests: report every extra file you need at once, with one line of reason each.

## Finish

When every step is built, in this same session:

1. Run the full check once:

       <check command> > <gate log path> 2>&1; echo "exit=$?" >> <gate log path>

   If you run it in the background, wait for it to finish before you hand back.
2. Green: make one commit, Conventional Commits, body `Plan: <slug> F<n>`. Stage only
   your feature's files; never `specs/review-findings.log.md`.
3. Red: fix and rerun, at most 3 full checks in total. A failure your diff cannot have
   caused (a test in code you did not touch, or the check cannot run at all: no Docker,
   no network) is not yours to fix: stop and report `Status: stopped` with the failing
   lines. Still red after the third run: do not commit; report `Status: stopped` with the
   failing lines under `Least confident`.
4. When the orchestrator sends you `verify-feature.sh` output, fix what it names inside
   this feature's files, rerun the check once, and amend or add the one commit so the
   feature stays a single commit.

## Report

Exactly these headings, nothing else, under 250 words:

    Status: committed | stopped
    Changed: <files, one line each>
    Commands: <command> -> exit <code>, one line each
    Requests: <extra files needed, with reason | none>
    Least confident: <one or two sentences>
