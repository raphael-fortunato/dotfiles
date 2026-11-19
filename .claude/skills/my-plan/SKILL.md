---
name: my-plan
description: Turn a feature request into a written plan of an epic split into features before any code is written. Researches the stack for greenfield work, grills the requirements, and produces a spec file that /my-plan-execute later consumes. Invoked manually with /my-plan. Never writes implementation code.
disable-model-invocation: true
---
# Plan

Produces a plan file. Writes no implementation code, not even a stub, not even to check
that an idea works.

The output is consumed by `/my-plan-execute`, so the file format below is a contract, not a
suggestion.

## Phases

<step name="0a-stack-research">
Greenfield only. Skip entirely when the repo already has code, since the stack is then a
fact rather than a decision.

Search the web before proposing anything. Establish:

- whether the default stack still fits this particular problem
- current stable versions of each piece, and any breaking change since the training cutoff
- alternatives worth a sentence, specifically where the default is a poor fit
- anything deprecated, unmaintained, or newly discouraged

Report findings as options with tradeoffs, never as a decision already made. The default
stack in AGENTS.md wins ties; deviating from it needs a stated reason and the user's
agreement.

Do not research the stack for a feature added to an existing codebase. The answer there
is always "follow what the repo already does".
</step>

<step name="0b-baseline">
Existing repos only, and only when `specs/000-baseline.md` does not exist. Once written,
it is never regenerated, only appended to.

Delegate to a subagent with read-only tools. It inventories what has already been built:
the modules and what each owns, the API surface, the data model, the frontend routes and
features, what is tested and what is not, and anything half-finished or clearly abandoned.

Write the result to `specs/000-baseline.md` and commit it before continuing.

This file is a record, not a runnable plan. `/my-plan-execute` never executes it; it only
appends one `Built since baseline` entry when an epic finishes.
</step>

<step name="0c-probe-integrations">
External APIs or external data formats only.
Before writing a plan that depends on an external bank, service, or complex data export,
conduct a minimal, throwaway probe against the real API or real data fixture.
Verify assumptions (e.g. historical data windows, rate limits, schema oddities)
before baking them into features. Anything the run will need from outside (secrets,
network access, paid calls, a live checkpoint) is resolved or listed as a blocking open
question now, never discovered mid-run.
</step>

<step name="1-codebase-research">
Existing repos only. Delegate to a subagent with read-only tools.

It reports back: the relevant files and what each is responsible for, the existing
patterns to follow, the data flow through the area, and anything already present that
should be reused rather than rebuilt. It reads `specs/000-baseline.md` (including its
`Built since baseline` entries) and any active plans in `specs/`. It does not read
`specs/archive/` wholesale: it greps there only when a specific past decision matters,
and reads just the matching section.

Keep the report short. It informs the plan, it is not pasted into it.
</step>

<step name="2-grill">
Hand off to the `my-grill-me` skill. Do not conduct the interview inline and do not
improvise a substitute.

Focus the grilling on:
- User-facing behaviour, UX, and screens (what the user actually sees and does)
- Key business rules and edge cases
- What is deliberately out of scope
- When the epic touches them: timezone source of truth, what makes a repeat request
  idempotent and what a retry returns, pagination, error shapes
Technical plumbing (exact schema field names, internal function signatures) is for the
agent to decide unless it introduces architectural risk.
</step>


<step name="3-propose">
Propose the epic as 3 to 6 features. A feature is a vertical slice: it cuts through every
layer it needs (storage, API, UI) for one small capability, so it is usable or testable
on its own. List them as numbered titles with one line on the user outcome each.

The user picks, reorders or rejects.
</step>

<step name="4-write">
Write the plan for what was selected to `specs/<slug>.md`, in the format below. Name
files and components; write no implementation code.
</step>

<step name="5-self-check">
Before presenting, check the plan and fix what fails. Do not list the results; fix them.

- **Wiring:** every step's `Files:` includes the files that connect it: router
  registration, `main.py` or app startup, scheduler registration, generated API types,
  frontend API client, compose or env wiring, and any test that asserts on those.
- **Needs:** everything a step reads (a field, a setting, a function) is created by an
  earlier step's `Files:` and checked by its `Done when`, or already exists in the code.
- **Promises:** every behaviour the prose promises appears in some `Done when` or
  scenario. Prose alone gets dropped.
- **Size:** no step over about 6 non-test files. Split the step if it is.
- **Order:** no step or e2e spec depends on something a later feature builds.
- **Migrations:** named by purpose, not pre-numbered. The builder numbers them at build
  time.
- **Cross-cutting rules:** if the epic touches time, retries, idempotency, pagination or
  error shapes, the `Cross-cutting rules` section settles each one.
</step>

<step name="6-present">
Commit the plan with `Status: ready`. Then create GitHub issues from it, following the
`to-issue` skill's issue template (`~/.copilot/skills/to-issue/SKILL.md`). Detect GitHub or
GitLab from the git remote. Skip the skill's interactive quiz: the user approved the features
in step 3.

- **Epic issue**, titled with the plan title. Body: Context, a checkbox list of the feature
  issues, and a link to `specs/<slug>.md`. Do not add sub-issue links.
- **One issue per feature**, titled `F<n>: <feature title>`, created in `Depends on:` order so
  blockers exist first. Body: `Parent` is the epic; `What to build` is the feature's outcome
  line; `Acceptance criteria` lists its scenarios and each step's `Done when` lines;
  `Files to modify` lists the feature's `Files:` without line ranges, since planning writes
  no code; `Blocked by` comes from `Depends on:`.
