# Methodology v1 — Design Decisions

> Canonical record of the design session on **2026-06-19** that hardened the methodology baseline.
> **Status:** decisions LOCKED · doc crystallization in progress.
> **v1 assumptions (deliberately fixed to keep things simple):** builder = **Claude Code**; reviewer = **Codex CLI** (one independent vendor, swappable later — "reviewer" stays a *role*, hard-wired to `codex-relay` for v1; no abstraction layer built yet = YAGNI).

---

## 0. The thesis (sharpened)

> **Human owns _direction_** (set at task definition · confirmed at merge · pre-checked when *fuzzy* or *Tier-3*).
> **AI⇄AI owns _judgment_.** **The Machine + CI own _facts_.**

AI⇄AI consensus is **necessary but not sufficient** — it is ~2 *correlated* votes, not two independent proofs (see §6). Correctness is carried by the Machine plane, not by two models agreeing.

The differentiated bet vs. the field: we **replace the human plan-approval gate with an _argued_ AI⇄AI consensus**, and gate the human only on direction + an executive-overview merge. This is ahead of mainstream tooling (Spec-Kit/Kiro still default to a human plan gate) — defensible, but the burden is on us to keep it honest (hence the guardrails in §5–§7).

---

## 1. The three planes

| Plane | Who | Owns | Notes |
|---|---|---|---|
| **Builder** | Claude Code | drives — plans, implements | states tier + mode at pickup |
| **Reviewer** | independent Codex session | **judgment** — pressure-tests as a peer | argued consensus, must push back *with evidence*; never rubber-stamp |
| **The Machine** | deterministic checks + CI | **facts** — correctness backstop | CI = the *only* truly neutral integration verifier |

Human owns **direction**, nothing else routine.

---

## 2. The two dials + the human-involvement map

Both dials are **builder-proposed at pickup** and **fail-safe** (round toward *more* scrutiny when unsure).

### Risk × reversibility — sets *correctness ceremony*
| Tier | What | Ceremony | Definition of Done |
|---|---|---|---|
| **1 · Fast-track** | low-risk, reversible, small | skip ADR/design-note/plan-relay; code relay optional | lint + affected tests; **batched** into merge digest |
| **2 · Standard** | normal feature/fix/refactor | full 6-step flow | lint + full suite vs real stack + CI green + coverage + reviewer consensus |
| **3 · Critical** | high-risk *or* hard-to-reverse *or* architecture-touching | full flow **+ ADR + `deep` relay + rollback plan + owner direction pre-check** | Tier 2 + ADR + deep-review consensus + rollback verified |

- **Tier-3 trigger set = HARD FLOOR (auto-escalate):** `{auth, authz, payments, secrets, data migration, public API/contract, security control, cross-module architecture}`. Builder may tier **up** freely; **cannot** tier a trigger-area change **down**.
- **Tier sets the mode:** T3 ⇒ Conductor, T1 ⇒ Orchestrator, T2 ⇒ builder's call. (Conductor/Orchestrator is no longer a separate axis.)
- **Reviewer audits the tier** on every relay ("you called this T2 but it touches auth → T3").

### Intent certainty — sets *direction checking*
| Certainty | Looks like | Handling |
|---|---|---|
| **Crisp** | clear "what" + acceptance criteria, pre-agreed | no *pre-build* gate; direction reconciled at merge via the direction-delta |
| **Uncertain** | "what" mostly clear, interpretation choices remain | **async, non-blocking** note ("my read + plan intent; flag if off") |
| **Fuzzy** | the "what" itself unresolved; builder guessing | **BLOCKING — human approval before any build** |

> **Unified pre-build human checkpoint fires when: risk = Tier 3 _OR_ certainty = Fuzzy.** Uncertain → async note. Else → nothing until merge.

### The complete "where's the human" map
| Moment | Human |
|---|---|
| **Phase 0 (inception)** | heavy — interactive, *ratify never author* |
| **Per-task direction** | only if Tier-3 *or* Fuzzy (pre-build); else none |
| **Per-task correctness** | **never** — AI⇄AI + the Machine |
| **Merge** | approve from executive overview / severity digest (Tier-1 batched) |

---

## 3. Portability & Phase 0

**The reframe:** a project's first act is a **probe → provision → or degrade**, never an assumption.

