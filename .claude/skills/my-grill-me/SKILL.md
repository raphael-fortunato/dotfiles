---
name: my-grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk every branch of the design tree.

## Rounds, not single questions

Ask in rounds. Each round is one message with every question that is open right now, never one question at a time.

- Number the questions and group them by topic.
- Give each question your recommended answer, so I can reply "ok" to most of them.
- Ask only questions whose answer does not depend on another open question. Hold dependent ones for the next round.
- If a question can be answered by exploring the codebase, explore instead of asking.

## Iterate until the picture is complete

After each round of answers:

1. Fold the answers in and list what is now decided, in a few lines.
2. Look for what the answers opened up: follow-on decisions, contradictions with earlier answers, edge cases, branches not yet walked.
3. If anything is open, ask the next round.

Stop only when no branch is left unresolved. Then give a short summary of the full set of decisions and say the grilling is done.
