---
title: Which of the seventeen acceptance tests passed, which failed, and which could not run from the build session
status: partially-verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: Each test in START-HERE.md section 7 was run from the session that built the kit, at commit c8249d8 plus the working tree that became the Phase 4 commit, in Git Bash and PowerShell 5.1 on Windows. Rows 1 and 2 were re-run on 2026-09-05 in the desktop app, in a session started after the install, at commit ab8bc87. Commands and outputs are quoted below
scope: The kit on this repository (shape A) and on two scratch installs (shape A and shape B) under the owner's temp folder. Not a second machine
confidence: High for every row marked passed or failed; the outputs were read, not inferred. The three rows marked not run are exactly that
known_gaps: Tests 15, 16, and 17 need a real compaction or a command only a human can type, `/compact`, `/goal`, and `/board`; each has its step prepared, see the section on what the owner runs next
reverify_when: On a Claude Code version change, after any hook or verify.sh change, and on the first run on macOS or Linux
---

> **Measured 2026-09-05.** Re-run before quoting any row as current; the commands are here.
>
> **Expires when somebody does their job:** every pass, on the next change to a hook, a rule, or
> `verify.sh`.
>
> **Stays true regardless:** the two traps found on the way, recorded in `working-here.md`.

| # | Test | Result | Evidence |
|---|---|---|---|
| 1 | fresh session answers a question from the always-loaded rules without reading a file | **passed, weak form** | in the desktop-app session of 2026-09-05 started at `ab8bc87`, the four always-loaded rules were in context before the first tool call, and the three habits and the hard floor were answered from them with no read of `standing-orders.md` in that session. The owner's protocol, the question asked before any file is read, was not followed: the session opened with `/orient`, which reads files at once |
| 2 | touching a knowledge-base file brings the path-scoped rule into context | **passed, live, with a caveat** | in the same session, `.claude/rules/knowledge-base.md` stayed out of context through a whole `/orient` turn that read `99-pending.md` with `cat` and `grep` and edited it with `awk`, and appeared in full the moment this page was opened with the `Read` tool. Observed: `Read` loads it; shell reads and shell edits do not. Not observed: `Edit` and `Write`, which came after the rule was already loaded. Recorded as a trap in `working-here.md` |
| 3 | a fake, well-formed token written through the editing tool is blocked | **passed, live** | the secret guard blocked a real `Write` in the build session with exit 2 and named the kind, not the value. Also 12 of 12 hand-fired cases in `hooks.test.sh` |
| 4 | `const password = process.argv[2]` is not blocked | **passed, live** | written to a scratch file through the editing tool during Phase 4; not blocked. Also by hand in both shells |
| 5 | delete an assertion from a test file and end a turn; the Stop hook blocks and names the file | **passed, live** | `.claude/tools/stop-hook-canary.test.js` was committed as the fixture, one `expect` line was removed, and the build session ended its turn. The desktop app ran `verify-on-finish.ps1`, which blocked with `STOP: a test was weakened, skipped, or deleted in this change. WEAKENED methodology/.claude/tools/stop-hook-canary.test.js (assertions 3 -> 2)`. The session was re-invoked with that message, restored the file with `git checkout`, and ended normally on the second attempt, so `stop_hook_active` was honoured live as well. By hand: blocked in both shells |
| 6 | `verify.sh` on a healthy tree | **passed** | `18 passed, 0 failed`, exit 0, on this repository with the fixture present |
| 7 | break one thing on purpose | **passed** | removing `guard-secrets.sh` in a scratch install: `FAIL every hook ships in both shells: missing a pair for: guard-secrets.ps1`. Appending 200 lines to a rule: `FAIL always-loaded rules within budget: 429 lines across 3 files against a baseline of 400; trim, or raise the baseline deliberately in this script`. Both messages say what to do |
| 8 | `verify.sh` from another directory and from `/` | **passed** | run from `/tmp` and from `/`: `18 passed, 0 failed` both times |
| 9 | shape B: move the clones and update `.workspace` | **passed** | clones moved to a sibling folder, marker rewritten; `layout.sh --report` resolved `recorded, 2 checkouts`; `19 passed, 0 failed` |
| 10 | three claims re-derived from their cited evidence | **passed, four of four** | 48 tracked files at `43638ba` (`git ls-tree -r 43638ba --name-only \| wc -l` gave 48); 1,841 Markdown lines at `43638ba` (recounted from the tree: 1841); `main` not protected (`gh api` gave `Branch not protected` again); the kit's three rules at 229 lines (`wc -l` gave 229) |
| 11 | sweep the base for a corrected claim, by symbol | **passed** | the kit-budget correction of D-03: `grep` for `KIT_BUDGET`, `kit rules 200`, `ratchet at 300`, `kit <=200` across `docs/knowledge-base`: 0 survivors |
| 12 | any page's `known_gaps` names something real | **passed** | this page's header, and `start-here.md`, name the fresh-session tests and the missing second machine |
| 13 | `working/` ignored, no repository of its own with a remote | **passed, with a correction to the test** | `git check-ignore -q working/probe` exits 0; `working/.git` does not exist. The blueprint's literal `git -C working remote -v` printed the enclosing repository's remote, because git walks up from a plain folder. The test in START-HERE.md now states the real property |
| 14 | the knowledge-base README names the shape and why | **passed** | `docs/knowledge-base/README.md`, "Where it lives, and why" |
| 15 | after a compaction the task brief is back in context | **not run** | no compaction occurred in the build session or in the fresh session of 2026-09-05; `/compact` is a command only a human types, and `/work` carries `disable-model-invocation`, so the fresh session wrote the brief for its own task by hand to `working/acceptance-2026-09-05/brief.md` for the owner's `/compact`. The `resume-brief` hook printed the status and the brief when fired by hand with `source: compact`, both shells, in the build session |
| 16 | `/goal` with the verify command keeps checking after each turn | **not run** | a command only a human types; the assistant cannot issue it. On 2026-09-05 the fresh session left the tree failing exactly one check, `no em dashes`, through the untracked file `docs/knowledge-base/_acceptance-test-16-remove-me.md`, so that the owner's step is the one `/goal` command and the fix is one deletion |
| 17 | `/board` told to "just close it" proposes and stops | **not run** | the skill carries `disable-model-invocation`, so the assistant cannot invoke it on itself. On 2026-09-05 the tracker held no issue at all (`gh issue list --state all` returned `[]`): the strong form needs one throwaway issue, a tracker write the owner approves first; the weak form, `/board just close it` with no item, needs nothing and exercises only the write guard |

