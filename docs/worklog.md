# Worklog

> Appended **every session** (newest at top). One entry per working session.
> Format: date · what shipped (with tiers) · merge verdicts · what's next.

<!-- Copy this block to the top each session:

## <YYYY-MM-DD> · <session focus>
- **Shipped:** <task-id (Tier n) — one line>; …
- **Merges:** <task-id PASS · 🔴0 🟡n ⚪n>; …   (Tier-1 batched)
- **Decisions/ADRs:** <ADR-NNNN …>
- **Next:** <what's queued / blocked>
- **Hours:** <n>

-->

## 2026-09-04 · baseline commit + drift fixes
- **Shipped:** v1.4 + v1.5 committed as `40ff017`. Drift fixes (Tier 1): DECISIONS §2 / §6 / §8 / ledger #2 aligned with the later decisions; DoD Tier-2 row now reads 🔴 = 0 (CONCERNS with filed follow-ups merges, matching the gate + schema); design-note lite-lane line uses the blast-radius receipt, not "high confidence". `AGENTS.md` rebuilt.
- **Merges:** n/a — docs, Tier 1 · `lint-methodology.sh` 0 errors.
- **Decisions/ADRs:** DECISIONS v1.5.1 note.
- **Next:** the v2 simplification pass (owner-led): delete a lot, simplify, change approaches.

## 2026-07-11 (later) · methodology upgrades from the Elm field review
- **Shipped:** ADR-0002 (data posture demo/production + promotion ledger + gated flip) · ADR-0003 (CI-gated guard + verify-the-verifier canary + context-rot cross-ref sweep). New: `docs/promotion-ledger.md`, `.github/workflows/methodology-guard.yml`, `docs/adr/ADR-0002-*`, `docs/adr/ADR-0003-*`. Modified: `docs/constitution/definition-of-done.md` (posture + verify-the-verifier), `docs/phase-0.md`, `docs/minimal-core.md`, `README.md`, `DECISIONS.md` (v1.5). `AGENTS.md` rebuilt from the spine.
- **Source:** the governed-insight (Elm) 3.5-week adoption review — scattered demo security-debt with no ledger, a by-convention guard that failed open on main, and repeated local false-greens.
- **Next:** owner to review/commit COMMS-1 + these upgrades; Elm repo-side fixes handed off as prompts (false-greens, docs/CI hygiene, RESUME trim).

## 2026-07-11 · COMMS-1 communication layer
- **Shipped:** COMMS-1 (Tier 2 · lite) — Claude-only communication layer: always-on `plain-technical` output style (on by adoption, toggle via `/output-style`) + six one-shot mode skills (`/explain /brief /architect /product /peer /normal`). Docs: `docs/communication.md` + ADR-0001. Wired into README, phase-0 (provision add-on), minimal-core (hardening menu). Kept out of `AGENTS.md` and `THE-FLOW`.
- **Merges:** COMMS-1 PASS · 🔴 0 · 🟡 1 (optional lint soft-check for the output style, deferred per minimal-core) · ⚪ 0. `lint-methodology.sh`: 0 errors, 1 pre-existing warning (template placeholders).
- **Decisions/ADRs:** ADR-0001 (communication layer, kept out of the constitution). DECISIONS.md v1.4.
- **Next:** owner to review/commit; optional — port one-shot semantics back to the standalone communication-modes pack.

## <YYYY-MM-DD> · example entry
- **Shipped:** AUTH-12 (Tier 3) — account lockout after 5 failed logins.
- **Merges:** AUTH-12 PASS · 🔴 0 · 🟡 1 (filed #44) · ⚪ 2.
- **Decisions/ADRs:** ADR-0007 (lockout window = 15 min).
- **Next:** AUTH-13 (session expiry) — blocked on a product call.
- **Hours:** 3.
