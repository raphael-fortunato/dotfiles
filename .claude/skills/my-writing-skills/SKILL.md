---
name: my-writing-skills
description: Use when creating a new skill or editing an existing one. Covers frontmatter rules, description field pitfalls, when to use prohibitions vs recipes, bulletproofing against rationalisation, and token efficiency.
---

# Writing Skills

Reference for writing skills in this repo (`skills/` directory, loaded by Claude Code).

## Skill file structure

```
skills/
  skill-name/        ← kebab-case, verb-first preferred ("dispatching-parallel-agents")
    SKILL.md         ← required; what the agent reads
    supporting.*     ← only for heavy reference (100+ lines) or reusable scripts
```

Keep supporting files out of `SKILL.md` unless the content is under ~50 lines. A heavy
reference in the main file makes every conversation that loads the skill pay for content
it may not need.

## Frontmatter

```yaml
---
name: skill-name          ← letters, numbers, hyphens only
description: Use when…    ← see Description below
---
```

Max 1024 characters total in the frontmatter block.

## Description field — the most important part

The description is the only thing loaded into every conversation. Agents decide which
skills to read based solely on it. Two rules that are easy to violate:

**1. Start with "Use when" — describe triggering conditions, not workflow.**

```yaml
# ❌ BAD: summarises the skill's process
description: Review a diff by fanning out one reviewer per convention skill, then apply must-fix findings.

# ✅ GOOD: triggering conditions only
description: Use when you want to review a diff against codebase conventions before committing or merging.
```

Why this matters: testing showed that when the description summarises workflow, agents
follow the description as a shortcut and skip reading the full skill body. A description
that says "dispatches two reviewers" caused an agent to dispatch two reviewers and skip
the skill's richer instruction — including the correctness reviewer that needed different
context than the convention reviewers.

**2. Never summarise the workflow in the description.**

The body is where the workflow lives. The description is the trigger. A description that
reads like a one-line summary of the skill body creates a shortcut agents will take. The
body becomes documentation they skip.

## SKILL.md structure

```markdown
# Skill Name

Brief: what is this, core principle in 1–2 sentences.

## When to Use
Bullet list of triggering symptoms. Decision flowchart only when the decision is non-obvious.

## [Main content sections]
Steps, patterns, examples.

## Common Rationalizations / Red Flags  ← for discipline skills only
Table of excuses + reality. Red flags list for self-checking.

## Never  ← hard prohibitions
```

## Prohibition vs recipe — pick the right form

Matching the form to the failure type matters. The wrong form backfires.

| Failure type | Right form | Wrong form |
|---|---|---|
| Knows the rule, skips it under pressure | Prohibition + rationalization table + red flags | Soft guidance ("prefer…") |
| Output has the wrong shape (too verbose, buried verdict, restated spec) | Positive recipe: state what the output IS, in order | Prohibition list ("don't restate", "never narrate") |
| Omits a required element | Structural: mark the field REQUIRED in the template | Prose reminders near the template |
| Behaviour should depend on a condition | Conditional keyed to an observable: "if X then Y" | Unconditional rule + exemption clauses |

**Why prohibitions backfire on shaping problems:** an agent under pressure negotiates
with "don't X". A recipe leaves nothing to negotiate: the output either matches the
stated shape or it doesn't. No nuance clauses — "don't X unless it matters" reopens the
negotiation.

## Bulletproofing discipline skills

For skills that enforce a behavioural rule (test first, verify before claiming done):

**1. State "violating the letter is violating the spirit" early.** This closes the class
of "I'm following the spirit" arguments.

**2. Build a rationalisation table from real failures.**

```markdown
| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests written after prove what the code does, not what it should do. |
```

**3. Add a Red Flags list** — easy for an agent to self-check when it's about to
rationalise:

```markdown
## Red Flags — STOP
- Code before test
- "I already manually tested it"
- All of these mean: delete code, start over.
```

**4. Close every loophole explicitly.** "Delete it" is weaker than "Delete it. Start over.
Don't keep it as reference. Don't look at it. Delete means delete."

## Token efficiency

Skills that apply broadly (convention skills, build loop, etc.) load into many
conversations. Every token has a cost.

- Aim for under 500 words for broadly-loaded skills. Under 200 for "always-on" ones.
- Move heavy reference to a supporting file. Reference it by path.
- One excellent example beats three mediocre ones.
- Don't explain what the agent already knows. Challenge each paragraph: "does the agent
  really need this, or am I documenting the obvious?"
- Use cross-references instead of repeating another skill's content.

## When to create a skill

Create when:
- A technique wasn't obvious and you'd need to look it up again
- The pattern applies across projects (not codebase-specific)
- Others on future sessions would benefit

Don't create for:
- One-off solutions
- Standard practices well-documented elsewhere
- Project-specific conventions → put those in `CLAUDE.md` or the convention skills
- Anything mechanically enforceable (lint rules, type checks) — automate it, don't document it

## Naming

Prefer verb-first gerunds for processes: `dispatching-parallel-agents`,
`systematic-debugging`, `verification-before-completion`. Use noun phrases for references:
`my-api`, `my-python`. Kebab-case only — no parentheses or special characters.
