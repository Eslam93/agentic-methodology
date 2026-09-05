---
title: What is not known about this kit, by root cause, ordered by leverage
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: Built from the known_gaps header of every page in this base and from the verification list in the v2 plan
scope: The kit and this repository. Not the private installations
confidence: High that these are gaps. Medium on the cost estimates, which are guesses
known_gaps: The most likely place for unknown unknowns is whatever has not been touched at all, which is a shape-B install with this kit and any machine other than the owner's
reverify_when: After each phase of the v2 plan
---

## Root cause A · parts of the harness had not run in a fresh session, closed 2026-09-05

Closed by Phase 4 on 2026-09-05 and by a session started after the install on the same day, in
which the owner typed `/compact`, `/goal`, and `/board`; see
`../_investigations/2026-09-05-v2-rewrite/acceptance.md`. The table stays as the record of how
each was closed, all on one machine and one Claude Code version.

| Unknown | State on 2026-09-05 | Page it limits |
|---|---|---|
| Do the always-loaded rules load in a fresh session, and answer a question without a file read? | verified in the weak form: in a session started after the install, the rules were in context before the first tool call and the standing orders were answered from them; the owner's question-first protocol was not run | closed |
| Does a rule with a `paths:` block stay out of context until a matching file is touched? Field reports of silent failure exist | verified: absent through a whole turn of shell reads and a shell edit under `docs/knowledge-base/`, present the moment a page there was opened with the `Read` tool. The silent failure is real for a shell-only session; `working-here.md` carries the trap | closed |
| Does `/goal <condition>` behave as documented, a separate evaluator re-checking after every turn? | verified for one cycle: with the tree failing one check, the evaluator blocked the stop and quoted the failing check; after the fix `verify.sh` passed. Not observed: whether it runs the command or judges the transcript, and any cycle beyond two turns | closed |
| Does `/board` told to close an item propose and stop without writing? | verified: on issue 1 of this repository the turn ended with a proposal and a question, and `gh issue list --state all` afterwards showed the item unchanged; the close was applied only after the owner's yes | closed |
| Does the `resume-brief` hook put the brief back after a real compaction? | verified: on the owner's `/compact` the hook printed the status file and the brief verbatim into the next turn, and the brief was named from that output without a file read | closed |
| Do `PreToolUse` hooks fire on the desktop app? | verified live: the secret guard blocked a real write and allowed the false-positive case | closed |
| Does the `Stop` hook fire live? | verified: weakening a committed test and ending the turn blocked the stop with the file named and the assertion count; the loop guard held on the second attempt | closed |
| Does `verify.sh` fail when it should? | verified: the canary fails, a removed hook fails the pair check with the file named, 200 padding lines fail the budget | closed |

## Root cause B · one person, one machine

Closes only with a second adopter or a second machine. Cost: unknown; not in the owner's hands alone.

| Unknown | Page it limits |
|---|---|
| Whether any skill helps, by comparison. The source installation recorded the same limit: no skill in it had been shown by comparison to help | every skill |
| Whether the install works on macOS. Linux is partly closed: CI on `ubuntu-latest` passed `verify.sh`, the canary, and the bash hook cases on 2026-09-05; the installer itself has not run there | `decisions.md`, D-03 |
| Whether a shape-B workspace installs cleanly with this kit. Shape B was derived from a shape-C installation and never run as B | `decisions.md`, D-02 |

## Root cause C · sources not independently re-verified

Closes with an afternoon of reading. Cost: low, but it was deferred in v1 and is deferred again.

| Unknown | Page it limits |
|---|---|
| The research citations behind the v1 thesis were re-checked by two reviewers in 2026-06 and never by the owner | `_readings/evidence-base.md` |
| The harness-standards facts were measured on another estate in 2026-08 and not re-measured here | `_readings/harness-standards-2026-08.md` |

## Root cause D · not surveyed

| Unknown | Page it limits |
|---|---|
| The standalone communication-modes pack still carries persistent-mode wording. Whether it should be deleted or aligned was never decided | `99-pending.md` |
| The project memories on the owner's other repositories, 84 notes on one of them, were never promoted or pruned | `99-pending.md` |
