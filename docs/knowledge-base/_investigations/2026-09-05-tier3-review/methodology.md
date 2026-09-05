---
title: What the Tier 3 review contract requires, which part of it a check can decide and which part only the people can, and the runs that show reviewed, waived, and neither
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: Thirteen cases added to hooks.test.sh and run on the owner's Windows machine on 2026-09-05, once each rather than once per shell, because baseline.sh is a bash tool with no PowerShell twin; the hook cases around them still run in both. A scratch repository produced the three outcomes by hand and the tool's output was captured. The wording changes were read against the tree they describe
scope: The change decided as D-19: the tier field, the review record, the hand-back check, and the text in /work, the standing orders, and the README. Not the review routes themselves, which are unchanged, and not any new reviewer
confidence: High for what the tool does, which is exercised by the suite, and for the two defects an independent review found and this page records. The contract itself is instruction-level in the one place that matters most, and that limit is stated below rather than softened
known_gaps: Nothing verifies that a recorded review actually ran; the record is the builder's own statement. The review lines sit outside seal_sha256 on purpose, because they are written later in the task, so a hand-written review record after sealing is still not detectable. The tier line is no longer in that position: Task Integrity 1.1 brought it inside the seal, so the one-line edit from tier 3 to tier 2 now blocks. No case has been run through a real Tier 3 task end to end in a live session
reverify_when: On any change to baseline.sh or to the review menu in /work, and if a waiver is ever recorded on a real task, to see whether the wording held
---

## The gap this closes

Tier 3 covers the work whose consequences are worst when it is wrong: authentication and
authorization, payments, secrets, migrations, public contracts, security controls, cross-module
architecture. Before this change, Tier 3 meant the review menu defaulted to all three routes, and
the owner could decline every one of them. A task could therefore finish with no independent
judgment and nothing on the record saying that anyone had decided to go without it. The tier
promised more than the methodology delivered.

The distinction the change buys is not "more review". It is that a later reader can tell these two
apart:

```
tier 3, reviewed
tier 3, not reviewed, because the owner said to go without one
```

## The contract

> A Tier 3 task is complete when one independent review has finished, or when the owner has waived
> it in their own words. Nothing else counts.

Offered, chosen, started, and failed are none of those, and reaching the hand-back is not a waiver.
Tier 1 and Tier 2 are untouched: neither requires an independent review, and this change does not
give them one.

**Which routes are independent.** The two the kit already has: the fresh-context review, where a
context that never saw the reasoning does the judging, and the Codex cold pass. The local run with
`/test-guide` is not one, because the builder runs it, and the tool refuses to accept it as one. No
new route, no second reviewer, no quorum, no rounds.

## The record

Two fields in the front matter the seal already writes, so there is one format and no second state
file:

```yaml
tier: 3                        # written by seal, which now requires it

review_status: completed       # written by review
review_route: codex-relay
review_evidence: <the verdict line, or what the reviewer returned>
review_at: <UTC>
```

or

```yaml
review_status: waived-by-owner
review_waiver: <the owner's own words>
review_at: <UTC>
```

Written once. `review` refuses to overwrite an existing record, for the same reason `seal` refuses
to re-seal: a record that can be replaced is not a record. `completed` refuses without a result,
because a review that produced nothing did not complete. `waived` refuses without the owner's
words, because a waiver nobody said is not a waiver.

## What is decided by a check, and what is not

**Mechanically decided (layer c).** `baseline.sh check`, which `/work` already runs as the first
step of the hand-back, exits non-zero on a Tier 3 brief carrying neither record, and prints the two
commands that resolve it. It reports the tier and the outcome for every task, so a Tier 1 or Tier 2
brief passes and says why. The refusals above are the tool's, not the model's.

**Instruction-level, and this is the load-bearing limit.** Nothing can tell whether a review that
was recorded actually ran, or whether the words in a waiver were ever said. The same builder that
would skip a review can write either record. Nor is the tier itself protected: `brief_sha256`
covers the body of the brief, not its front matter, so one hand-edit turning `tier: 3` into
`tier: 2` makes `check` report that no review is required, and that is a cheaper escape than
forging a review record. Both were reproduced by the verifier of this change.

