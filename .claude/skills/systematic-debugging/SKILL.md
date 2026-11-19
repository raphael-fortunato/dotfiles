---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging

## Overview

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## When to Use

Use for ANY technical issue: test failures, bugs, unexpected behavior, performance problems, build failures, integration issues.

**Use this ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- You don't fully understand the issue

## The Four Phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read Error Messages Carefully**
   - Don't skip past errors or warnings
   - Read stack traces completely
   - Note line numbers, file paths, error codes

2. **Reproduce Consistently**
   - Can you trigger it reliably?
   - What are the exact steps?
   - If not reproducible → gather more data, don't guess
   - **Minimize reproduction cycle time:** If the failure occurred during a long test run (>30 seconds) or full suite, isolate the failing test into a fast standalone command (e.g. Playwright `--grep`, pytest `-k`) before attempting to diagnose or modify code. Fast feedback (sub-30 seconds) is mandatory for effective debugging.

3. **Check Recent Changes**
   - What changed that could cause this?
   - `git diff`, recent commits
   - New dependencies, config changes
   - Environmental differences

4. **Gather Evidence in Multi-Component Systems**

   When the system has multiple components (e.g., FastAPI route → service → Postgres query, or Next.js fetch → API → Qdrant), **before proposing fixes, add diagnostic instrumentation:**

   ```
   For EACH component boundary:
     - Log what data enters component
     - Log what data exits component
     - Verify environment/config propagation
     - Check state at each layer

   Run once to gather evidence showing WHERE it breaks
   THEN analyze evidence to identify failing component
   THEN investigate that specific component
   ```

   **Example (FastAPI layered system):**
   ```python
   # Layer 1: Route handler — log what arrived
   logger.debug("route received: %s", payload.model_dump())

   # Layer 2: Service — log what it's calling with
   logger.debug("service calling query: doc_id=%s user_id=%s", doc_id, user_id)

   # Layer 3: Query — log what it's executing
   logger.debug("query sql params: %s", params)
   ```

   This reveals which layer fails before any fix is attempted.

5. **Trace Data Flow**

   When an error is deep in a call stack:
   - Where does the bad value originate?
   - What called this function with the bad value?
   - Keep tracing up until you find the source
   - Fix at source, not at symptom

### Phase 2: Pattern Analysis

**Find the pattern before fixing:**

1. **Find Working Examples** — locate similar working code in the same codebase
2. **Compare Against References** — if implementing a pattern, read the reference completely
3. **Identify Differences** — list every difference between working and broken code, however small
4. **Understand Dependencies** — what settings, config, environment does this need?

### Phase 3: Hypothesis and Testing

**Scientific method:**

1. **Form Single Hypothesis** — state clearly: "I think X is the root cause because Y"
2. **Test Minimally** — make the SMALLEST possible change to test hypothesis. One variable at a time.
3. **Verify Before Continuing** — if it worked, go to Phase 4. If not, form a NEW hypothesis. Do NOT stack fixes.
4. **When You Don't Know** — say "I don't understand X." Ask. Research. Don't pretend.

### Phase 4: Implementation

**Fix the root cause, not the symptom:**

1. **Create Failing Test Case** — simplest possible reproduction, automated if possible. MUST exist before fixing. Follow `my-testing` for the test level (unit/integration/api).

2. **Implement Single Fix** — address the root cause identified. ONE change at a time. No "while I'm here" improvements.

3. **Verify Fix** — test passes? No other tests broken? Run `make check`.

4. **If Fix Doesn't Work**
   - STOP
   - Count: how many fixes have you tried?
   - If < 3: return to Phase 1 with new information
   - **If ≥ 3: STOP and question the architecture (step 5 below)**

5. **If 3+ Fixes Failed: Question Architecture**

   Pattern indicating an architectural problem:
   - Each fix reveals new shared state / coupling / problem in a different place
   - Fixes require "massive refactoring" to implement
   - Each fix creates new symptoms elsewhere

   **STOP and ask the human before attempting more fixes.** This is not a failed hypothesis — this is a wrong architecture.

## Red Flags — STOP and Follow Process

If you catch yourself thinking any of these, return to Phase 1:

- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Here are the main problems: [lists fixes without investigation]"
- Proposing solutions before tracing data flow
- "One more fix attempt" (when already tried 2+)
- Each fix reveals a new problem in a different place

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "I'll write test after confirming fix works" | Untested fixes don't stick. Test first proves it. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "I see the problem, let me fix it" | Seeing symptoms ≠ understanding root cause. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem. Question pattern, don't fix again. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence | Understand WHAT and WHY |
| **2. Pattern** | Find working examples, compare | Identify differences |
| **3. Hypothesis** | Form theory, test minimally | Confirmed or new hypothesis |
| **4. Implementation** | Create test, fix, verify | Bug resolved, `make check` green |
