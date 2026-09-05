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

## Root cause A · nothing in the harness has run yet

Closes with Phases 2 to 4 of the plan. Cost: the build itself.

| Unknown | Page it limits |
|---|---|
| Do `PreToolUse` and `Stop` hooks fire on the desktop-app surface on Windows? The source installation measured them on a CLI-era setup in 2026-08 | `start-here.md`, fact 5 |
| Does a rule with a `paths:` block stay out of context until a matching file is touched, on the current Claude Code version? Field reports of silent failure exist | `decisions.md`, D-03 |
| Does `/goal <condition>` behave as documented, a separate evaluator re-checking after every turn? Read in the docs, never run | `decisions.md`, D-04 |
| Does `verify.sh` fail when it should? It is trusted only after the canary and one deliberate break | the plan's Phase 4 |

## Root cause B · one person, one machine

Closes only with a second adopter or a second machine. Cost: unknown; not in the owner's hands alone.

| Unknown | Page it limits |
|---|---|
| Whether any skill helps, by comparison. The source installation recorded the same limit: no skill in it had been shown by comparison to help | every skill |
| Whether the install works on macOS or Linux. Every measurement so far is Windows, Git Bash and PowerShell | `decisions.md`, D-03 |
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
