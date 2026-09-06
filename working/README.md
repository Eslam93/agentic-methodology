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
| `active-tasks/<session id>`: one line naming the brief this Claude session is carrying, written by `baseline.sh seal`. Volatile coordination state, never durable knowledge | |
| `<task>/test-guide.md`: the plain-English test steps for the task in flight | a secret value: nowhere, ever |
| `documents/<slug>.md`: proposals, specs, plans, anything we intend to do | |
| `evidence/`: command output you are reading once | |

The knowledge base never links into this folder. Promotion runs one way, inward: when something
here turns out to be durable, `/record` it with its evidence and delete it here.

## What survives, and where

**Recovery is guaranteed within this checkout, and only within it.** After a compaction,
`resume-brief` restores the brief of the task this session is carrying, and the Stop hook measures
from that task's baseline, because both read `active-tasks/<session id>` here.

**A linked git worktree starts with none of this.** Everything in this folder is ignored by git, so
`git worktree add` gives you a checkout with no `working/` at all: no brief, no pointer, no
pre-existing list. The tools handle that correctly rather than guessing, which means they fall back:
the Stop hook compares against `HEAD` and says so, and the resume hook has nothing to restore. So a
task agreed in one worktree is not carried into another, and nothing here is shared between them.

That is a real limit, not an accident. Copying this folder between worktrees would make two
checkouts share one task identity and one baseline, and the pointer is deliberately per session, not
per machine. **Cross-worktree handoff is not guaranteed and is not attempted.** If you move to a
worktree mid-task, agree the task again there and seal it: `git` carries the code, this folder does
not travel. Whether it should is a decision nobody has taken; it is recorded in `99-pending.md`.

If this folder ever gets a git remote, that is a bug. `verify.sh` checks for it.
