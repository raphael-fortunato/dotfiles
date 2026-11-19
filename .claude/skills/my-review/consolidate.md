# Consolidate review findings

Turns mistakes that keep recurring in reviews into proposed convention changes. Runs once
at the end of an epic (dispatched by `/my-plan-execute`), or on request. It proposes. It
never edits a skill, a lint config or the brief; the user approves each proposal first.

## Inputs

- This repo's `specs/review-findings.log.md`. The line format is in `my-review` under
  Log findings.
- The same file in every other repo under `~/software/*/`, where it exists. A repo
  without one is skipped silently.
- The convention skills the candidate rules come from (`~/.claude/skills/my-*/SKILL.md`)
  and the frequently-missed list in `~/.claude/skills/my-plan-execute/brief.md`.

Lines with `consolidate` in the third field record earlier decisions. A rule already
`promoted` or `declined` is not proposed again, with one exception: it was promoted to
the brief, and builders keep missing it at the same rate. Then propose the next step up
the ladder below.

## Find candidates

Group convention findings by skill plus verbatim rule, and correctness findings by tag.

- **Recurring:** `kept` in 3 or more features, or in 2 or more repos.
- **Misfiring:** `dropped` 2 or more times on the same rule. The rule is ambiguous or
  wrong, not the builders.

Everything else is noise for now. Say how many lines and repos you read, then stop if
nothing qualifies.

## Choose where each candidate goes

Pick the first that works:

1. **Lint rule.** A ruff, mypy or eslint rule that catches it mechanically. Name the
   exact rule code and the config line. A machine check beats any reminder.
2. **The brief's frequently-missed list.** The rule exists and is clear, but builders
   miss it. Keep the list at 10 or fewer; when adding, propose dropping one with no
   `kept` hits since it was added.
3. **Convention text.** A correctness pattern that no skill states yet, or a misfiring
   rule that needs rewording or a stated exception. Give the exact sentence and where it
   goes in which skill.
4. **No change.** It recurred because of one plan's quirk, or it's covered already.

## Judge each proposal before you make it

Recurring is not the same as right. A reviewer can be consistently wrong. For each
candidate, answer briefly:

- **Best practice?** Is this an established practice, backed by a ruff/eslint rule
  rationale, the framework's own docs, or a widely accepted principle? Or is it one
  reviewer's taste? Name the source.
- **Better code here?** Take two real findings from the log and say what following the
  rule actually changed: a bug avoided, a clearer read, an easier change. If the honest
  answer is "about the same", that's a weak proposal.
- **Cost.** Would it flag good code, push toward over-abstraction, or fight an existing
  rule or a common plan decision? Misfiring `dropped` lines are evidence here.
- **Checkable?** Can it be stated as one sentence a reviewer can verify against a diff?

Verdict per candidate: `recommend`, `weak` or `reject`. Only `recommend` goes forward as
a proposal; `weak` and `reject` get one line each so the user sees what was set aside.

## Report

Under 400 words:

    Read: <n> lines from <repos>
    Proposals:
      P<n> [lint|brief|convention] <skill>: <exact text or rule code, and where it goes>
        Evidence: <count> kept in <features/repos>; e.g. <file> — <what>
        Judgement: <best practice / better code / cost, one line each>
    Set aside:
      <rule or tag> — weak|reject — <why, one line>

## After the user decides

For each approved proposal, apply exactly the approved text. For each one, approved or
not, append a line to this repo's log:

    <YYYY-MM-DD> <repo> consolidate <promoted|declined> <skill|correctness> "<rule>" — <lint|brief|convention|-> — <reason, under 15 words>
