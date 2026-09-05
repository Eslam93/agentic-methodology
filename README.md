# Agentic methodology

A Claude Code **harness** and a **knowledge base** format for building software with an AI
assistant doing most of the editing. The human owns direction. An independent review owns judgment.
Deterministic checks own facts. Everything else is advice, and it says so.

Two doors. Pick one.

## I want the kit

Four rules, ten skills, four hooks, five tools. Install is a copy.

```bash
git clone https://github.com/Eslam93/agentic-methodology kit
bash kit/.claude/tools/install.sh <your-repo> --shape A          # one repository
bash kit/.claude/tools/install.sh <workspace> --shape B --repos <clones>   # several
```

Then open Claude Code there, start a new session, and say: *read START-HERE.md in `kit/` and
follow it.* The assistant asks you the eleven questions it cannot answer from the code, measures
the rest, writes the project rule, and runs the acceptance tests.

What you get:

| | |
|---|---|
| `/orient` | where things stand at the start of a session, in five lines, then it stops |
| `/work` | a task from a description, a GitHub issue, or an Azure DevOps item: understand, one yes, an uninterrupted build, a review menu, a hand-back with evidence |
| `/record` `/handoff` | durable facts into the knowledge base with evidence; volatile status into a disposable `working/` folder |
| `/codex-relay` | an optional second model, read-only, briefed in full, answering verdict first |
| `/test-guide` `/pr` `/board` | plain-English test steps, a well-formed pull request, a tracker update that proposes and stops |
| `/explain` `/summarize` | the real version, and the short version, without losing the caveats |
| four hooks | a secret value is blocked before it is written; a weakened test blocks the turn; a destructive-command list that starts empty; the task brief re-read after a compaction |
| `verify.sh` | the checks that exist here, a canary that must fail, and a hook test suite that proves the guards can go red |

Windows first: every hook ships in PowerShell and Bash. Measured on the desktop app and Git Bash.

## I want the why

Version 1 of this methodology was documents a project fills in: a per-task flow, a constitution
built into `AGENTS.md`, design notes, ADRs, a worklog, a resume file, an escape log, a promotion
ledger, a memory system. Complete, and reachable at tag `v1.5.1`. In real use the documents were
filled in and not read. Version 2 keeps the theory and deletes the documents: what survives lives
as rule lines a session loads, skill beats a session runs, and checks a script can fail.

The knowledge base is the second half. Its rules were paid for by named failures: a refuted claim
that survived five correction passes, a stale claim quoted as current months after the fix. Every
substantial page carries when its facts were gathered, how they were verified, and what was not
checked. A changeable condition is never asserted in the present tense.

Where the reasoning is:

- [`docs/knowledge-base/00-orientation/start-here.md`](docs/knowledge-base/00-orientation/start-here.md): what this project is and the facts that save confusion
- [`docs/knowledge-base/decisions.md`](docs/knowledge-base/decisions.md): every decision in force, what each superseded, when to revisit it
- [`docs/knowledge-base/00-orientation/evidence-and-verification-rules.md`](docs/knowledge-base/00-orientation/evidence-and-verification-rules.md): how a claim is written so it is still true in a year
- [`docs/knowledge-base/_readings/`](docs/knowledge-base/_readings/): the sources, with what was taken and what was not
- [`docs/knowledge-base/00-orientation/what-we-do-not-know.md`](docs/knowledge-base/00-orientation/what-we-do-not-know.md): the gaps, by root cause

This repository runs the kit on itself: `.claude/` here is both the source adopters copy and the
live harness it is maintained with. The kit was derived from three real installations, one of them
the owner's own site in daily use since 2026-08; that repository, `Eslam93/Portfolio`, is the
worked example whenever it is public.

## The limits, stated once

Nothing here has been shown by comparison to help. The measurements are one maintainer's, on
Windows, dated in the knowledge base. The hooks see the editing tools and the two shells, nothing
else. If you install it, write your own limits down the same way.

License: MIT.
