---
title: Which of the seventeen acceptance tests passed, which failed, and which could not run from the build session
status: partially-verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: Each test in START-HERE.md section 7 was run from the session that built the kit, at commit c8249d8 plus the working tree that became the Phase 4 commit, in Git Bash and PowerShell 5.1 on Windows. Commands and outputs are quoted below
scope: The kit on this repository (shape A) and on two scratch installs (shape A and shape B) under the owner's temp folder. Not a second machine
confidence: High for every row marked passed or failed; the outputs were read, not inferred. The five rows marked not run are exactly that
known_gaps: Tests 1, 2, 15, 16, and 17 need a session started after the install, a real compaction, or a command only a human can type
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
| 1 | fresh session answers a question from the always-loaded rules without reading a file | **not run** | the build session started before the rules existed; the owner runs this in the next session |
| 2 | touching a knowledge-base file brings the path-scoped rule into context | **not run** | same reason |
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
| 15 | after a compaction the task brief is back in context | **not run** | no compaction occurred in the build session. The `resume-brief` hook printed the status and the brief when fired by hand with `source: compact`, both shells |
| 16 | `/goal` with the verify command keeps checking after each turn | **not run** | a command only a human types; the assistant cannot issue it |
| 17 | `/board` told to "just close it" proposes and stops | **not run** | the skill carries `disable-model-invocation`, so the assistant cannot invoke it on itself; the owner runs it against a real item |

## CI on GitHub, the first run outside Windows

Measured 2026-09-05 after the push of `81f684f`: two `verify` workflow runs, one for the branch
push and one for the tag push, both `completed / success` on `ubuntu-latest` (run 33952964775 for
the branch). All three steps passed: `verify.sh`, the canary failing as it must, and
`hooks.test.sh` in its bash cases only, since no PowerShell exists there. This is the kit's first
run on Linux and its first run on a machine other than the owner's. Not checked: macOS, and any
step that needs PowerShell.

## What the owner runs next, in a fresh session on this repository

1. Ask, before any file is read: *"what are the three habits, and what is the hard floor?"* The
   answer must come from context (test 1).
2. Edit any file under `docs/knowledge-base/` and ask what the claim-type table says. The
   path-scoped rule must be in context after the edit and not before (test 2).
3. Work a small task with `/work` until a brief exists in `working/<task>/brief.md`, run
   `/compact`, and check the brief is back without re-planning (test 15).
4. `/goal bash .claude/tools/verify.sh passes` on a tree where it does not, and watch whether the
   session keeps checking (test 16).
5. `/board` on any issue with the words "just close it" (test 17).

## Two traps measured on the way

- An argument starting with `-` is parsed as an option by more than `grep`: `yes "- padding"`
  failed the same way during test 7, silently from inside a pipeline. Recorded as one root cause in
  `working-here.md`.
- `git -C <subfolder> remote -v` reports the enclosing repository when the subfolder is not its own
  repository, so a "no remote" check passes or fails on the wrong repository. Test for
  `<subfolder>/.git` first. Recorded in `working-here.md`.
