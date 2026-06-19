# The Constitution (spine → AGENTS.md)

Authored as small spine files here; **assembled** into the repo-root `AGENTS.md` by
`build-constitution.sh`.

**Why a build step:** Codex reads only the *literal bytes* of `AGENTS.md` (git-root → cwd,
**32 KB cap**, no `@import`, no link-following), so the spine must be **inlined, not
referenced** — otherwise the independent reviewer never sees it. Claude Code reads it via
`CLAUDE.md`'s `@AGENTS.md` import.

## Files (concatenation order)
1. `principles.md` — non-negotiables / priorities
2. `conventions.md` — stack, structure, naming, patterns
3. `security.md` — threat model, secrets, reviewer data boundary
4. `definition-of-done.md` — tiered "done" bars + the merge gate

## Build & wire-up
- Run `sh build-constitution.sh` after editing any spine file → writes `AGENTS.md` (< 32 KB).
- `CLAUDE.md` is one line — `@AGENTS.md`. **Windows: import, not symlink.**
- **Verify both planes loaded it:** Claude `/memory`; Codex echoes its instruction files.

## Authoring discipline (Phase 0 is *subtractive*)
- **Minimal + precise** beats comprehensive (auto-generated bloat measurably hurts).
- **Toolchain-first:** never encode a rule a linter / type-checker / CI already enforces.
- Composition: **your global ruleset (optional — a per-environment input, _not_ vendored) ⊕ conventions detected from the code ⊕ the owner's calls.**

> Constitution = rules about the **code**. Process rules live in `THE-FLOW.md`.

> **These spine files ship as _templates_** (placeholders + guidance). Phase 0 fills them per project, and
> `lint-methodology.sh` warns while they're still unfilled. The `AGENTS.md` in this repo is a *demo build*,
> not a real constitution. Target the assembled file at **≤ 12 KB** (32 KB is the hard cap).

> *Loader facts — cite here, **not** in `AGENTS.md` (avoid bloat):* Codex reads `AGENTS.md` literally with a 32 KiB `project_doc_max_bytes` cap and no `@import`; Claude Code reads `CLAUDE.md` as session context (supports `@import`). Per official Codex + Claude Code docs.
