---
name: to-issues
description: Break a plan, spec, or PRD into independently-grabbable issues using tracer-bullet vertical slices. Works with GitHub and GitLab. Use when user wants to convert a plan into issues, create implementation tickets, or break down work into issues.
---

# To Issues

Break a plan into independently-grabbable issues using vertical slices (tracer bullets). Supports both GitHub and GitLab repositories.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes an issue number or URL as an argument, fetch it:
- **GitHub**: use `gh issue view <number>` (with comments)
- **GitLab**: use `glab issue view <number>` (with comments)

Auto-detect the platform from the git remote URL.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code.

### 3. Assess complexity and suggest epics/user stories (if needed)

If the issue or plan seems complex (spans multiple domains, affects many systems, or has 10+ potential slices), suggest organizing it into **epics** or **user stories** first:

- **User stories**: Capture distinct user-facing behaviors or features
- **Epics**: Group related user stories into larger themes

Ask the user:
- Should we break this into user stories/epics before slicing?
- Do you already have user stories defined?

If the user approves, create the epic/user story issues first, then slice each one separately in subsequent iterations. This provides better issue hierarchy and makes large projects more navigable.

### 4. Draft vertical slices

Break the plan into **tracer bullet** issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
</vertical-slice-rules>

### 4. Identify files to be modified

For each proposed slice, scan the codebase to find every file the slice must change:

1. **Auto-scan**: Search for files related to the feature based on keywords, module structure, and existing code patterns
2. **Describe each change**: For each file, state clearly what changes and why, so an implementer does not have to rediscover it. Name the functions, classes, routes, fields or config keys involved.
3. **Mock code when it helps**: Where the change is hard to describe in words (a new signature, a config shape, a new route), add a short mock code block. Label it as illustrative, not final. Do not give line numbers.

If the auto-scan is unclear or incomplete, ask the user:
- "I found these files, but I'm not sure about X. Can you clarify?"
- "Are there other files that should be modified?"

### 5. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)
- **Files to modify**: each file with a one-line summary of its change (from step 4)

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?
- Are the identified files and planned changes correct?

Iterate until the user approves the breakdown.

### 6. Create the issues

For each approved slice, create an issue using the appropriate CLI:
- **GitHub**: `gh issue create`
- **GitLab**: `glab issue create`

Create issues in dependency order (blockers first) so you can reference real issue numbers in the "Blocked by" field.

Use the issue body template below for both platforms:

<issue-template>
## Parent

#<parent-issue-number> (if the source was an issue, otherwise omit this section)

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Files to modify

List each file that must change. For each, state what changes and why, in enough detail that the change can be made without rediscovering it. Add a mock code block when the change is hard to describe in words. Mock code is illustrative, not final, and has no line numbers.

### File: `path/to/file.py`
**What to change**: Add a `parse_range()` helper used by `list_items()`, and accept a `range` query parameter on `GET /items`. Keep the existing default behaviour when the parameter is absent.

**Mock code** (illustrative):
```python
def list_items(range: str | None = None) -> list[Item]:
    start, end = parse_range(range)
    ...
```

---

### File: `path/to/config.yaml`
**What to change**: Add a `max_range_days` key under `api:` with a default of 90.

**Mock code** (illustrative):
```yaml
api:
  max_range_days: 90
```

---

## Blocked by

- Blocked by #<issue-number> (if any)

Or "None - can start immediately" if no blockers.

</issue-template>

Do NOT close or modify any parent issue.
