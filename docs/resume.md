# RESUME — start here

> The always-current **handoff** pointer (distinct from the append-only `worklog.md`). Kept fresh by
> **Step 7 close-out** after every merge, so a fresh / post-compact session resumes cleanly without
> re-deriving anything. One screen — if it grows, trim.

## Current state
Two methodology changes built and lint-green, uncommitted in the working tree:
- **COMMS-1** (communication layer): `.claude/output-styles/plain-technical.md`, `.claude/skills/{explain,brief,architect,product,peer,normal}/`, `docs/communication.md`, ADR-0001, design note.
- **v1.5 upgrades** (from the Elm field review): ADR-0002 (data posture + `docs/promotion-ledger.md` + gated flip), ADR-0003 (`.github/workflows/methodology-guard.yml` CI guard + verify-the-verifier canary), DoD posture + canary edits, phase-0 + minimal-core wiring, DECISIONS v1.5. `AGENTS.md` rebuilt.

## Next task
Awaiting direction. Owner to review and commit COMMS-1 + the v1.5 upgrades. Optional follow-up: port the one-shot mode semantics back to the standalone communication-modes pack.

## Open threads / watch-outs
- The standalone communication-modes pack still uses persistent (not one-shot) mode wording — intentional divergence for now.
- Elm repo-side fixes were handed to the working session as prompts (false-greens, docs/CI hygiene, RESUME trim); not applied here (read-only on Elm).
- Deferred 🟡: an optional `lint-methodology.sh` soft-check that a present output style has `keep-coding-instructions: true`.

## How to resume
Review the diff in `D:\SourceCode\methodology` (`git status`), read the ADRs (0001/0002/0003) + `docs/design-notes/COMMS-1-communication-layer.md`, run `sh build-constitution.sh && sh lint-methodology.sh` to confirm green, then commit if approved.

## Prep-for-compact checklist (run at Step 7 before a compact)
- [ ] worklog appended
- [ ] this file current (state · next · threads · resume)
- [ ] board moved · memory notes written
- [ ] `AGENTS.md` fresh (lint green)