- **7-capability readiness model**, scored *per-capability* (Absent / Weak / Ready): Governance · Architecture · Work-definition · Verification · Version-control · Tracking&memory · Review-plane.
- **Phase 0 posture: interactive, piece-by-piece** — *owner ratifies, never authors*; sees only **deltas + decisions**, each with a recommendation (blanket-accept where indifferent).
- **Phase 0 = the flow pointed at the scaffolding** (builder plans, reviewer pressure-tests, owner ratifies) — provision in dependency order; reviewer cost only on Governance + Architecture.
- **Phase 0 is _subtractive_:** minimal + precise beats comprehensive; **toolchain-first** (never encode a rule a linter/type-checker/CI already enforces); treat `/init` output as an inventory to **delete from**. *(Auto-generated context files measurably hurt — Gloaguen 2026.)*
- **"Ready" = good enough to lean on, not perfect.**
- **The honest tradeoff:** the human-light promise *scales with substrate*. You can remove the human, *or* the reviewer, *or* the deterministic tests — **not all three.** Low substrate = dial sits toward more-human / more-risk until bootstrapped.

---

## 4. The constitution (file format + spine)

- **`AGENTS.md` is canonical** (read by both planes). **Codex reads only the literal bytes** (git-root → cwd walk, **32 KB cap**, follows neither `@import` nor links). Claude Code does **not** auto-load `AGENTS.md`.
- **Spine authored as separate files** under `docs/constitution/` (`principles.md`, `conventions.md`, `security.md`, `definition-of-done.md`) → **concatenated into the canonical `AGENTS.md` by a build step**, kept **< 32 KB**.
- **`CLAUDE.md` = one line `@AGENTS.md`** (so Claude's native loader fires). **Windows: use the import, not a symlink.**
- **Verify what each tool loaded** (Claude `/memory`; Codex echoes its instruction files) — this is load-bearing.
- **Boundary:** the constitution = rules about the **code**; THE-FLOW = rules about the **process**. Keep separate.
- **Composition:** constitution = *your global ruleset (optional per-environment input — e.g. `~/.claude/rules/common/*`; **not vendored**, degrades gracefully if absent) ⊕ conventions detected from code ⊕ owner's project-specific calls.*

---

## 5. Consensus protocol (anti-collusion)

- Argued consensus, **≤ 3 reviewer rounds**, genuine deadlock → escalate to owner.
- **Anti-sycophancy guardrails** (challenged reviewers cave 13–80% of the time; *casual* pushback is the most corrosive):
  1. **Evidence-only rebuttals** — the builder may push back only by citing a **re-run test result, a spec/constitution line, or a concrete counterexample.** Bare "I disagree" is invalid → the finding stands.
  2. **Side-by-side adjudication** — restate the *original finding* next to the evidence-backed rebuttal and judge them **as a pair**, not as a continuing argument. (Cuts cave-in ~84% → ~44%.)
  3. **Fast-consensus flag** — instant agreement on a **Tier-3 / critical-path** change is *escalated*, not trusted.
- **Cold-diff code review** (models miss ~64% of their *own* errors but catch them as external input):
  - **Cold correctness pass first** — reviewer gets diff + what-it-should-do + *how* to verify + **"independently recompute before judging"** — but **NOT** the builder's reasoning or claimed results.
  - **Context pass second** — *then* share judgment calls / rationale / results for the design discussion + reconciliation.

---

## 6. Verification (the Machine plane)

- **AI⇄AI ≈ ~2 _correlated_ votes** — cross-family blind-spot overlap ≈ same-family (Claude & Codex miss roughly the same bugs). So the Machine carries correctness.
- **Tiered:**
  - **T3:** property / fuzz / metamorphic tests required; **human ratifies the golden answers** (ratify-don't-author — blocks AI tests enshrining current-buggy behavior).
  - **T2:** standard tests + property tests where the input space is non-trivial; human ratifies golden answers for core logic.
  - **T1:** example tests fine.
- **TDD delivered as a _test-map_, not recited procedure** ("do TDD" prose *raised* regressions 6→10%; a test-map cut them 72%): the design note lists the **existing tests that cover the change (must stay green) + the new tests each acceptance criterion requires.**
- **DoD line:** *"AI⇄AI consensus is necessary, not sufficient — correctness isn't done until the Machine passes, and a human owns the golden answers for critical logic."*

---

## 7. The merge gate (severity digest)

- Every finding bucketed: **🔴 Action-Required / 🟡 Recommended / ⚪ Minor**, plus a one-word verdict **PASS / CONCERNS / FAIL / WAIVED**.
- **Merge allowed iff the 🔴 bucket is empty.**
- Emitted **machine-readable** (a hook/CI can block on any 🔴) **+ human-readable** (the executive overview you actually read). **Tier-1 merges batched** as a list of these one-liners.

---

## 8. Planning additions

- **`/clarify` before planning** — *demand-driven and proportional* (invisible when crisp, a safety net when fuzzy): records a *Clarifications* section in the design note. Paired with a **plan confidence self-score (1–10)** that routes **≤ 6 → treat as fuzzy → human direction gate; ≥ 7 → proceed.** The number is a heuristic; the **clarify questions are the real signal** (visible, reviewer can challenge a dishonest score).
- **EARS acceptance criteria** (`WHEN/WHILE/IF … THE SYSTEM SHALL …`) in design notes — **Tier 2/3** (skip Tier 1). Each EARS line → one test in the test-map.

---

## 9. Decision ledger

| # | Item | Decision |
|---|---|---|
| 1 | Severity-tiered merge digest | ✅ adopt |
| 2 | `/clarify` + confidence-score (demand-driven) | ✅ adopt |
| 3 | EARS acceptance criteria (Tier 2/3) | ✅ adopt |
| 4 | Per-dimension reviewer passes | ⏸ **park** → lenses baked into the single review prompt; decorrelation handled by the Machine plane |
| 5 | RADAR-style auto-classifier | ⏸ **park → v2** (v1 = hard-floor + builder-proposes + reviewer-audits) |
| 6 | §1 AGENTS.md spine fix | ✅ adopt |
| 7 | §2a Machine plane carries correctness | ✅ adopt (tiered) |
| 8 | §2b anti-sycophancy guardrails ×3 | ✅ adopt |
| 9 | §2c cold-diff + recompute trigger | ✅ adopt |
| 10 | §3a Phase 0 probe-and-prune | ✅ adopt |
| 11 | §3b TDD as a test-map | ✅ adopt |
| 12 | §4 validations | ✔ confirmed |

---

## 10. Parked for v2

- **RADAR-style risk auto-classifier** (authorship + diff-risk score + percentile thresholds) — graduate when volume justifies it.
- **Per-dimension reviewer passes** — only if single-pass + Machine plane prove insufficient.
- **Area-scoped rules** — per-directory `AGENTS.md` (+ `CLAUDE.md` pointer) for large repos.
- **Reviewer abstraction layer** — only when a second/third reviewer vendor actually arrives.

---

## 11. Status / historical change log

> Entries are chronological; later entries supersede earlier "pending" notes.

- **✅ Thread #5 — document spine + templates (DONE):** constitution scaffold (spine → `AGENTS.md` build + `CLAUDE.md` pointer) · `definition-of-done.md` (tier table + merge gate) · design-note / ADR / Definition-of-Ready templates · `worklog.md` · `phase-0.md`.
- **✅ v1 rewrites (DONE):** `THE-FLOW.md`, `MEMORY-SYSTEM.md`, `codex-relay.command.md`, `README.md`.
- **✅ Self-containment audit (DONE):** deep-review prompt **vendored** as `codex-relay.deep-review-prompt.md` (+ wiring-up install step); architecture-map + memory (`MEMORY.md` index + note) **starters** added so every prescribed artifact ships a template. Rule of thumb — **mechanism ⇒ vendor; input ⇒ reference-and-degrade**: the global ruleset and the external board stay optional referenced inputs, not vendored copies.
- **🔧 v1.1 hardening — from external review (Cluster A adopted):** (1) cold-derived acceptance criteria + direction-delta at merge — closes "built the wrong thing, proven green"; (2) diff-scoped mutation testing as the Machine's *outcome* gate (T3 required ≥ threshold, T2 recommended); (3) T2 **lite lane** + **blast-radius receipt** (heuristic, *not* the parked learned classifier); (4) symmetric evidence — a 🔴 without reproducing evidence → 🟡 pending (🔴 = demonstrably broken, 🟡 = judgment); (5) evidence calculus — independent > builder-produced, citations never settle alone. *(Clusters D–E pending.)*
- **🔧 v1.1 — Cluster B adopted:** (6) reviewer's role reframed (design + process/direction audit; correctness → the Machine); (7) independence named honestly — mostly *didn't-write-it*, modest *different-mind*; **Codex kept for v1**, fresh-Claude cold pass noted as a swappable option *(DECIDED: Codex is the sole v1 reviewer; fresh-Claude documented as the later swap)*; (8) evidence-base honesty (64.5% caveated to non-reasoning models; TNR<25% added; Gloaguen/TDAD flagged unverified); (9) golden-answers owned as the one non-light human floor + custody block; (10) human-light-scales-with-substrate stated bluntly.
- **🔧 v1.1 — Cluster C adopted:** (11) digest **JSON schema** (emoji = display; CI gates on `merge_allowed`; every 🔴 carries `evidence`); (12) **branch-scoped relay state** (fixes the parallel-baseline data race; refuse-on-branch-change); (13) CI **WAIVED** protocol (reason · owner · replacement output · expiry · follow-up); (14) flaky result ≠ evidence (quarantine); (15) reviewer relay is a **two-way** trust boundary — reviewer output untrusted until verified.
- **🔧 v1.1 — Cluster D adopted:** (16) **methodology linter** (`lint-methodology.sh` — placeholders / size / JSON digest / encoding); (17) **context-rot audit** (phase-0 §5 cadence — semantic stale-ref sweep); (18) **escape log** (`docs/escape-log.md` — defect → plane-that-missed-it) — the self-improvement loop **un-parked** as a lite instrument.
- **🔧 v1.1 — Cluster E adopted (smalls):** EARS *ubiquitous* invariants restored; confidence score gains an **uncertainty-type** label (product-value/security/data-contract → direction gate); Conductor/Orchestrator given an *operational* definition (explain-it-yourself vs delegate-and-review; never ship what the builder can't explain); squash-merge ↔ delta-baseline clarified (per-commit on the branch, squash only at trunk); AGENTS.md **≤ 12 KB target** added to the build; spine **template-vs-live** clarified; cold pass gains a **red-team framing** + a **(T3) pre-mortem**.
- **🔧 v1.1.2 — review iteration 3 (solo-filtered, cheap subset applied):** schema **tightened** (verdict↔findings consistency · recipe needs expected/actual · `additionalProperties:false` + `extensions`/`waivers`); evidence ladder gains a **recipe timebox** + spec-line-proves-existence-not-violation; **cold/context STATUS fields marked** (anti-anchoring); relay **secret-preflight + injection-resistant preamble** (solo-sized security); **lane card** added as the daily entry point; human-accountability reworded (**direction + risk + domain truth**); over-strong cites **demoted** (RADAR / Autonomy×Risk / PRP / TPR-TNR) + Kiro claim corrected. *Deliberately skipped as team-shaped: RACI · metrics dashboard · enterprise data-classification · relay-as-full-script + run-dir/locking · CI enforcement pipeline.*
- **✅ v1.1 hardening COMPLETE (Clusters A–E).** Open items: **#7 decided — Codex sole v1 reviewer**; **re-verify Gloaguen/TDAD cites — deferred** (owner: "later").
- **🔧 v1.1.1 — review iteration 2 (applied in full):** the meta-fix — marked **core vs hardening** (`docs/minimal-core.md`) so the method subtracts on *itself*; 4 risk/clarity signals → 2 axes (confidence number demoted to color); **design relay optional for routine T2** (full relay reserved for T3 / arch / fuzzy); evidence rule → **5-level ladder + reproducible-recipe** (a real bug the sandbox can't run still blocks); **cold-criteria from raw verbatim task text**; mutation **fast-unit-scoped + probe-and-degrade + default 80%**; coverage demoted to a proxy where mutation runs; **no-op** a valid outcome (DoR + step 1); linter gains **staleness guard + broadened mojibake + real JSON schema (`docs/schemas/severity-digest.schema.json`) + config-smell checks**; crisp-row · lite-lane-on-receipt · rebase→merge-base fallback · honest human-touchpoint accounting; cites **re-verified** + METR / no-op / config-smell added. *(Cites' independent web-check still owner-deferred.)* *(Stays v2: area-scoped AGENTS.md · learned RADAR classifier · per-dimension passes · reviewer abstraction.)*
- **🔧 v1.1 — Review #2 (practitioner, real project):** ~90% validation ("it's our evolved flow, hardened + portable"); confirmed the AGENTS.md-spine win from lived pain (reviewer was blind to project laws in `CLAUDE.md`). One new artifact adopted: **`docs/adoption.md`** — a staged *retrofit* playbook (additive-now → constitution-deliberate → cosmetic-lazy) for adopting onto a *live* project, distinct from phase-0's greenfield bootstrap. (Project-specific migration left to the adopting team.)
- **Not yet discussed (future sessions):** methodology success metrics · the §10 v2 backlog (RADAR classifier · per-dimension passes · area-scoped rules · reviewer abstraction). *(Concurrency handled in C; the self-improvement loop is seeded in D via the escape log — success metrics can grow from it.)*

---

- **🔧 v1.2 — applied (post-review, pre-first-run):** **(1)** lint guard wired as a **git pre-commit hook** (`.githooks/pre-commit` + `git config core.hooksPath .githooks`) — blocks any commit that leaves `AGENTS.md` stale or the docs broken. Chose a git hook over a Claude-Code PostToolUse hook: **surface-independent** (the daily driver is a customized, non-standard CC surface, so CC hooks may not fire). **(6)** `MEMORY-SYSTEM.md` exposed as an **on-demand skill** (`.claude/skills/memory-system/SKILL.md`). **Deferred to post-first-run:** SessionStart nudge (#2) · **plugin packaging (#3)** — now *distribution-only* for us, since the OpenAI/CC plugin path needs the vanilla `claude` CLI, which **isn't installed here** (we run a customized surface); the **`codex` CLI direct already covers the transport** (continuity empirically verified: fresh `exec` = stateless, `resume` = full memory). **Optional / task-time:** local cold-criteria pre-filter (#4) — a *cost optimization*, never a "decorrelating signal." **Rejected:** MCP-for-relay-state (#5).

- **🔧 v1.3 — from real use (first practice complaints):** **(1)** added **Step 7 — Close-out & handoff**: after every merge, a mandatory close-out (worklog · `docs/resume.md` handoff doc · board · memory · `AGENTS.md`-fresh) then a **context-aware "start now vs checkpoint + compact" checkpoint** — *"what's next" is now planning, not a go signal* (it had been diving straight into the next task and skipping compact-prep). Standardized **`docs/resume.md`** as the handoff / prep-for-compact artifact (distinct from the append-only worklog). **(2)** flipped the **codex-relay return contract to verdict-first** — line 1 is `VERDICT: … · 🔴n 🟡n ⚪n`, terse findings below — so the gate reads one line instead of dissecting a long review.

## Evidence base (for the docs' credibility)

Cross-context review beats self-review; "Nine Judges, Two Effective Votes" (correlated errors — cross-family ≈ same-family); **judge-calibration: AI reviewers run TPR > 96% but TNR < 25% — they wave correct code through yet catch < ¼ of real defects (the strongest case for "the Machine carries correctness")**; Self-Correction Bench (~64.5% own-error blindness — *caveat: measured on non-reasoning models; deliberation ("Wait") cuts it ~89%, so the raw figure overstates the blind spot for reasoning builders/reviewers; the mechanism still holds*); sycophancy-under-rebuttal studies (citation rebuttals most regressive; ~78.5% persistence → escalate); Meta RADAR (risk-tiered review, revert ⅓ / incident 1/50); Anthropic Autonomy×Risk; GitHub Spec-Kit (`constitution.md`); Amazon Kiro (EARS, per-phase gates); PRP (validation loops, confidence score); AGENTS.md standard + Claude Code / Codex loader docs. **Re-verified by both review-2 reviewers (independent web-check still owner-deferred):** Gloaguen et al. `arXiv:2602.11988` (repo context files tend to *reduce* task success + raise cost >20%; harm concentrated in *LLM-generated* files — human-written give ~+4% at ~+19% cost, architecture overviews don't earn their place, every context file adds steps — *supports the subtractive constitution + trimming the architecture map*) and TDAD `arXiv:2603.17973` (procedural TDD prompting raised regressions to 9.94%; a targeted test-map cut them ~70%). Applicability still varies by model class / task / harness. Added: **METR** (Mar 2026 — many SWE-bench-passing PRs wouldn't actually merge → backs "Machine-pass ≠ done" + the direction-delta); **"Coding Agents Don't Know When to Act"** `arXiv:2605.07769` (backs the no-op outcome); **Configuration Smells in AGENTS.md** `arXiv:2606.15828` (backs the linter's config-smell checks). *(Full sourced report available from the landscape scan.)*

**Demoted to supporting-rationale (not independently verified — review-3 web pass):** Meta "RADAR", "Anthropic Autonomy×Risk", "PRP validation loops", and the AI-reviewer TPR>96% / TNR<25% figures. The *directions* (risk-tiered review, two-axis autonomy, executable validation loops, low reviewer true-negative rate) hold, but the specific names/numbers are **not load-bearing** until cited to primary sources. **Corrected:** the "ahead of mainstream because Spec-Kit/Kiro gate the plan" claim is overstated — **Kiro ships a no-gate "Quick Plan" path** — so reframe as *"a more AI-mediated plan-reconciliation model, to be validated by pilot metrics."*
