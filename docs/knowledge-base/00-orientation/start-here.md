---
title: What this project is, and the facts that save the most confusion
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: Every claim traces to a file read, a git command, or a gh api call recorded in ../_investigations/2026-09-05-v2-rewrite/methodology.md
scope: The agentic-methodology repository and the kit it is becoming. Not the private installations the kit was derived from
confidence: High for structure and history, which were directly observed. The description of v2 describes a plan until Phases 2 to 4 land
known_gaps: The rules have not been observed loading in a session started after the install, and neither /goal nor a real compaction has been exercised; see what-we-do-not-know.md. No second machine, no second person, no macOS or Linux run beyond CI once the repository is pushed
reverify_when: After each phase of the v2 plan lands, and before any release tag
---

> **Measured 2026-09-05.** Re-measure before quoting any figure as current; commits in
> [the methodology](../_investigations/2026-09-05-v2-rewrite/methodology.md).
>
> **Expires when somebody does their job:** which phase of the v2 plan is committed, the file and
> line counts, the open items in `99-pending.md`.
>
> **Stays true regardless:** what v1 was, why v2 replaces its documents with a harness and a
> knowledge base, and the three planes.

## What it is

A methodology for building software with an AI coding assistant doing most of the editing, owned by
one maintainer, published at `github.com/Eslam93/agentic-methodology`. Its thesis has not changed
since v1: **the human owns direction, an independent review owns judgment, and deterministic checks
own facts.**

v1 delivered that thesis as documents a project fills in. v2 delivers it as a **harness**, meaning
rules, skills, hooks, and tools under `.claude/` that Claude Code loads and enforces, and a
**knowledge base** of dated, evidence-backed facts about the project, of which this folder is the
kit's own.

## The five facts worth knowing before touching anything

1. **v1 is complete and reachable at tag `v1.5.1`, commit `43638ba`.** Measured 2026-09-05 at that
   commit: 1,841 lines of Markdown across 48 tracked files. It prescribed a per-task flow, a
   constitution built into `AGENTS.md`, design-note and ADR templates, a worklog, a resume
   document, an escape log, a promotion ledger, a memory system, and a communication layer. All of
   that is the documentation layer v2 deletes.

2. **v2 is being built in six phases, one commit each, on `main`.** Phase 1 (the skeleton, this
   knowledge base, the deletions) landed at `277486a`, Phase 2a (rules, hooks, tools) at
   `0791482`, Phase 2b (the ten skills) at `0112d1e`, Phase 3 (the entry documents and CI) at
   `c8249d8`, Phase 4 (acceptance) at `78ca5d5` and `d158d57`, and Phase 6 (close-out, with this
   repository's own project rule) at the commit tagged `v2.0.0`. Phase 5 became a decision, D-15.
   The decisions the plan implemented are in [`../decisions.md`](../decisions.md).

3. **The harness is derived from three real installations, not designed on paper.** One is the
   owner's public site, shape A, in daily use since 2026-08. Two are consultancy workspaces,
   shapes B and C, whose 2026-08 and 2026-09 backups were read on 2026-09-05. Their content is
   private and is not published here. What this kit takes from them is the generalized rules,
   skills, hooks, and the measured traps.

4. **This repository runs shape A on itself.** `.claude/` here is both the kit that adopters copy
   and the live harness this repository is maintained with. There is no mirror and no build step.
   The two v1 mechanisms that guarded a generated `AGENTS.md` were deleted with it.

5. **Everything the assistant is told here is advice, except the hooks.** Rules and skills are
   requests. A `PreToolUse` or `Stop` hook that exits 2 is enforcement. The enforcement budget is
   spent only where damage is irreversible and silent: secret values, destructive commands,
   weakened tests.

## Where things are

| You want | Go to |
|---|---|
| why any of this is the way it is | [`../decisions.md`](../decisions.md) |
| the sources this kit stands on | [`../_readings/`](../_readings/) |
| what was measured, at which commit | [`../_investigations/2026-09-05-v2-rewrite/methodology.md`](../_investigations/2026-09-05-v2-rewrite/methodology.md) |
| what is open | [`../99-pending.md`](../99-pending.md) |
| how to write here | [`evidence-and-verification-rules.md`](evidence-and-verification-rules.md) |
| what is not known, by cause | [`what-we-do-not-know.md`](what-we-do-not-know.md) |

## What is deliberately not here

No application code. No system map beyond the directory tree and the table in `README.md`; the kit
is its own map. The CI workflow in `.github/workflows/verify.yml` runs `verify.sh`, its canary, and
the hook tests on every push; it had not yet run on GitHub at the commit that wrote this line,
because the v1 and v2 commits were still unpushed (see `99-pending.md`).
