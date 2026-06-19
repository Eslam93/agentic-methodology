# Design Note — <TASK-ID>: <title>

> **One per task (Tier 2/3).** Tier 1 needs no design note — a worklog line suffices.
> A *living* doc, filled across the task's life: **A** pickup → **B** plan → **C** plan consensus → **D** build → **E** review + merge.
> Sections marked **(T3)** apply to Critical tasks only.

## A · Pickup
- **Task / link:** <issue or board item>
- **Outcome:** build | ask/refine | **no-op** (already satisfied / duplicate / obsolete — confirm the change is needed *before* planning)
- **Tier:** 1 / 2 / 3   ·   **Mode:** Conductor (T3) · Orchestrator (T1) · builder's call (T2)
- **Tier-3 trigger hit?** none | auth | authz | payments | secrets | data-migration | public-API/contract | security-control | cross-module-arch
  *(hard floor — builder may tier **up**, never **down** a trigger-area change)*
- **Intent certainty:** crisp | uncertain | fuzzy
- **Clarifications** *(from `/clarify` — demand-driven; empty if crisp):*
  - Q: <…> → A: <…>
- **Direction pre-check** *(required iff **Tier-3 OR fuzzy**, resolved before build):* <owner approval ref | async note ref | N/A>
- **Blast-radius receipt** *(heuristic tier check — if any answer contradicts the proposed tier, AUTO-ESCALATE):*
  files changed <n> · public API changed? <y/n> · data shape / migration? <y/n> · auth/security touched? <y/n> · observability changed? <y/n> · user-facing? <y/n>
- **(T3) Pre-mortem:** assume this shipped and caused an incident — top 3 likely causes, each with the test / monitor / rollback that would catch it.

## B · Plan
- **Per-file plan:**
  - `path/to/file` — <what changes & why>
- **Open decisions** *(product AND technical — each goes to the plan relay):*
  1. <decision> — options: <A / B> — **recommendation:** <X, because …>
- **Acceptance criteria (EARS):**
  - THE SYSTEM SHALL <always-true invariant>.  *(ubiquitous — the always-on properties trigger-based forms miss)*
  - WHEN <trigger>, THE SYSTEM SHALL <response>.
  - WHILE <state>, THE SYSTEM SHALL <response>.
  - IF <error condition>, THEN THE SYSTEM SHALL <response>.
- **Test-map** *(the "tests that prove it"):*
  - *Existing — must stay green:* `test_x::case_a`, `test_y::case_b`
  - *New — one per criterion above:* <test name → which criterion it proves>
- **Uncertainty type:** product-value | UX | data-contract | architecture | security | testability | dependency/env | unknown-code-area · **Confidence (1–10):** <n> *(optional color)*  *(direction gate fires when type ∈ {product-value, security, data-contract} **or** `/clarify` is unresolved — the **type + clarify** are the gate, never the gameable number.)*

## C · Plan consensus (relay)
- **Lane:** full reconcile | **lite** (non-trigger T2, high confidence, clean `/clarify` → single cold-criteria pass + code relay only)
- **Cold-derived criteria diff:** <reviewer independently derives acceptance criteria from the task statement, then diffs vs the builder's EARS — list divergences; a divergence is a DIRECTION flag>
- **Verdict:** PASS | CONCERNS | FAIL   ·   🔴 <n>  🟡 <n>  ⚪ <n>
- **Reconciliation:** <folded must-fixes; pushback is evidence-only — **independent (reviewer recompute / un-authored spec / failing check) outweighs builder-produced ("my test passes" is weak alone); a citation never settles alone**; an unsubstantiated 🔴 → 🟡 pending; deadlocks (or fast consensus on critical-path) escalated>
- **Rounds:** <n>/3

## D · Build & verify (the Machine plane)
- **Shipped:** <file-level summary>
- **Checks:** lint <✓> · full suite vs **real stack** <✓> · CI <✓/link> · coverage <✓>
- **Mutation (diff-scoped, fast unit layer only):** mutate changed *logic* lines, run the test-map — score <n>% (**T3: required ≥ 80%** unless ADR-waived; T2: when logic is non-trivial; *degrade* to manual fault-injection if no tooling; list + address survivors)
- **(T3)** golden answers **human-ratified** for critical logic <✓> · rollback plan <link>  *(property/fuzz/metamorphic = means to raise the mutation score)*
  - **Golden-answer custody (T3 critical logic):** scenario · expected value · ratified-by · date · *why* it's correct · source of truth

## E · Code review + merge
- **Cold pass → context pass verdict:** PASS | CONCERNS | FAIL   ·   🔴 <n>  🟡 <n>  ⚪ <n>
- **Direction delta (owner signs, separate from 🔴=0):** what this does *in product terms* + how it differs from the task as written <…>
- **Merge digest (owner overview):** verdict; **🔴 = 0**; 🟡 → follow-ups <#…>; ⚪ <n>
- **(T3)** ADR: <link to docs/adr/…>

<!--
Reminders baked into this template:
- Two dials are builder-proposed at pickup, fail-safe (round UP when unsure).
- AI⇄AI consensus is necessary, not sufficient — D (the Machine) must pass; CI is the only neutral integration check.
- Code review = cold correctness pass (diff only, "recompute before judging") THEN context pass.
- Merge allowed iff 🔴 = 0.
-->
