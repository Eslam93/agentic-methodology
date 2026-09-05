# Agentic methodology

**v2 is being rebuilt on this branch. The complete v1 is reachable at tag `v1.5.1`, commit `43638ba`.**

v2 replaces the documentation layer of v1 with two things: a Claude Code **harness** (rules, skills,
hooks, and tools under `.claude/`) and a **knowledge base** of dated, evidence-backed facts under
`docs/knowledge-base/`. The decisions behind the rewrite and the measurements it rests on are already
recorded in the knowledge base. The kit itself, the entry point for assistants (`START-HERE.md`), and
the two-door version of this README land in the next phases.

Where things are right now:

- [`docs/knowledge-base/00-orientation/start-here.md`](docs/knowledge-base/00-orientation/start-here.md): what this project is and the facts that save confusion
- [`docs/knowledge-base/decisions.md`](docs/knowledge-base/decisions.md): every decision in force, dated, with what it superseded
- [`docs/knowledge-base/99-pending.md`](docs/knowledge-base/99-pending.md): what is open

License: MIT.
