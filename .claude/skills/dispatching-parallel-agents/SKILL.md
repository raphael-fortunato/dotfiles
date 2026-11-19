---
name: dispatching-parallel-agents
description: Use when facing 2 or more independent investigation or implementation tasks with no shared state or sequential dependencies — dispatch one agent per domain in a single response to run concurrently rather than working through them one at a time.
---

# Dispatching Parallel Agents

## When to Use

```
Multiple tasks?
  └─ Are they independent (no shared state, no sequential dependency)?
       └─ Yes → one agent per domain, dispatched in a single response
       └─ No (related failures, shared state) → single agent handles all
```

**Good candidates:**
- 3+ test files failing with different root causes
- Multiple subsystems broken independently
- Independent research questions (e.g., "what does the API return?" and "what does the DB schema say?")
- Convention review fan-out (what `my-review` does)

**Bad candidates:**
- Failures that might share a root cause (fix one might fix others)
- Agents that would edit the same files
- Tasks where output of one informs the other

## The Pattern

### 1. Identify independent domains

Group by what's actually broken or being investigated. Each domain should be understandable without context from the others.

### 2. Issue all dispatches in one response

Multiple `Agent(...)` calls in a single response = parallel execution. One per response = sequential. This is the only mechanic that matters.

### 3. Write focused prompts

Each agent gets:
- One clear problem domain
- All context it needs to understand the problem (error messages, test names, file paths)
- A constraint on what it may touch ("do not change files outside `backend/users/`")
- A specific output format ("return: root cause summary + files changed")

Never give an agent your session history. Construct exactly what it needs.

### 4. Integrate results

When agents return:
- Read each summary
- Check for conflicting changes (did two agents edit the same file?)
- Run the full test suite
- Resolve any conflicts before committing

## Prompt Structure

```
Fix the 3 failing tests in tests/documents/test_search.py:

1. "test_search_returns_empty_on_no_match" — expects [] but gets None
2. "test_search_filters_by_user_id" — passes wrong user_id to query
3. "test_search_pagination" — off-by-one on limit

These are independent bugs in the search query layer. Do NOT change
anything outside backend/documents/queries.py and tests/documents/test_search.py.

Return: root cause of each failure and what you changed.
```

Key ingredients: specific failures named, specific files scoped, output format stated.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| "Fix all the failing tests" | Name the specific test file and failures |
| Agent edits the same file as another | Scope each agent to non-overlapping files |
| Vague output: "fix it" | State what to return: root cause + changes |
| Dispatching one per response | All dispatches in one response = parallel |
| Pasting your whole session history | Give only what the agent needs for its domain |

## After Agents Return

Always run the full suite before reporting done. Agents can make correct-looking local fixes that conflict with each other or break something else. The suite is the only proof that integration held.
