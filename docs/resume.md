# RESUME — start here

> The always-current **handoff** pointer (distinct from the append-only `worklog.md`). Kept fresh by
> **Step 7 close-out** after every merge, so a fresh / post-compact session resumes cleanly without
> re-deriving anything. One screen — if it grows, trim.

## Current state
v1.4 + v1.5 are committed (`40ff017`). Drift fixes are applied in the working tree and lint-green, **uncommitted**: DECISIONS §2 / §6 / §8 / ledger #2, the DoD Tier-2 row (🔴 = 0), the design-note lite-lane line, DECISIONS v1.5.1 note, `AGENTS.md` rebuilt.

## Next task
The **v2 simplification pass** (owner-led): delete a lot, simplify, change approaches. Candidate list from the 2026-09-04 read-through, not yet acted on: `/clarify` and the relay command are referenced but not shipped · `lint-methodology.sh` re-implements the build instead of reusing it · the evidence calculus is restated in ~5 places · README table omits minimal-core / escape-log / the schema · pin markdown to LF in `.gitattributes`.

## Open threads / watch-outs
- The standalone communication-modes pack still uses persistent (not one-shot) mode wording — intentional divergence for now.
- Elm repo-side fixes were handed to the working session as prompts (false-greens, docs/CI hygiene, RESUME trim); not applied here (read-only on Elm).
- Deferred 🟡: an optional `lint-methodology.sh` soft-check that a present output style has `keep-coding-instructions: true`.

## How to resume
`git log --oneline -3` (expect `40ff017` or later) · `git status` shows the uncommitted drift fixes · `sh build-constitution.sh && sh lint-methodology.sh` must be green · then continue the simplification pass from the candidate list above.

## Prep-for-compact checklist (run at Step 7 before a compact)
- [ ] worklog appended
- [ ] this file current (state · next · threads · resume)
- [ ] board moved · memory notes written
- [ ] `AGENTS.md` fresh (lint green)
