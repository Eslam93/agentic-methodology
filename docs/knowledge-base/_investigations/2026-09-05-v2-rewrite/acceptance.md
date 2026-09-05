---
title: Which of the seventeen acceptance tests passed, which failed, and which could not run from the build session
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: Each test in START-HERE.md section 7 was run from the session that built the kit, at commit c8249d8 plus the working tree that became the Phase 4 commit, in Git Bash and PowerShell 5.1 on Windows. Rows 1 and 2 were re-run on 2026-09-05 in the desktop app, in a session started after the install, at commit ab8bc87; rows 15 and 16 ran in the same session at 773584b, on the owner's `/compact` and `/goal`, and row 17 at 46de369 on the owner's `/board`. Commands and outputs are quoted below
scope: The kit on this repository (shape A) and on two scratch installs (shape A and shape B) under the owner's temp folder. Not a second machine
confidence: High for every row; the outputs were read, not inferred. Row 1 passed only in its weak form, stated on the row
known_gaps: Every row ran on one machine, one Claude Code version, in the desktop app. For test 16, the goal page read on 2026-09-05 says the evaluator judges the conversation and runs nothing (../../_readings/claude-code-docs-2026-09-05.md); this was not observed directly. For test 17, only GitHub through `gh`, not Azure DevOps
reverify_when: On a Claude Code version change, after any hook or verify.sh change, and on the first run on macOS or Linux
---

> **Measured 2026-09-05.** Re-run before quoting any row as current; the commands are here.
>
> **Expires when somebody does their job:** every pass, on the next change to a hook, a rule, or
> `verify.sh`.
>
> **Stays true regardless:** the three traps found on the way, recorded in `working-here.md`.

| # | Test | Result | Evidence |
|---|---|---|---|
| 1 | fresh session answers a question from the always-loaded rules without reading a file | **passed, weak form** | in the desktop-app session of 2026-09-05 started at `ab8bc87`, the four always-loaded rules were in context before the first tool call, and the three habits and the hard floor were answered from them with no read of `standing-orders.md` in that session. The owner's protocol, the question asked before any file is read, was not followed: the session opened with `/orient`, which reads files at once |
| 2 | touching a knowledge-base file brings the path-scoped rule into context | **passed, live, with a caveat** | in the same session, `.claude/rules/knowledge-base.md` stayed out of context through a whole `/orient` turn that read `99-pending.md` with `cat` and `grep` and edited it with `awk`, and appeared in full the moment this page was opened with the `Read` tool. Observed: `Read` loads it; shell reads and shell edits do not. Not observed: `Edit` and `Write`, which came after the rule was already loaded. After the real compaction of the same day the rule was out of context again at the start of the next turn, although the post-compaction resume had re-read three knowledge-base pages; the first `Read` call of that turn brought it back. Recorded as a trap in `working-here.md` |
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
| 15 | after a compaction the task brief is back in context | **passed, live** | on 2026-09-05 the owner typed `/compact` in the desktop-app session at `773584b`, with the brief written by hand to `working/acceptance-2026-09-05/brief.md` because `/work` carries `disable-model-invocation`. The `resume-brief` hook fired on the real compaction and printed `working/status.md` and the brief verbatim into the first turn after it, under its own heading "After compaction. Re-read before continuing"; the assistant named the brief, its tier, and its five outcome lines from that output without reading either file. Caveat: the compaction summary also carried an outline of the brief, so what the hook added was the verbatim text, not the fact that a brief existed. By hand with `source: compact`, both shells, in the build session |
| 16 | `/goal` with the verify command keeps checking after each turn | **passed, live** | on 2026-09-05 the owner typed `/goal bash .claude/tools/verify.sh passes` in the desktop-app session at `773584b`, with the tree failing exactly one check, `no em dashes`, through the untracked file `docs/knowledge-base/_acceptance-test-16-remove-me.md`. The session ran `verify.sh` (`17 passed, 1 failed`, exit 1) and ended its turn on purpose without the fix, so that the check could go red. The stop was blocked by a message headed with the condition that quoted the failing check, the counts, the exit code, and the assistant's own sentence about ending the turn. The next turn deleted the file and `verify.sh` gave `18 passed, 0 failed`, exit 0. Whether the goal then cleared is visible to the owner at the end of that turn, not to the session. Not observed: whether the evaluator ran the command itself or read the transcript's quotation of it. Settled from the documentation on 2026-09-05: the goal page says the evaluator "doesn't run commands or read files independently", so it judged the quotation (`../../_readings/claude-code-docs-2026-09-05.md`) |
| 17 | `/board` told to "just close it" proposes and stops | **passed, live** | on 2026-09-05 the tracker held no issue at all (`gh issue list --state all` returned `[]`), so the owner approved one throwaway issue, `Eslam93/agentic-methodology#1`, "Acceptance test 17 fixture", created at 08:04:57Z, then typed `/board 1 just close it` in the desktop-app session at `46de369`. The skill's turn read the item from the server with `gh issue view 1`, proposed the close with the closing comment written out, and ended on a question. `gh issue list --state all --json number,state,updatedAt` in the next turn returned `OPEN`, `2026-09-05T08:04:57Z`, unchanged. After the owner's yes the comment and the close were applied one call each and read back: `CLOSED`, reason `COMPLETED`, closed at `2026-09-05T08:06:38Z`, one comment. Not exercised: Azure DevOps, custom fields, an item with existing comments or a parent, and the weak form with no item |

## CI on GitHub, the first run outside Windows

Measured 2026-09-05 after the push of `81f684f`: two `verify` workflow runs, one for the branch
push and one for the tag push, both `completed / success` on `ubuntu-latest` (run 33952964775 for
the branch). All three steps passed: `verify.sh`, the canary failing as it must, and
`hooks.test.sh` in its bash cases only, since no PowerShell exists there. This is the kit's first
run on Linux and its first run on a machine other than the owner's. Not checked: macOS, and any
step that needs PowerShell.

## Three traps measured on the way

- A path-scoped rule loads on the `Read` tool and not on a shell read or a shell edit of the same
  file, and after a compaction it is out of context again until the next `Read`. A session that
  prefers the shell, as bypass mode asks it to, can write knowledge-base pages without ever seeing
  the knowledge-base rule. Measured 2026-09-05; recorded in `working-here.md`.
- An argument starting with `-` is parsed as an option by more than `grep`: `yes "- padding"`
  failed the same way during test 7, silently from inside a pipeline. Recorded as one root cause in
  `working-here.md`.
- `git -C <subfolder> remote -v` reports the enclosing repository when the subfolder is not its own
  repository, so a "no remote" check passes or fails on the wrong repository. Test for
  `<subfolder>/.git` first. Recorded in `working-here.md`.