What the change buys is that skipping is no longer the quiet default: it takes a deliberate,
dated, attributable line in the agreed brief, and the hand-back check refuses to pass without
one. That is the honest description, and it is the one the README and the standing orders carry.

**The tier edit was closed the same day** by Task Integrity 1.1, which added `seal_sha256` over the
approval fields, `tier` among them: changing `tier: 3` to `tier: 2` after sealing now blocks the
turn and fails `check`. It did not need a new meaning for `brief_sha256`, which is why it was
cheaper than the fix considered here. The review lines stay outside that digest by design, because
they are written later in the task, so forging a review record by hand remains undetectable and
remains the load-bearing limit. Evidence:
`../2026-09-05-task-baseline/methodology.md`.

A stronger mechanism was considered and rejected in the same breath: a Stop hook that blocked every
turn of a Tier 3 task until a review was recorded would interrupt the build for a condition that
only matters at the end, which is the thing the enforcement budget exists to avoid.

## The suite

Thirteen cases: **120 passed, 0 failed**, against 107 before this change. These thirteen run
once, not once per shell, because `baseline.sh` is a bash tool with no PowerShell twin; the hook
cases around them still run in both shells and still pass.

| Case | Expected | Result |
|---|---|---|
| seal with no tier | refused, since the contract cannot be checked without one | passes |
| a brief that arrives already carrying a review record | the seal strips it; only `review` writes one | passes |
| a brief with no tier line | `check` fails rather than passing with a shrug | passes |
| a review route the kit does not treat as independent | refused by name | passes |
| Tier 3, neither review nor waiver | `check` exits non-zero and names the two ways out | passes |
| review completed with no result | refused: offered and started are not completed | passes |
| the local run offered as the review | refused, with the reason | passes |
| waiver with no owner words | refused | passes |
| Tier 3 with a completed review | `check` passes and names the route | passes |
| a second review record | refused; the record does not move | passes |
| Tier 3 waived by the owner | `check` passes and says WAIVED, not reviewed | passes |
| Tier 2 with no review | passes, and says none is required | passes |
| Tier 1 with no review | passes | passes |

The three outcomes, from the scratch repository, in the tool's own words:

```
TIER 3 CONTRACT INCOMPLETE: no independent review and no owner waiver is recorded.
tier 3: independent review completed via codex-relay
tier 3: independent review WAIVED by the owner: owner: skip review, I have read it myself
```

Cases 5 and 6 of the owner's list, a review that was offered but not run and one that started and
failed, are covered by the same refusal: neither produces a result to record, and `completed`
without a result is refused. Nothing distinguishes a failed review from an unstarted one except the
absence of a verdict, which is the right test. What the tool checks is that a result was given, not
that the result is true; the same holds for the words in a waiver.

## What an independent review of this change found

This change is itself Tier 3, so it was reviewed by a fresh context that had not seen the
reasoning. It returned FAIL with two defects that defeated the requirement, both since fixed and
both now covered by a case:

1. **A brief could arrive at the agreement already carrying its own review record.** The seal
   rewrote its own keys and kept everything else, so a `review_status: waived-by-owner` line
   written into the brief before sealing survived and satisfied the contract, with nobody asked and
   no timestamp. Worse, it then locked out the real record, because a review record does not move.
   That is precisely the silent conversion of "no review" into "waived" the change exists to
   prevent. The seal now strips every `review_` key, so only `review` can write one.
2. **A brief with no tier line passed the check.** The branch printed that the tier was not
   recorded and then exited zero, so any brief sealed before the tier existed, or one with the line
   removed, skipped the only check that asks about review. It now fails and says how to fix it.

Three smaller findings were also taken: the route rule was a deny-list of three names, so any
unrecognised word was accepted as a review route, and is now an allow-list of the two the kit
treats as independent; this page claimed the tool cases ran in both shells, which they do not; and
the standing orders still showed `baseline.sh seal` without its new tier argument.

## What this change did not touch

The task baseline and the active-task pointer are unchanged; the suite's coverage of both still
passes, including committed weakening, staged renames, two-session isolation, and the relay-brief
regression. The review menu, its defaults, and the owner's freedom to choose the route are as D-06
left them. No mandatory route, no quorum, no scoring, no retries, no orchestration, no merge gate.
