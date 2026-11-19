---
name: my-review
description: Use when a diff needs checking against the codebase conventions and the plan before it is committed or merged. Invoked manually with /my-review, and called by /my-plan-execute on each feature before its commit.
---

# Review

Checks a diff against the convention skills and for correctness. One merged reviewer
for small diffs, two in parallel for large ones: conventions and correctness. Most diffs
are clean, and `CLEAN` is the expected result.

Usage: `/my-review` reviews the current branch against `main`. `/my-review <ref>` reviews
against another ref. `/my-plan-execute` calls it on an uncommitted feature diff.

There is no `make check` before reviewing. The build loop runs the gate once, after review
fixes are in, so review findings land before the gate rather than after it.

## Routing

Pick the convention skills that apply from the changed paths:

<example name="routing">
  *.py                               → my-python
  backend/**/routers/, schemas/      → my-api  (in addition to my-python)
  **/pb_migrations/**                → my-api  (PocketBase access rules)
  frontend/**                        → my-nextjs
  **/tests/**, test_*.py, *.test.ts  → my-testing
</example>

For the correctness reviewer, find the plan: the path `/my-plan-execute` passed, or else
the most recent `specs/*.md` that is not `000-baseline.md` or a `.log.md`. None: review
against the diff and git history alone.

## Reviewers

Pick the shape from the diff size: insertions plus deletions from `git diff HEAD
--shortstat`, plus the line count of untracked files in scope.

- **Small:** 150 changed lines or fewer, or the feature is `light`. Dispatch one merged
  reviewer on `standard`. It runs both briefs below in order and returns both reports.
- **Large:** anything bigger. Dispatch both reviewers in one response: the convention
  reviewer on `light`, the correctness reviewer on `standard`.

Automated mode from `/my-plan-execute` runs once, at the end of a plan: one merged
reviewer on `deep` that runs both briefs. Manual
mode uses the size rule above, and `deep` for the correctness reviewer when asked.

Tiers map to Claude and Codex models in the table in `my-plan-execute`.

<step name="convention-reviewer-brief">
Read these convention skills: <list from routing>. Review the diff against them and
nothing else. Each skill applies only to the files that routed to it.

Report each finding as:

  <file>:<line> [must-fix|optional] <skill>: "<verbatim rule text>" — <what to change>

**must-fix** is a stated rule being broken. A "Never" bullet is always must-fix.
**optional** is a genuine improvement no stated rule requires.

An empty report is valid and common. A finding you cannot support with a verbatim quote
is dropped.

Do not report: anything ruff, mypy, eslint or tsc already enforce; preferences not in the
skills; correctness, performance or security unless a skill names them; code the diff did
not touch.
</step>

<step name="correctness-reviewer-brief">
Read `~/.claude/skills/my-review/code-reviewer.md` and follow it. If a plan path is given,
read only the feature under review and `## Amendments`.

Report findings as:

  <file>:<line> [Critical|Important|Minor] <what's wrong> — <why it matters> — <how to fix>
</step>

## Collect

Merge both reports and drop duplicates. Critical, Important and convention must-fix are
must-fix. Minor and convention optional are optional.

- **Automated (from `/my-plan-execute`):** return the must-fix list to the orchestrator
  and log the optional ones. Do not fix; the feature's builder applies them.
- **Manual:** present findings grouped by must-fix and optional. The user may promote, demote
  or drop any. Then dispatch one fixer with the approved list.

## Log findings

After collecting, and in manual mode after the user's rulings, append one line per must-fix
finding and per dropped finding to `specs/review-findings.log.md` in the reviewed repo.
Create it if missing. From `/my-plan-execute`, the orchestrator commits it with the run
log; in manual mode it goes in the fix commit.
Optional findings are not logged. A `CLEAN` review appends one line with `-` for the
skill, rule, file and what fields.

    <YYYY-MM-DD> <repo> <slug F<n> | manual> <kept|dropped> <skill|correctness> "<rule>" — <file> — <what, under 15 words>

- Convention findings: `<rule>` is the verbatim rule text the reviewer quoted, unchanged,
  so the same rule groups across runs.
- Correctness findings: `<rule>` is a short tag for the kind of bug, reused when one
  fits: `unbounded read`, `race on concurrent write`, `missing 4xx`, `swallowed error`,
  `non-atomic multi-write`, `timezone/date boundary`, `N+1 query`, `stale client state`.
  Coin a new tag only when none fits.
- Dropped: `<what>` gives the reason, e.g. `plan specifies the hand-built queue`.

The end-of-epic consolidation (`consolidate.md`, same directory) reads this log. Never
edit or remove earlier lines.

## Fix (manual mode only)

<step name="fixer-brief">
Apply the listed findings. Convention findings change structure only, never behaviour.
Correctness findings change behaviour as stated. Run only the affected test files plus
lint and types on the changed files, then the full check once at the end.

Halt and report instead of applying when a fix would edit a test to keep it passing,
touch a file no finding named, or introduce a new module or interface.
</step>

Commit applied fixes as `refactor: apply review findings`.

## Rulings

When the user rules on an ambiguous finding, the ruling goes into the convention skill's text
so the next review reads it. There is no separate rulings file.

## Report

Begin with `CLEAN` or `FINDINGS`. Then: count of must-fix and optional per reviewer, what
was applied, "Declined to judge" items with the ruling on each.

## Never

- Never auto-apply an optional finding.
- Never apply a convention fix that changes behaviour.
- Never invent findings to justify the run.
- Never review code the diff did not touch.
