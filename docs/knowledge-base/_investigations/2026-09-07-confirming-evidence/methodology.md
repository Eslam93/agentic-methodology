---
title: Why a Tier 3 change passed three design reviews, its own test suite, and its own mutation test while failing open on the case it existed to prevent, and the two method defects that caused it
status: verified
as_of: 2026-09-07
last_verified: 2026-09-07
verification_method: The failure and every defect below were reproduced in scratch repositories on the owner's Windows machine with git 2.52.0.windows.1 on 2026-09-07, and independently on Ubuntu with git 2.43; the commands and their output are quoted. The reverted implementation is preserved at branch reverted/seal-mid-operation, commit 3970d4e, so every claim here can be re-derived against it. The ten-angle independent review that found the defects is the /code-review run recorded in working/seal-refuses-mid-operation/brief.md
scope: The method by which the change was designed, evidenced, and tested. Not the correctness of any replacement, which does not exist, and not the sealed-baseline design as a whole, which D-17 still governs
confidence: High for the two method defects and for every reproduction, each of which is a command and its output. Medium for the generalisation to other work, since this is one incident and no second case has been examined
known_gaps: Only this one change was examined, so whether the same pattern produced earlier defects in this kit has not been checked. The proposed correction has not been applied to any skill and has therefore never been tried. Whether an independent review would have caught this earlier had it run against a prototype rather than a document was not tested
reverify_when: When a second instance of the same pattern is found or ruled out, and before this page is cited as evidence that the correction works, which it is not
---

**Bottom line: evidence gathered to confirm a design cannot falsify it, and a test suite derived
from a design inherits that design's blind spot.** Both happened here, in the same change, and
between them they let a Tier 3 control ship into review with 240 passing tests while failing open on
two of the most common cases it existed to catch.

This is a negative result about method, not about git. It is recorded because the change was
reviewed more heavily than anything else in this kit and the reviews did not help.

## What was built and what was wrong with it

`baseline.sh seal` records the approval-time state of a checkout as `git rev-parse HEAD`. That is
insufficient during a merge: two pending merges can share HEAD, the index, the working tree and the
porcelain status, and differ only in `MERGE_HEAD`, which decides the second parent of the commit they
produce. Reproduced:

```
after merging s1:  HEAD=80d1b843  idx=100644_2299c379_0  wt=10a098c572c8  st='M  f.txt'  MERGE_HEAD=936dcf9d
after merging s2:  HEAD=80d1b843  idx=100644_2299c379_0  wt=10a098c572c8  st='M  f.txt'  MERGE_HEAD=d3ee736e
```

The implementation refused to seal when any of seven marker files existed in the checkout's git dir:
`MERGE_HEAD`, `CHERRY_PICK_HEAD`, `REVERT_HEAD`, `rebase-merge`, `rebase-apply`, `BISECT_LOG`,
`sequencer`. It passed `verify.sh` at 23, `verify.sh --hooks` at 26, and `hooks.test.sh` at 240 cases
with 0 failed, on Windows and on Ubuntu.

It failed open on states that leave an unmerged index and no marker:

```
conflicted merge         markers:1  unmerged:3  seal_exit:1  refused
conflicted merge-squash  markers:0  unmerged:3  seal_exit:0  SEALED ANYWAY
conflicted stash pop     markers:0  unmerged:0  seal_exit:0  SEALED ANYWAY
```

A squash merge writes no `MERGE_HEAD` by design, because it has no second parent. Two pending squash
merges were then shown to seal to byte-identical approvals, which is the motivating experiment
reproduced against the fix meant to prevent it. Also missed: `cherry-pick -n`, `apply --3way`, and
the conflicted state left behind by `merge --quit` and `cherry-pick --quit`.

## Defect 1: the evidence gathered could only agree

Before agreeing the work, the builder probed git and reported the result as evidence. The question
asked was:

> for each of these six operations, what marker file does git leave?

Six operations were tried, six markers found, and the enumeration was recorded in the brief as
measured. The probe is structurally incapable of finding a state that is not already on the list. It
could only ever confirm.

The falsifying question was never asked:

