# The file-based memory system

A persistent directory of **one-fact-per-file** notes the agent reads each session. Cheap to write,
indexed for recall, kept honest by dedupe + delete.

## One file = one fact

Each note has frontmatter + a body:

```markdown
---
name: <short-kebab-case-slug>
description: <one-line summary — used to judge relevance on recall>
metadata:
  type: user | feedback | project | reference
---

<the fact. For `feedback`/`project`, follow with **Why:** and **How to apply:** lines.
Link related notes with [[their-name]].>
```

## Types

- **`user`** — who the user is (role, expertise, preferences).
- **`feedback`** — guidance on *how the agent should work* (corrections + confirmed approaches); always
  include the **why**.
- **`project`** — ongoing work, goals, constraints not derivable from the code or git history; convert
  relative dates to absolute.
- **`reference`** — pointers to external resources (URLs, dashboards, tickets).

## The index — `MEMORY.md`

One line per memory, loaded into context **every session**:

```markdown
# Memory Index
- [Short title](slug.md) — one-line hook describing when it's relevant
```

Never put memory *content* in the index — only the pointer.

## Linking

`[[name]]` links to another memory's `name:` slug. Link liberally; a `[[name]]` with no file yet marks
something worth writing later (it's a TODO, not an error).

## Discipline

- Before saving, check for a file that already covers it — **update, don't duplicate**.
- **Delete** memories that turn out to be wrong.
- **Don't store what the repo already records** (code structure, past fixes, git history, the rules
  file). If asked to "remember" something derivable, capture only what was *non-obvious* about it.
- Recalled memories reflect what was true *when written* — re-verify file/flag/function names before
  relying on them.
- **Keep the index tiny** — `MEMORY.md` ≤ ~200 lines (it loads every session). Push detail into the
  per-fact files, never the index.

## Why it works

A long-term memory that is **append-cheap** (write a note mid-task without ceremony), **recall-scoped**
(the one-line `description` + `MEMORY.md` index let the agent pull only relevant notes), and
**self-correcting** (dedupe on write, delete on wrong). The split between a tiny always-loaded index and
on-demand full notes keeps the per-session context small while the knowledge base grows. This is the
same shape as the harness's native auto-memory (a small always-loaded index + on-demand topic files),
so it rides native rails rather than fighting them.

## Starters
Copy `docs/memory/MEMORY.md` (the index) and `docs/memory/_NOTE-TEMPLATE.md` (one note) into your
harness's project-memory directory to instantiate this — they are templates, not live memory.
