# Design Note — COMMS-1: Communication layer for the methodology

## A · Pickup
- **Task / link:** Add a switchable, repo-scoped communication layer that turns on when the methodology is adopted.
- **Outcome:** build.
- **Tier:** 2 (Lite lane)   ·   **Mode:** Conductor
- **Tier-3 trigger hit?** none (docs + Claude config; no auth/authz/payments/secrets/data-migration/public-API/security-control/cross-module-arch)
- **Intent certainty:** crisp (owner settled the forks) — no blocking pre-build gate; direction reconciled at merge via the direction-delta.
- **Blast-radius receipt:** files changed ~14 · public API? no · data/migration? no · auth/security? no · observability? no · user-facing? yes (the owner's reading experience). → consistent with T2-lite.

## B · Plan
- **Per-file plan:**
  - `.claude/output-styles/plain-technical.md` — new; always-on baseline (`keep-coding-instructions: true`).
  - `.claude/skills/{explain,brief,architect,product,peer,normal}/SKILL.md` — new; one-shot modes (`disable-model-invocation: true`).
  - `docs/communication.md` — new; the layer's doc.
  - `docs/adr/ADR-0001-communication-layer.md` — new; the decision + the out-of-constitution boundary.
  - `README.md` — modify; "What's here" row + wiring-up step.
  - `docs/phase-0.md` — modify; optional provisioning add-on (step 2).
  - `docs/minimal-core.md` — modify; hardening-menu row.
  - `DECISIONS.md` — modify; v1.4 change-log entry.
- **Open decisions (resolved with owner):** default state = on-by-adoption (opt-out); ships = baseline + all six modes; modes = one-shot (single response, then baseline resumes); `/normal` = repurposed to a one-shot default-voice escape hatch.
- **Acceptance criteria (EARS):**
  - THE SYSTEM SHALL keep the communication layer on the Claude output-style + skills surface, with no communication instructions in `AGENTS.md`.
  - WHEN a repo adopts the methodology and sets `outputStyle`, THE SYSTEM SHALL apply the plain-technical voice to every builder response in that repo by default.
  - WHEN the owner runs `/output-style` and selects Default, THE SYSTEM SHALL disable the voice for that repo without deleting the assets.
  - WHILE the baseline is active, THE SYSTEM SHALL retain Claude Code's built-in engineering behavior (`keep-coding-instructions: true`).
  - WHEN a mode command is invoked, THE SYSTEM SHALL apply it to the next single response only, then revert to the baseline.
  - THE SYSTEM SHALL provide six modes that do not fire unless explicitly invoked.
  - IF the layer is added, THEN THE SYSTEM SHALL add zero steps to `THE-FLOW`'s per-task loop.
- **Test-map:**
  - *Existing, must stay green:* `sh lint-methodology.sh` (AGENTS.md fresh, no mojibake in tracked files, schema valid).
  - *New, per criterion:* grep `AGENTS.md` proves absence of voice rules · grep each skill for `disable-model-invocation` · grep README / phase-0 / minimal-core reference `docs/communication.md` · manual: `/output-style` lists "Plain technical", on leads-with-conclusion, off returns to default, a mode shapes one response then reverts.
- **Uncertainty type:** product-value (resolved with owner) · **Confidence:** high (color only).

## C · Plan consensus
- **Lane:** lite (non-trigger T2). Cold-criteria derived from the owner's raw ask; one divergence surfaced and resolved: "adapts the communication modes" means the *baseline* auto-activates, while the six modes stay manual one-shot overrides. Owner confirmed.
- **Verdict:** PASS (owner-ratified plan).   ·   Rounds: 0/3 (crisp; full design relay skipped per lite eligibility).

## D · Build & verify (the Machine plane)
- **Shipped:** the per-file plan above.
- **Checks:** `sh lint-methodology.sh` — result recorded in the worklog for this session.

## E · Code review + merge
- **Direction delta (owner signs, separate from 🔴=0):** delivers exactly the agreed layer — an always-on, per-repo, opt-out plain voice plus six one-shot modes, Claude-only, kept out of the constitution and the per-task flow. No scope drift.
- **Merge digest:** presented to the owner in-session (verdict + 🔴/🟡/⚪).
- **ADR:** `docs/adr/ADR-0001-communication-layer.md`.

<!-- Follow-ups (🟡): optionally extend lint-methodology.sh with a soft check that a present output style has keep-coding-instructions: true. Deferred per minimal-core (leave hardening off for routine work). -->
