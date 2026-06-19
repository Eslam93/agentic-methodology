# Adoption — retrofitting onto a live project

> `phase-0.md` bootstraps a project *toward* readiness. **This** is for the other case: you already run
> an ad-hoc process on a **mid-flight** project and want to adopt the methodology **without a big-bang
> rewrite.** The spine of most teams' flow already matches — so adopt **additively, in three stages**:
> quality rises on the very next task, and the plumbing waits.

## Stage 1 — Now (zero migration, pure quality)
Habits + relay wording only; no file moves, no rewrites:
- **Severity digest at merge** — bucket findings 🔴/🟡/⚪ + a PASS/CONCERNS/FAIL verdict; merge iff 🔴 = 0.
- **Anti-sycophancy + cold-diff in the relay** — evidence-only rebuttals, side-by-side, a cold correctness pass first (withhold your reasoning/results), red-team framing.
- **EARS acceptance criteria + a test-map** in design notes.
- **The two dials as a labeling habit** — state tier (1/2/3) + intent certainty (crisp/uncertain/fuzzy) at pickup.
- **Definition of Ready** as an entry check before starting a task.

> These need no migration and lift quality immediately. **Start here.**

## Stage 2 — Deliberate pass (real effort + judgment) — a mini Phase-0
The one piece with genuine work *and* a real decision:
- **Author the constitution spine → build `AGENTS.md`** so the *reviewer* finally cites the same rules you follow. (If your laws live only in `CLAUDE.md` today, the reviewer is **blind to them** — Codex reads only `AGENTS.md`.)
- The judgment call — **what to keep:** port your existing laws, then *prune* anything a linter / type-checker / CI already enforces (toolchain-first). Your global ruleset becomes an optional input you prune *from*, not an always-loaded book.
- Wire the relay project-local (`.claude/commands/`) + vendor the deep-review prompt.
- `CLAUDE.md` = `@AGENTS.md` (**Windows: import, not symlink**). Run `lint-methodology.sh`.

> Run this *as a task through the flow itself* — builder drafts the spine, reviewer pressure-tests, you ratify. It's Phase-0 pointed at your own scaffolding.

## Stage 3 — Lazy / whenever (cosmetic)
No urgency:
- Renames to the standard layout (`docs/adr/`, `docs/worklog.md`, an architecture map under `docs/architecture/`).
- Board / worklog conventions.

## The sequencing rule
**Never big-bang mid-flight.** Stage 1 is free and immediate; Stage 2 is one deliberate mini-Phase-0 (where the "what to keep from the old rules" judgment lives); Stage 3 is cosmetic. **Adopt the guarantees first, the plumbing last.**

> Greenfield project instead? Use `phase-0.md` — this guide is specifically for retrofitting a project that already has its own working process.
