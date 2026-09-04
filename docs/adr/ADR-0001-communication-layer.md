# ADR-0001: A Claude-only communication layer, kept out of the constitution

- **Status:** Accepted
- **Date:** 2026-07-11
- **Task:** COMMS-1 (design note: `docs/design-notes/COMMS-1-communication-layer.md`)
- **Tier:** 2 (lite)   <!-- welcomed, not mandated at T2; recorded because it adds a layer to the method -->

## Context
The methodology keeps the human for direction and merge approval, both read from human-facing prose (design
notes, direction-deltas, severity digests). When the builder's default voice is dense with stack-specific
jargon, a non-specialist owner cannot reliably do that job. We want the builder's voice to adapt when a repo
adopts the methodology: switchably, per repo, without adding weight to the per-task flow or to the
constitution.

## Decision
Add a **communication layer** on the Claude Code output-style + skills surface:
- an always-on, project-scoped output style (`plain-technical`, `keep-coding-instructions: true`) that is
  **on by default on adoption** and toggled per repo via `/output-style`;
- six **one-shot** mode commands (`/explain /brief /architect /product /peer /normal`), each shaping a single
  response before the baseline resumes.

It is Claude-only (builder plane), documented in `docs/communication.md`, provisioned as an optional Phase-0
add-on, and listed in the `minimal-core.md` hardening menu. It is **not** a step in `THE-FLOW`.

## Consequences
- Easier: the human's direction and merge reading improves; adoption also adapts the builder's voice with no
  extra action.
- Harder / accepted: one more optional layer to keep fresh; default-on means adopters get the voice unless
  they opt out (a deliberate choice).
- **Boundary held:** communication instructions stay out of `AGENTS.md`. The reviewer does not read them, and
  the constitution's size budget is preserved. Voice = builder-to-human; constitution = rules about the code
  (both planes); `THE-FLOW` = process. Three separate homes.
- Revisit if: a second builder/reviewer vendor arrives (the modes are Claude-specific), or if the layer
  starts leaking into per-task ceremony (then it has failed the minimal-core test and should be cut).

## Alternatives considered
- **Put the voice in `AGENTS.md` / `CLAUDE.md`:** rejected. It bloats the constitution, and the reviewer
  (which cites it) does not need voice rules.
- **A per-turn hook that injects the instruction:** rejected. More fragile, and imperative injected text can
  trip prompt-injection handling; an output style lives in the system prompt and is simpler and more durable.
- **Persistent modes (like the standalone communication-modes pack):** rejected here. With an always-on
  baseline, one-shot overrides are cleaner and match the natural skill-injection lifecycle: a mode is a
  single-turn nudge, and the baseline in the system prompt reasserts by itself.
