---
name: my-reflection
description: Use when a session went wrong and you want to understand why — repeated work, ignored plans, unexpected cost, stumbles, "why did it do that", or building a record of what happened. Works with Claude Code session transcripts stored at ~/.claude/projects/.
---

# Reflection

Pin down what went wrong in a session, read the transcript, and report findings with
evidence. This skill reports facts. It does not propose fixes to skills or workflow.

**Core principle:** Every finding cites `file:line`. No citation, no finding. Every
number comes from the transcript or a command you ran.

## Workflow

### 1. Problem intake

Ask until you can write a statement naming: the session(s), the turn range if known,
what was expected, what happened, and the observable that matters (wall-clock, repeated
actions, cost, a specific wrong decision). "It took too long" is a complaint, not a
problem statement.

Do not start analysis until you have the statement.

### 2. Locate the session

Claude Code stores sessions at:
```
~/.claude/projects/<project-hash>/
```

Each session is one or more `.jsonl` files. Find the right one:

```bash
# List projects
ls ~/.claude/projects/

# Find sessions for this project (run from inside the project)
project_hash=$(echo -n "$(pwd)" | shasum -a 256 | cut -c1-8)
ls -lt ~/.claude/projects/ | grep "$project_hash" | head -5

# Or search by recency
ls -lt ~/.claude/projects/*/  | head -20
```

Confirm you have the right session by quoting its first user prompt and timestamp.

### 3. Dispatch analysis agents in parallel

Read the region around the reported problem yourself first. Then dispatch one analyst
subagent per applicable dimension in a single response (parallel):

**Dimensions — include all that could explain the reported problem:**

<step name="analyst-brief">
You are a session analyst. You have read-only access to a session transcript at the
path provided. Read it. Report only findings with `file:line` citations. Discard
anything you cannot cite.

Human prompts are the user's words. Hook output, system reminders, and tool results are
not. Do not conflate them.

Your dimension: [one of the following]
</step>

| Dimension | Brief addition | Use when |
|-----------|---------------|----------|
| **plan-adherence** | Did the agent follow the plan or spec that was loaded? Find every deviation — places where the plan said one thing and the agent did another. Note whether each deviation was acknowledged. | "It ignored the plan" |
| **repeated-work** | Find every instance where the agent did the same thing twice. List: what was repeated, the turns it happened at, and whether the repetition was justified. | "Why did it do that again?" |
| **stumbles** | Find every error, correction, dead end, and recovery. For each: what failed, how many turns it took to recover, and whether it was recovered at all. | General quality, "it seemed lost" |
| **cost-and-time** | Count tool calls by type (read, edit, bash, agent). Identify the 3 most expensive turns. Note any long chains of reads before an action. | "Why did it cost so much?" |
| **skill-timeline** | List each skill that loaded (look for skill invocations in the transcript). Note the turn each loaded and whether the skill's instructions were followed in subsequent turns. | "The skill didn't fire" / "It ignored the instructions" |
| **request-conflicts** | Find any place where two instructions in the session contradicted each other — system prompt vs user request, skill instruction vs CLAUDE.md, earlier request vs later request. Note how each conflict was resolved. | "It did the opposite of what I said" |

### 4. Write the report

Merge findings from all analysts. For each finding:
- State what happened
- Cite `file:line` (the JSONL file and approximate line/turn number)
- Note whether it was a one-off or a pattern

Structure:

```markdown
# Session Reflection — <session id or date>

**Problem statement:** <from intake>
**Session:** <path>
**Turns analysed:** <range>

## Findings

### [Dimension]
<finding with citation>

## Summary
<2–3 sentences: what went wrong and what pattern it reflects>

## Open questions
<things the transcript couldn't answer>
```

### 5. GitHub issues (optional)

Only if the user asks. Never proactively offer to file issues.

## Hard rules

- **Read-only.** Never modify, move, or delete a session file.
- **Cite or drop.** A finding without a transcript citation is discarded.
- **No diagnosis of skills.** Report what happened in the session. Do not propose changes
  to skills or CLAUDE.md. That is a separate decision.
- **Intake before analysis.** Nothing starts until the problem statement is written.
  A statement you reconstructed yourself is not an answer — write the questions and wait.

## Red Flags

| Thought | Reality |
|---------|---------|
| "The problem is obvious, skip intake" | The statement scopes everything. Get it first. |
| "I'll sweep the whole transcript and report everything" | An unscoped sweep wastes time on the wrong question. Ask first. |
| "I found the problem — here's how to fix the skill" | Report the evidence. Proposing fixes is out of scope. |
| "I'll cite the approximate area" | Approximate is not a citation. Find the exact line or drop the finding. |