- **Label**: `HITL` if the feature has a `Gate:`, otherwise `AFK`.
- Create with `gh issue create` (or `glab issue create`).
- Then add an `**Issue:** #<n>` line under each feature heading in the spec, and the epic
  number under the title, and commit the spec again.

If the user asks for changes, edit, re-run the self-check, commit, update the issues to match,
and present again.
</step>

## Baseline file format

Written once per repo, at `specs/000-baseline.md`.

<example name="baseline-file">
# Baseline

&gt; Status: baseline
&gt; Generated: &lt;date&gt;
&gt; Not executable. This file records what existed before planning began.

## Summary

Three or four sentences: what this system does and roughly how it is put together.

## Built

### B1: &lt;Area, e.g. Document ingestion&gt;

**Files:** `backend/src/app/documents/`, `frontend/src/features/documents/`
**Does:** &lt;what it does today, not what it should do&gt;
**Tested:** unit, api | partial | none
**Notes:** &lt;anything surprising, or a known deviation from conventions&gt;

### B2: &lt;Area&gt;

...

## Gaps

Things visibly missing or unfinished. Observations only, not a proposal.

- &lt;gap&gt; (relates to: B1)

## Convention deviations

Where existing code departs from the convention skills. Record it; do not fix it here.

- &lt;file or area&gt;: &lt;which convention, and whether it looks deliberate&gt;
</example>

`Built` entries have no checkboxes and no `Done when`. They are a record of what exists,
never executable work, and must not be mistaken for it.

Fixing convention deviations is out of scope for planning. That is a separate `/my-review`
pass against the whole tree, run deliberately.

## Plan file format

Three levels: epic (the file), feature (the unit that is built, reviewed, committed and
ticked), step (an ordered build step inside a feature). "Slice" means feature.

<example name="plan-file">
# &lt;Epic title&gt;

&gt; Status: ready
&gt; Created: &lt;date&gt;

## Context

Two or three sentences: what this changes and why.

## Stack decisions

Greenfield only. What was chosen, what was rejected, and why.

## Out of scope

Things a reader might assume are included and are not.

## Cross-cutting rules

Only when the epic needs them. One line each.
- Time: &lt;source of truth for timezone, naive vs aware&gt;
- Idempotency: &lt;what identifies a repeat, what a retry returns&gt;

## Open questions

- [ ] &lt;question&gt; (blocks: F2)

## - [ ] F1: &lt;Feature title&gt;

**Model:** standard
**Depends on:** none
**Gate:** none
**Builds on:** B1

&lt;One sentence on what this feature delivers.&gt;

Acceptance scenarios:
- &lt;user-level scenario&gt;
- &lt;user-level scenario&gt;

### F1.1: &lt;Step title&gt;

**Files:** `backend/src/app/users/queries.py`, `backend/tests/users/test_queries.py`
**Tests:** unit | integration | api | e2e
**Does:** &lt;one or two sentences&gt;
**Done when:**
- &lt;observable condition&gt;

### F1.2: &lt;Step title&gt;

...

## - [ ] F2: &lt;Feature title&gt;

...

## Verification

The end-of-epic check: the full e2e suite plus any command sequence a human runs.

## Amendments

Written by `/my-plan-execute` during the run. Empty when the plan is written.
</example>

Rules, because `/my-plan-execute` depends on them:

- Feature IDs are `F<n>`; step IDs are `F<n>.<n>`. The checkbox lives on the feature
  heading only.
- `Issue:` lines are written by step 6 after the GitHub issues exist. The plan is
  committed before issues are created, so the numbers can be added in a second commit.
- Features carry `Model:`, `Depends on:` and `Gate:`. `Depends on:` lists earlier features
  or `none`; it is never left out. `Gate:` is `none` or what the user must check before the
  next feature starts (e.g. "live email received").
- `Model:` is a tier: `light`, `standard` or `deep`. `/my-plan-execute` maps it to a Claude
  or Codex model. `light` only for features that copy an existing pattern closely. `deep`
  where the difficulty is reasoning: concurrency, idempotency, retries, recovery, anything
  with races. Everything else is `standard`.
- `Builds on:` lists baseline IDs, and is omitted when the feature touches no existing
  code.
- Steps run in order; the order is the dependency inside a feature.
- `Files:` names every file the step creates or edits, including its test file and its
  wiring. A directory entry ending in `/` covers everything under it; use it sparingly.
- `Tests:` declares the level. A step with `Tests: e2e` writes the Playwright spec for the
  feature's scenarios alongside the UI it tests, not ahead of it.
- `Done when:` conditions are observable: a test passes, an endpoint returns a status, a
  command produces output. Never "works correctly".

## Sizing

- 3 to 6 features per epic. 2 to 4 steps per feature.
- A step touches about 6 non-test files at most. More means two steps.
- Each feature leaves the repo green with one commit.

## Sequencing

For greenfield work, F1 is scaffolding: `/my-setup-repo` runs before any application
feature, and the plan says so.

After that, F1 puts a working end-to-end path in front of the user as early as possible.
Never build all tables first, then all endpoints, then all screens.

## Never

- Never write implementation code during planning.
- Never skip the grilling phase, however clear the request seems.
- Never regenerate a baseline file that already exists.
- Never put a checkbox on a baseline entry or on a step.
- Never fix convention deviations during planning.
- Never pick a stack deviation without the user agreeing to it.
- Never invent a requirement the user did not state or confirm.
- Never leave a feature without `Model:`, `Depends on:`, `Gate:` and scenarios, or a step
  without `Files:`, `Tests:` and `Done when:`.
- Never write a `Done when` condition that cannot be checked by running something.
- Never present a plan that has not passed the self-check.