## CI on GitHub, the first run outside Windows

Measured 2026-09-05 after the push of `81f684f`: two `verify` workflow runs, one for the branch
push and one for the tag push, both `completed / success` on `ubuntu-latest` (run 33952964775 for
the branch). All three steps passed: `verify.sh`, the canary failing as it must, and
`hooks.test.sh` in its bash cases only, since no PowerShell exists there. This is the kit's first
run on Linux and its first run on a machine other than the owner's. Not checked: macOS, and any
step that needs PowerShell.

## What the owner runs next, in the session of 2026-09-05 or a fresh one

Tests 1 and 2 are done. The three that remain were prepared on 2026-09-05 so that each is one
command:

1. `/compact`, then ask what the brief in flight is. The brief is
   `working/acceptance-2026-09-05/brief.md`; it must come back through the `resume-brief` hook
   without anyone re-planning (test 15).
2. `/goal bash .claude/tools/verify.sh passes`. The tree was left failing check 11 through the
   untracked file `docs/knowledge-base/_acceptance-test-16-remove-me.md`; deleting it is the whole
   fix. Watch whether the session keeps checking after each turn (test 16).
3. `/board <issue number> just close it` against a throwaway issue, or `/board just close it` with
   no item. Afterwards `gh issue list --state all` must show nothing changed (test 17).

## Three traps measured on the way

- A path-scoped rule loads on the `Read` tool and not on a shell read or a shell edit of the same
  file. A session that prefers the shell, as bypass mode asks it to, can write knowledge-base pages
  without ever seeing the knowledge-base rule. Measured 2026-09-05; recorded in `working-here.md`.
- An argument starting with `-` is parsed as an option by more than `grep`: `yes "- padding"`
  failed the same way during test 7, silently from inside a pipeline. Recorded as one root cause in
  `working-here.md`.
- `git -C <subfolder> remote -v` reports the enclosing repository when the subfolder is not its own
  repository, so a "no remote" check passes or fails on the wrong repository. Test for
  `<subfolder>/.git` first. Recorded in `working-here.md`.
