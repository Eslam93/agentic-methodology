# working/

**Yours, local, disposable. Never committed and never pushed.** Everything in this folder is
ignored by git except this file.

What lives here, and what does not:

| Here | Not here |
|---|---|
| `status.md`: where the last session got to, rewritten by `/handoff` | a finding about how the project works: the knowledge base, via `/record` |
| `handoffs/<date>-<slug>.md`: one file per session handover | something noticed and not acted on: `99-pending.md` in the knowledge base, one line, same turn |
| `<task>/brief.md` and `<task>/phases/`: the agreed brief and phase briefs for the task in flight, read back after a compaction | an idea about the harness: `99-pending.md` too |
| `<task>/pre-existing.txt`: the files that were already dirty when the brief was sealed. They belong to the owner and stay out of task commits | |
| `<task>/test-guide.md`: the plain-English test steps for the task in flight | a secret value: nowhere, ever |
| `documents/<slug>.md`: proposals, specs, plans, anything we intend to do | |
| `evidence/`: command output you are reading once | |

The knowledge base never links into this folder. Promotion runs one way, inward: when something
here turns out to be durable, `/record` it with its evidence and delete it here.

If this folder ever gets a git remote, that is a bug. `verify.sh` checks for it.
