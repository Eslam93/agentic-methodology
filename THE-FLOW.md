# THE FLOW — the per-task SOP

Run every **Tier 2/3** unit of work (issue / ticket) by its lane — pick the lane ([lane card](docs/lane-card.md)) and run that lane's required subset. **Tier 1**
fast-tracks (see the dials). Before any of this, the project must be past **[Phase 0](docs/phase-0.md)**
and the task must pass the **[Definition of Ready](docs/definition-of-ready.md)**.

> **Three planes + one human job.**
> **Builder** (Claude) drives · **Reviewer** (independent Codex) pressure-tests *judgment* — its real
> strength is **design + process/direction audit, not catching correctness bugs** (that's the correlated
> blind spot) · **the Machine** (deterministic checks + CI) carries *facts*. **The human owns _direction_, risk acceptance, and domain truth** —
> not routine line-by-line correctness. AI⇄AI consensus is **necessary, not sufficient** (it's ~2 *correlated* votes,
> not two independent proofs — so the Machine carries correctness).
>
> **Human gates:** a **direction pre-check before build** *only when Tier-3 or Fuzzy*, and the
> **merge** — approved from an executive **severity digest**, never line-by-line.

## The two dials — set at pickup, builder-proposed, fail-safe (round *up* when unsure)

- **Risk × reversibility → Tier 1/2/3** (sets correctness ceremony *and* the mode: T3 ⇒ Conductor,
  T1 ⇒ Orchestrator, T2 ⇒ builder's call). The **Tier-3 trigger set is a hard floor** —
  `{auth, authz, payments, secrets, data-migration, public-API/contract, security-control,
  cross-module-arch}` auto-escalates; the builder may tier **up**, never a trigger-area change **down**.
  The reviewer **audits the tier** every relay.
- **Intent certainty → crisp / uncertain / fuzzy** (sets direction checking). **Crisp** → no pre-build gate; direction is reconciled at merge via the direction-delta (not "none"). **Uncertain** → an async, non-blocking "here's my read" note. **Fuzzy** → **blocking human
  approval before build.**

---

> **Core vs hardening:** run the irreducible *core* on every task; switch on *hardening* by tier / maturity — never everywhere. See [`docs/minimal-core.md`](docs/minimal-core.md).

## The six steps

1. **Read & understand everything.** The constitution (`AGENTS.md`), the architecture map, prior
   decisions (ADRs), the task's design note, and the exact code it builds on. **Verify, don't assume.**
   First confirm the change is actually needed — **valid outcomes are build · ask/refine · no-op**
   (already satisfied / duplicate / obsolete). Unnecessary AI action is its own defect class.

2. **Draft the plan + ALL open decisions.** Open a **[design note](docs/design-notes/_TEMPLATE.md)**.
   Run **`/clarify`** (demand-driven — invisible when crisp); record answers. Write the per-file plan,
   list every open question (**product AND technical**, each with options + your recommendation), the
   **acceptance criteria in EARS**, and the **test-map** (existing tests that must stay green + a new
   test per criterion). Label the **uncertainty type** (product-value / security / data-contract / architecture / …) — *that* + the clarify questions route the direction gate; the 1–10 confidence number is optional color, **not** a gate (it's gameable).

3. **Reconcile the plan with the reviewer to MUTUAL agreement** (via `codex-relay`), and **run the
   direction pre-check if Tier-3 or Fuzzy.** First, the reviewer **derives acceptance criteria cold**
   from the task statement and diffs them against the builder's EARS — a divergence is a *direction* flag
   (cold-diff applied to requirements, where misunderstanding is born). Then send the plan + every
   decision. Fold clearly-correct must-fixes, but **push back only with evidence**, weighted by
   independence: **the reviewer's own recompute / an un-authored spec line / a failing check outweighs
   builder-produced evidence** ("my test passes" is weak alone), and **a citation never settles a finding
   on its own** (it goes side-by-side). Evidence is symmetric — an unsubstantiated reviewer 🔴 downgrades
   to 🟡 pending, just as a bare builder rebuttal is invalid. The reviewer judges **side-by-side**, not in
   a wear-down chat. Iterate — **cap ~3 rounds**; on deadlock *or suspiciously fast agreement on a
   critical-path change*, escalate to the owner.
   **Lite lane (routine non-trigger T2):** skip the **full multi-round design relay** — Machine + a single
   cold-criteria pass + the direction-delta is enough. Eligibility is gated by the **blast-radius receipt**
   (not the confidence number). The full design relay is reserved for Tier-3 / architecture-touching / fuzzy.

4. **Implement — NO human plan gate.** Once builder + reviewer agree (and direction is cleared where
   required): **conductor/orchestrator per tier**, **branch per task**, and verification driven by the
   **test-map** (not recited TDD). Then the **Machine plane**: lint + the **full suite against the real
   stack** (not mocks) + CI green; **diff-scoped mutation testing** — mutate the changed lines, run the
   test-map; surviving mutants mean the tests don't really test it (**T3: score ≥ threshold required**;
   T2: recommended on non-trivial logic; property/fuzz/metamorphic are *means* to raise the score);
   **(T3)** **human-ratified golden answers** for critical logic. A brief "build started" note is courteous.

5. **Independent code-review relay on the diff.** **Cold correctness pass first** — give the reviewer the
   diff + how-to-verify + *"independently recompute before judging,"* and **withhold your reasoning and
   claimed results.** Then a **context pass** (judgment calls, results) for the design discussion.
   Reconcile with the same **evidence calculus** (independent > builder-produced · citations never settle
   alone · unsubstantiated 🔴 → 🟡 pending · side-by-side) → re-verify (lint + tests + CI green).

6. **Owner's only gate — approve the merge from the SEVERITY DIGEST, not line-by-line.** Present the owner
   (a) an executive summary of what shipped, (b) a **Direction delta** — what shipped *in product terms*
   vs the task as written, signed **separately from 🔴 = 0** (a perfectly-built *wrong* feature has an
   empty 🔴 bucket), and (c) the digest: **🔴 / 🟡 / ⚪**, verdict **PASS/CONCERNS/FAIL/WAIVED**. **Merge
   only when 🔴 = 0.** Emit it machine-readable (a hook/CI can enforce 🔴-empty) and human-readable.
   **Never self-merge unless told.** On merge: close the task, move the board to **Done**, append the
   worklog. **Tier-1 merges are batched.**

---

## Working rules

- **The tier sets the mode** — Conductor (you understand it deeply: T3 governance/security/architecture)
  vs Orchestrator (delegate, review after: T1 boilerplate/tests/scaffolding). State it at pickup.
  *Operationally:* Conductor = the builder reasons through and can explain every change itself (no
  black-box sub-agents on the critical path); Orchestrator = may delegate to sub-agents and review their
  output. Rule of thumb either way: **never ship what the builder can't explain.**
- **Verify, don't assume.** Inspect the real environment/code; never claim what you didn't check.
- **Never loosen a control to "make it work."** Stop and escalate.
- **Artifacts (tier-scoped):** **one ADR per real decision** (Tier-3 mandatory) · **one design note per
  Tier-2/3 task** · **append the worklog every session** · **track every task on a board**
  (Backlog → Ready → In progress → In review → Done; set it explicitly, it doesn't auto-move).
  Tier-1 needs none of these beyond a worklog line.
- **Branch per task; conventional commits; PR references the task; squash-merge.** Commit only when asked;
  never self-merge unless told. *(No conflict with the delta-baseline relay or ADR traceability: per-commit
  history lives on the branch during review — where `git diff <sha>..HEAD` and ADRs reference it — and is
  squashed into the trunk only at merge, using the conventional-commit PR title.)*
- **Clean-room verification before every PR:** lint + the full suite against the *real* stack; CI green.
  CI is the **only neutral integration check** — not your machine, not the reviewer's sandbox.
- **Add-a-rule reflex:** when you make a mistake the owner doesn't want repeated, propose a new standing
  rule for the constitution (kept *minimal + precise* — never restate what a tool already enforces).
- **Escape-log reflex:** when a defect slips past a plane that should have caught it, record it in
  `docs/escape-log.md` (which plane missed it, why, and the fix to the *method*) — the methodology's own
  feedback loop; review it to tune tiers and checks.
- **Lint the methodology itself:** `lint-methodology.sh` runs the Machine plane on the docs (placeholders,
  size budget, JSON digest, encoding) — wire it into CI alongside the constitution build.

## Where the human is involved (the whole map)

| Moment | Human |
|---|---|
| **Phase 0 (inception)** | heavy — interactive, *ratify never author* |
| **Per-task direction** | only if Tier-3 *or* Fuzzy (pre-build); else none |
| **Per-task correctness** | **never** — AI⇄AI judgment + the Machine's facts |
| **Merge** | approve from the severity digest (Tier-1 batched) |

> **Honest accounting:** per-task *correctness* is light — but the human's *system-level* touches are real: ratifying golden answers (**not** light), signing each merge's direction-delta, and periodically working the escape log / context-rot sweep / lint triage. "Human owns direction + merge" is the per-task headline, not the whole surface area.

## Why it's shaped this way

- **Reviewed by three planes.** Plan and code are pressure-tested by a *different model* (judgment) and
  must pass deterministic checks + CI (facts) before they reach the human. Most defects die there.
- **Correctness can't rest on the AI pair.** Different vendors miss roughly the *same* bugs (~2 correlated
  votes), so the Machine — property/fuzz tests + human-owned golden answers — carries correctness.
- **The human's time is spent once, on direction, not syntax** — a digest at merge replaces line-by-line.
- **Argued consensus is kept honest *and* protected from sycophancy.** Requiring evidence-backed,
  side-by-side reconciliation stops a hard-pushing builder from talking a correct reviewer down — the
  failure mode a naive "push back" rule would create.
