---
name: verification-before-completion
description: Use before claiming any work is complete, fixed, or passing — before committing, creating PRs, or moving to the next task. Requires running the verification command and reading its output in this message before making any success claim.
---

# Verification Before Completion

## The Iron Law

```
NO COMPLETION CLAIM WITHOUT FRESH VERIFICATION OUTPUT IN THIS MESSAGE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate

Before claiming any status:

1. **Identify** — what command proves this claim?
2. **Run** — execute it in full, right now
3. **Read** — full output, exit code, failure count
4. **Verify** — does the output confirm the claim?
   - If NO: state actual status with evidence
   - If YES: state the claim WITH the evidence
5. **Only then** — make the claim

Skipping any step is not verifying. It is asserting.

## Common Claims and What They Require

| Claim | Requires | Not sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| `make check` clean | `make check` output: exit 0 | Partial run, "nothing changed" |
| Bug fixed | Test reproducing original symptom: passes | Code changed, assumed fixed |
| Red-green cycle complete | Watched test fail, then pass | Test passes once |
| Done when conditions met | Each condition checked against output | Reading the code |
| Build succeeds | Build command: exit 0 | Linter passing |

## Red Flags — Stop

- Using "should", "probably", "seems to", "looks like"
- Expressing satisfaction before verification ("Great!", "Done!", "Perfect!")
- About to commit without running `make check`
- Relying on output from a previous turn
- "I'm confident this works" — confidence is not evidence

## Rationalisations

| Excuse | Reality |
|--------|---------|
| "Should work now" | Run it |
| "Nothing changed that could break it" | Run it |
| "I'm confident" | Confidence ≠ evidence |
| "Linter passed" | Linter ≠ test suite |
| "Tests passed earlier this session" | The tree may have changed. Run them now. |
| "Just one more thing to do first" | Verification comes before the claim, not after |

## Applies To

- Any variation of "done", "fixed", "passing", "complete", "ready"
- Any expression of satisfaction about the state of the work
- Any positive statement implying the code is correct
- Committing, PR creation, task completion, moving to next task
