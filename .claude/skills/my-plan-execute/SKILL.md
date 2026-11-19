---
name: my-plan-execute
description: Execute a plan file end to end, one feature at a time, each in a fresh subagent, halting only on decisions a human must make. Invoked manually with /my-plan-execute <plan-file>. Requires a plan produced by /my-plan.
disable-model-invocation: true
---

# Plan execute

Runs a plan to completion, or until it hits something only a human can decide.

This skill orchestrates. It never implements. Builders, reviewers and fixers are
subagents. The feature is the unit of everything: one builder, one gate, one
commit, one tick. Reviews run once, at the end of the plan.

Usage: `/my-plan-execute specs/<slug>.md`

## Files the run owns

- `specs/<slug>.md`: the plan. During a run it changes only by feature ticks, `Status:`,
  and amendments (below).
- `specs/<slug>.log.md`: the run log. Created at preflight. One line per event: feature
  start ref, commit hash, amendment, review outcome, halt, ruling. No narrative. Builders
  never read it.
- `/tmp/plan-run/<slug>/env.md`: environment notes written by preflight.
- `/tmp/plan-run/<slug>/F<n>-gate.log`: the builder's gate output.

## Start of run

<step name="load">
Read the plan header and the feature list (headings, checkboxes, `Depends on:`, `Gate:`).
Do not read feature bodies; builders read their own.

Refuse to start when:
- An unchecked `Open questions` box blocks a feature in scope.

If `Status:` is `running` or `blocked`, run `reconcile` first.
</step>

<step name="reconcile">
A previous run stopped. Bring the plan in line with git before doing anything else:

1. `git log --grep "Plan: <slug> F"` lists features already committed. If any is
   unticked, run the full check once on HEAD into a fresh gate log, then for each:
   `verify-feature.sh <commit>^ <gate-log> <allowed-files-file> <commit>`. Pass: tick it
   and log it. Fail: treat it as the active feature and say what failed. Do not rebuild
   committed work to find out what exists.
2. A `**BLOCKED**` marker: show it to the user and ask for a ruling. Record the ruling in the
   log, remove the marker, and continue. The user does not edit the file by hand.
3. A dirty tree: if the changes sit inside the active feature's files, hand them to that
   feature's builder as existing work to review and continue. Otherwise stop and show
   `git status`.
</step>

<step name="preflight">
Once per run, before the first dispatch:

1. Find the repo's commands: the full check (`make check`), the full e2e suite, and how to
   run one test file at each tier. Read the Makefile and package scripts; do not guess.
2. Write `/tmp/plan-run/<slug>/env.md`: the commands, required services, anything
   non-obvious it took to make them run. Under 30 lines.
3. Set `Status: running`, create the run log, commit both.

Do not run the full check here. `main` is only ever committed green, so the first
builder's gate is the first check of the run.

Report: features outstanding, in order, and the first `Gate:` expected.
</step>

## The loop

Repeat until every feature is ticked or the run halts.

<step name="select">
Pick the first unticked feature in file order. Its `Depends on:` must be ticked; if not,
the plan is misordered: halt. If the previous feature has a `Gate:`, stop and ask the user to
clear it before continuing.

Log the feature start ref (`git rev-parse HEAD`).
</step>

<step name="build">
Dispatch one fresh builder subagent with the brief in `brief.md` (same directory as this
file), filled in. Spawn it on the model for the feature's `Model:` tier (default
`standard`), from the column for the executor running this skill:

| Tier | Claude | Codex | Used for |
|---|---|---|---|
| `light` | `claude-haiku-5-5` | `gpt-6-luna`, effort medium | features copying an existing pattern |
| `standard` | `claude-haiku-5-5` | `gpt-6.1-sol`, effort medium | most features and fixers; the end-of-run consolidation |
| `deep` | `claude-sonnet-5-5`, effort high | `gpt-6-astra`, effort high | concurrency, idempotency, retries, recovery |

Fixers run on the same tier as their feature. A plan written with the old values maps
`haiku` → `light`, `sonnet` → `standard`, `opus` → `deep`.

Model IDs retire. Verified 2026-10-10. If a listed model is rejected or missing from the
executor's model list, use the closest current one in that tier, log the substitution,
and tell the user at the end of the run so this table gets updated.

The builder implements every step with targeted tests, then runs the full check and makes
the feature's one commit (`brief.md`, Finish). It returns the report shape `brief.md`
defines. Give it the feature section pointer, the start ref and the gate log path. Keep it
until `verify` passes; do not dispatch a separate finisher.

e2e does not run here. It runs once, at the end of the epic.
</step>

<step name="amend">
When a builder returns a file request or hits a gap, decide it yourself and keep going if
it is routine:

- a missing wiring or registration file, a test file, a generated-types file
- reordering steps or features
- a small step the plan clearly implies but forgot
- renumbering a migration

Apply the amendment under `## Amendments` at the end of the plan, one line each:
`A<n> (F<n>): <what changed> — <why>`. Log it. Send the builder on.

Amendments never loosen a `Done when`, never drop an acceptance scenario, and never cover
the cases in `What needs a human`.
</step>

<step name="verify">
Run the script, do not read the builder's report as proof:

    ~/.claude/skills/my-plan-execute/verify-feature.sh <start-ref> <gate-log> <allowed-files-file>

`<allowed-files-file>` lists the feature's `Files:` plus its amendments, one path per
line. The script checks: exactly one commit since the start ref, every changed file is
allowed, the gate log records exit 0. On any failure, send the script output back to the
same builder (`write_agent`) once; a second failure halts. No new agent.
</step>

<step name="record">
Tick the feature, log the commit hash, commit the plan, the run log and
`specs/review-findings.log.md` together. If the feature has an `**Issue:** #n` line in the
plan, close that GitHub issue (`gh issue close <n> --comment "Built in <hash>"`, or
`glab issue close` on GitLab) after the commit. Skip this when the line is absent. Print:

    Progress: <done> of <total> features (<pct>%) — F<n> <title> committed <hash>

Nothing else between features.
</step>

## End of run

When every feature is ticked:

1. Dispatch one merged reviewer on `deep` (Claude `claude-sonnet-5-5`, effort high; Codex
   `gpt-6-astra`, effort high) over the committed diffs of every feature in this run
   (`git show <commit>` for each, hashes from the log). It reads each feature's plan section
   and `## Amendments`, runs the convention brief in `~/.claude/skills/my-review/SKILL.md`
   (with the convention skills it routes to), then the correctness brief in
   `~/.claude/skills/my-review/code-reviewer.md`, and reports as `my-review` defines. Append
   must-fix findings to the findings log as `my-review` does. If there are must-fix
   findings, dispatch a single fresh fixer for all of them, across features, on the highest
   tier among the affected features. It applies them with targeted tests, runs the full
   check once, and makes one commit `fix(<scope>): <description>` with `Plan: <slug> F<n>`
   lines in the body, one per affected feature. Red after that one run: halt. Log it. This
   review is the only review in the run.
2. Run the full e2e suite once, and the plan's `Verification` section. Save one screenshot
   per acceptance scenario. Open each and compare it against its scenario.
3. Failures: dispatch a single fixer for all failures with the failing output, one commit, then rerun
   only the failing specs. Still failing: halt.
4. Run the full check once more if anything changed.
5. Set `Status: done`. Append one `Built since baseline` entry to `specs/000-baseline.md`.
   `git mv` the plan and its log into `specs/archive/`. Commit.
6. Ask the user whether to run consolidation; skip it on no. If yes, dispatch one `standard` subagent to follow `~/.claude/skills/my-review/consolidate.md`.
   It returns proposals and edits nothing.
7. Report: features done, commits, amendments, deferred items, screenshot paths, then the
   consolidation proposals verbatim (when run). Ask the user which proposals to apply. Apply only the
   approved ones, log every decision as `consolidate.md` describes, and commit the
   findings log in this repo. Skill edits live outside the repo, so name each file you
   changed. Ask the user before pushing: in some repos a push to `main` deploys. Where the
   repo works through PRs, offer to push the branch and open one.

## What needs a human

Halt for these and nothing else:

- a schema or migration change the plan did not anticipate
- a change to auth, permissions, or secrets
- loosening a `Done when` or dropping a scenario
- a choice between two defensible approaches the plan does not settle
- deployment, or any change to a running server
- the same feature failing verify twice, or the end-of-run e2e fix failing
- the full check still red after 3 runs in a feature's Finish step, or after the one run of an end-of-run fixer

To halt: leave the feature unticked, put a marker under its heading, set `Status: blocked`,
log it, commit the plan, and report.

    **BLOCKED**: <what needs deciding, one or two sentences>
    Attempted: <what was tried>
    Last output: <the relevant lines only>

Uncommitted work stays in the tree; `reconcile` picks it up.

## Never

- Never implement in this context. Always dispatch.
- Never carry one feature's context into the next builder.
- Never tick a feature without `verify-feature.sh` passing on it.
- Never run e2e per feature.
- Never put run notes in the plan. They go in the log.
- Never continue around a halt to unrelated features.
- Never run the full check more than 3 times for one feature.
- Never dispatch a separate finisher or a fixer for a verify failure. The feature's builder handles both.
- Never push without asking.
