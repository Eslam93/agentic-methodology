# Phase 0 — Bootstrap (dropping the methodology into any project)

> A project's **first act is a probe, not an assumption**: detect what exists, provision what's
> missing, or explicitly degrade. Phase 0 is the one place the human leans **in** — inception
> sets intent + governance. After it, you return to the human-light steady state.
>
> **Posture: interactive, piece-by-piece — the owner _ratifies, never authors_** (sees only deltas
> + decisions, each with a recommendation; blanket-accept where indifferent).
> **Phase 0 = the flow pointed at the scaffolding** (builder plans, reviewer pressure-tests, owner
> ratifies) — nothing new to learn.

## 1 · Probe — readiness across 7 capabilities
Score each **Absent / Weak / Ready** (mostly automatable file/CLI detection):

| Capability | "Ready" bar | Detection signal |
|---|---|---|
| **Governance** | a constitution a reviewer can *cite* | `AGENTS.md` / `CLAUDE.md` / rules present |
| **Architecture** | a current system map; ADRs from now on | `docs/architecture/`, `docs/adr/` |
| **Work-definition** | tasks meet the Definition-of-Ready | tracker / board quality |
| **Verification** | one cmd runs lint + full suite; stack stands up; CI exists; mutation tooling probed | test config, CI workflows, mutation tool (stryker / pit / mutmut / cargo-mutants / …) |
| **Version control** | git; branch-per-task; PR/merge path | `git rev-parse` |
| **Tracking & memory** | task states visible; memory seeded | board, `MEMORY.md` |
| **Review plane** | a *different* model reachable + authed | `codex` CLI present |

> Detect the **review plane first** — no second model ⇒ posture shifts (human reclaims the plan gate).

## 2 · Provision — in dependency order (interactive)
1. **Version control** — `git init` if missing (cheap; unblocks delta baselines).
2. **Governance (constitution)** — builder drafts from code ⊕ **your global ruleset _if you have one_**
   (an *optional* per-environment input, e.g. `~/.claude/rules/common/*` — **not vendored** here; with no
   global ruleset the constitution is built from detected conventions ⊕ owner calls alone), surfacing only
   *conflicts / gaps / project non-negotiables*; reviewer pressure-tests; you ratify. *(reviewer cost)*
3. **Architecture map** — reverse-engineered from code (template: `docs/architecture/README.md`); reviewer checks. *(reviewer cost)*
4. **Verification** — bootstrap lint/test/CI; for greenfield this *becomes* the first real tasks.
5. **Work-definition + tracking/memory** — seed `MEMORY.md` (starters in `docs/memory/`), worklog, board (or worklog-only).

Only steps 2–3 cost a reviewer round; the mechanical ones don't.

## 3 · Authoring discipline — *subtractive*
- **Minimal + precise** beats comprehensive (auto-generated context bloat measurably hurts outcomes).
- **Toolchain-first:** never encode a rule a linter / type-checker / CI already enforces.
- Treat any generated draft (e.g. `/init` output) as an **inventory to delete from.**
- "Ready" = good enough to lean on, **not perfect.**

## 4 · Degrade — when you choose not to provision
> **The promise and the boundary, bluntly:** this methodology makes routine human review light **only
> after** the project has real tests, real CI, a citeable constitution, and a working independent
> reviewer. Without those it *deliberately becomes more human-heavy.* That is both the product promise
> and the safety boundary.

The human-light promise **scales with substrate**. You can remove the human, *or* the reviewer,
*or* the deterministic tests — **not all three.** State the degraded guarantee out loud:
- **No CI** → local-suite gate; CI-green can't be a merge gate (named gap).
- **No second model** → single-plane; the **human reclaims the plan gate**.
- **No real stack** → contract/mocks + a flagged integration gap.

## 5 · Keep it fresh (context-rot audit)
Config files go stale as code moves. **Monthly, or before a milestone:**
- grep `AGENTS.md` / `CLAUDE.md` / the architecture map for file paths, commands, and module names;
- verify each still exists; run each listed command;
- delete or update stale instructions (treat the constitution as *code*, not archive);
- record the sweep in the worklog.

`lint-methodology.sh` automates the *structural* half (placeholders, size, schema, encoding); this audit covers the *semantic* half (do the references still point at real things).
