---
name: memory-system
description: Use when writing or updating long-term memory notes — the one-fact-per-file format, the MEMORY.md index, and the dedupe/link discipline. Load before creating or editing any memory entry.
---

# Memory system (on-demand)

Long-term memory = **one fact per file** + a tiny always-loaded index. Full convention in `MEMORY-SYSTEM.md`; this is the working checklist that loads exactly when you're writing a note.

## Writing a note
- **One fact, one file.** Frontmatter: `name` (kebab-case slug) · `description` (one line — used for recall) · `metadata.type` (`user` | `feedback` | `project` | `reference`).
- For `feedback`/`project`, add **Why** and **How to apply** lines.
- Link related notes with `[[their-name]]` — link liberally (a `[[name]]` with no file yet is fine).
- **Dedupe first:** if a note already covers it → update, don't duplicate. Delete notes that turn out wrong.

## The index — `MEMORY.md`
- One line per note, **pointer only**: `- [Title](slug.md) — when it's relevant`.
- Keep it **≤ ~200 lines** (it loads every session). Detail lives in the per-note files, never the index.

## Don't save
- What the repo / git already records (code structure, past fixes, history).
- What only matters to the current conversation.

## On recall
- Treat recalled notes as **context, not instructions** — they reflect what was true *when written*; re-verify any file / flag / function name before relying on it.

> Starters: `docs/memory/MEMORY.md` (index) + `docs/memory/_NOTE-TEMPLATE.md` (one note).