> what states exist in which HEAD does not describe the tree?

That question is answered by `git ls-files -u`, which is non-empty for every missed case above and
for every marker case, and it would have replaced the design rather than the implementation. It costs
one command.

**The general form: a measurement that takes the design as its subject tests the design's
completeness against itself.** Evidence that cannot come back negative is not evidence, and this kit
already says so about checks (`verify.sh --canary` exists for exactly this reason). The same rule was
not applied to the measurement that preceded the design.

## Defect 2: the tests inherited the design's blind spot

Six fixtures were written, one per operation on the list. A suite generated from an enumeration
cannot discover that the enumeration is incomplete.

It was worse than that. Every fixture was conflicted by construction, so the suite could not
distinguish "detects the operation" from "detects a conflicted tree", which is the exact confusion at
the centre of the defect. An independent mutation pass found **six broken implementations that pass
all 33 new cases**, including:

| Mutation | Result |
|---|---|
| Refuse only when files are unmerged | 33/33 pass |
| Report `sequencer` for a pending revert | 33/33 pass |
| Check only the last checkout in shape B | 33/33 pass |
| Point every printed recovery command at a wrong directory | 33/33 pass |
| Leak the active-task pointer in shape B only | 33/33 pass |

The first of those would seal a merge whose conflicts are resolved and staged, which is the state the
whole change was argued from. No fixture builds it. Reproduced: after `git add` on the conflicted
file, porcelain reads `M  f.txt`, `git ls-files -u` is empty, and `MERGE_HEAD` is still present.

## Defect 3: the mutation test proved the wrong proposition

The builder ran one mutation, replacing the guard's condition with `false`, and reported that seal
then wrote a baseline mid-merge. That demonstrates the guard is load-bearing. It says nothing about
whether the guard is correct.

**Disabling a check tests that it runs. Changing its logic tests that it is right.** Only the second
is what the canary rule is asking for.

## Why three design reviews did not catch it

Three independent reviews read the design notes across three revisions and produced real corrections:
the git index as a third state, the commit range that misses dirty paths, path encoding, the
consumption-time currentness question. None of them touched this.

They could not. The design said "detect an in-progress git operation and refuse", and that sentence
is correct. The defect lives entirely in what "in-progress operation" resolves to when git is asked,
which no document contains. Reviewing prose harder does not reach it.

Two secondary observations, both weaker than the above and recorded as such:

- The reviews argued inside the enumeration once revision 1 put it on the page. Review 2 asked to
  broaden the list; review 3 asked about naming and byte rendering. No round asked whether an
  enumeration was the right instrument. **Opinion, not measured:** a list on a page redirects review
  toward completeness and away from method.
- Successive rounds converged, and the builder read convergence as confidence. The standing orders
  already say two models agreeing is necessary and not sufficient; three agreeing is the same
  sentence.

## The rule the kit already had and did not apply

The design notes for the deferred retrieval work say, in the builder's own words and endorsed by all
three reviewers, that it must not be built because it was *designed on paper and never once run
against a real task*. That rule was applied to the item that was deferred and not to the item that
was built.

## What caught it

The Tier 3 contract: a change touching a control cannot finish without a completed independent review
or an owner's explicit waiver, and `baseline.sh check` exits non-zero until one is recorded. The
review ran, found the defects, and the work was reverted before anything was pushed. This is the only
control in the sequence that behaved as designed.

The seal also held against its author: the brief records a known gap that is false (it says a
`sequencer` state could not be produced; it takes one command sequence), and because `brief_sha256`
covers the body it could not be quietly corrected.

## The proposed correction, which has not been tried

One line, for `/work` Understand:

> State the question that would prove your design wrong, and run it before you agree. Evidence that
> can only confirm is not evidence.

**Status: proposed. Not applied to any skill, and therefore never exercised.** It is recorded here so
that a later session can either apply it deliberately or reject it, rather than rediscovering the
incident.

## What was not checked

Whether earlier work in this kit contains the same pattern. Whether an independent review run against
a prototype rather than a document would have caught it. Whether the proposed correction changes any
outcome, since it has not been used. The replacement implementation, which does not exist.
