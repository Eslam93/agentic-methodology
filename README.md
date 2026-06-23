# Agentic Development Methodology

A reusable, **droppable** setup for AI-assisted engineering: detect a project's readiness, provision
what's missing, then run every task through a three-plane review with the human gating only
**direction** and the **merge**.

## The idea in one breath

> **Human owns _direction_** (set at task definition · confirmed at merge · pre-checked when *fuzzy*
> or *Tier-3*). **AI⇄AI owns _judgment_.** **The Machine + CI own _facts_.**
> AI⇄AI consensus is *necessary, not sufficient* — so deterministic checks carry correctness.

**Three planes:**
- **Builder** (Claude) — plans, implements, drives.
- **Reviewer** (an independent Codex session) — pressure-tests plan & code as a peer; reaches an
  **argued, evidence-backed** consensus. Its strength is **design judgment + process/direction audit**;
  catching correctness bugs is its *weakest* use (correlated blind spot) — so the Machine carries correctness.
- **The Machine** (tests, types, lint, fuzz/property checks + **CI**) — verifies what neither model can
  vouch for. CI is the only *neutral* integration check.

> *What the cross-vendor reviewer actually buys:* mostly **"didn't-write-it" decorrelation** (own-output
> blindness lifts when the artifact arrives as external input — the cold pass captures this), plus a
> *modest* "different-mind" bonus (frontier models share blind spots, so it's smaller than "different
> vendor" implies). The reviewer is a **swappable role** for exactly this reason.

**Two dials, set per task** (builder-proposed, fail-safe): a **risk tier** (1/2/3, with a hard-floor
trigger set) sets correctness ceremony; an **intent-certainty** dial (crisp / uncertain / fuzzy) sets
direction checking.

## What's here

| Path | What it is |
|---|---|
| [`THE-FLOW.md`](THE-FLOW.md) | The per-task **SOP** — the build loop + close-out, the dials, the human-map. |
| [`docs/lane-card.md`](docs/lane-card.md) | **The daily entry point** — pick a lane, run its column. |
| [`docs/phase-0.md`](docs/phase-0.md) | **Bootstrap** — probe → provision → degrade for *any* project. |
| [`docs/adoption.md`](docs/adoption.md) | **Retrofit** — adopt onto a *live* project in 3 stages (no big-bang). |
| [`docs/constitution/`](docs/constitution/) | The **rules about the code** (spine → built `AGENTS.md`). |
| [`docs/definition-of-ready.md`](docs/definition-of-ready.md) | The entry gate for a task. |
| [`docs/design-notes/_TEMPLATE.md`](docs/design-notes/_TEMPLATE.md) | The per-task workhorse (Tier 2/3). |
| [`docs/adr/_TEMPLATE.md`](docs/adr/_TEMPLATE.md) · [`docs/worklog.md`](docs/worklog.md) | Decisions + session log. |
| [`docs/resume.md`](docs/resume.md) | **Handoff** — always-current "start here" + prep-for-compact checklist. |
| [`docs/architecture/README.md`](docs/architecture/README.md) | System-map template (Phase-0 generated). |
| [`MEMORY-SYSTEM.md`](MEMORY-SYSTEM.md) | File-based long-term memory (rides native auto-memory rails). |
| [`docs/memory/`](docs/memory/) | Memory starters — `MEMORY.md` index + `_NOTE-TEMPLATE.md` (copy to the harness memory dir). |
| [`codex-relay.command.md`](codex-relay.command.md) | The slash command wiring in the independent reviewer. |
| [`DECISIONS.md`](DECISIONS.md) | Locked design rationale + evidence base + the parked-for-v2 list. |
| `build-constitution.sh` · `CLAUDE.md` | Assemble the spine → `AGENTS.md`; Claude's import pointer. |

## Prerequisites
- An agentic harness with **slash commands**, **sub-agents**, and a **file-based memory** (builder = Claude Code).
- The **`codex` CLI** installed + authenticated — a *different* model from the builder (independence is the point).

## Wiring it up
1. Run **Phase 0** ([docs/phase-0.md](docs/phase-0.md)) on the project — probe readiness, provision gaps interactively.
2. Author the constitution spine in `docs/constitution/`, then `sh build-constitution.sh` → `AGENTS.md`
   (< 32 KB). Keep `CLAUDE.md` = `@AGENTS.md` (**Windows: import, not symlink**).
3. Put `codex-relay.command.md`'s body into `.claude/commands/codex-relay.md`; copy `codex-relay.json.example`
   to `./.claude/codex-relay.json` and fill `verify` + `env_notes`; copy `codex-relay.deep-review-prompt.md`
   to `~/.claude/codex-relay/deep-review-prompt.md` (needed for `deep` mode).
4. Adopt `THE-FLOW.md` as the SOP and `MEMORY-SYSTEM.md` as the memory convention.
5. **Enable the guards:** `git config core.hooksPath .githooks` — the pre-commit hook runs `lint-methodology.sh` and blocks any commit that leaves `AGENTS.md` stale or the docs broken. The memory discipline ships as an on-demand skill at `.claude/skills/memory-system/`; copy it to `~/.claude/skills/` to make it available across all your repos.

> **v1 assumptions:** builder = Claude, reviewer = Codex (one independent vendor). "Reviewer" is a
> *role* — swappable later. See [`DECISIONS.md`](DECISIONS.md) for the full rationale and the v2 backlog.
