---
title: How a Claude session says which task it is carrying, where the session id actually comes from, and the runs that prove the relay brief can no longer be restored as the agreement
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: The session id was measured live in this session, from the Bash tool environment and from a temporary PostToolUse hook installed in a gitignored settings file and then removed. The behaviour was exercised by hooks.test.sh in both shells, and the original defect was reproduced against the hook as it stood at commit 3019749 and then against the new one, on the same fixture
scope: The change decided as D-18: the active-task pointer, both hooks, baseline.sh, and the text that describes them. Not orchestration, not parallel work, not cleanup of stale pointers
confidence: High for what was measured here. Medium for the durability of CLAUDE_CODE_SESSION_ID, which the Claude Code documentation does not list among the variables it sets, so it may change without notice
known_gaps: The equality of the hook payload's session_id and CLAUDE_CODE_SESSION_ID was measured for PostToolUse only, on one build, on one machine. A real compaction was not forced, so the SessionStart payload was not observed live; the suite fires that hook by hand. Nothing was run on macOS or Linux, and shape B is not covered by a suite case
reverify_when: On a Claude Code version change, and before relying on the binding after any change to how hooks or the Bash tool are launched
---

## The defect

`/work` writes the owner's agreed brief to `working/<task>/brief.md`. `/codex-relay` later writes
its own `working/relay/<task>/brief.md`, and review normally happens after agreement, so the relay
file is the newer one. The compaction hook picked the newest `brief.md` in the tree and announced it
as "the task brief in flight, agreed with the owner". Reproduced on 2026-09-05 against the hook at
`3019749`, on a fixture whose relay brief is dated later:

```
The task brief in flight, working/relay/task-1/brief.md (agreed with the owner; do not re-plan it):
MARKER-relay a review brief written after the agreement
```

The same fixture, with the same file dates, after this change, in both shells:

```
The agreed task brief this session is carrying, working/task-1/brief.md (bound to this session when the owner said yes; do not re-plan it):
MARKER-agreed-task the owner said yes to this
```

The underlying gap was not the ordering rule. Nothing in the tree recorded which task a session was
carrying, so every reader had to infer one.

## Where the session id comes from, measured

| Question | Answer, measured 2026-09-05 |
|---|---|
| Does a hook receive a session id? | Yes. The hooks page lists `session_id` among the common input fields, and a temporary `PostToolUse` hook received `a0d7ea79-ee6b-433e-a4ca-93a27b873cec` |
| Does a Bash tool call see one? | Yes. `CLAUDE_CODE_SESSION_ID` is present in the Bash tool environment and held the same value |
| Are they the same value? | Yes, compared directly in one session: hook payload `session_id` equals `CLAUDE_CODE_SESSION_ID` |
| Is that variable documented? | No. The hooks page documents `CLAUDE_PROJECT_DIR`, `CLAUDE_PLUGIN_ROOT`, `CLAUDE_PLUGIN_DATA`, and `CLAUDE_EFFORT` for hook commands, and no session variable for the Bash tool |
| Is there another session-like value? | Yes, `CLAUDE_CODE_HOST_SESSION_ID`, a different value of the form `local_<uuid>`. It is not what hooks report and is not used |

The probe was a five-line PowerShell script that wrote its stdin to a scratch file, wired through
`.claude/settings.local.json`, which is gitignored. It fired on the next Bash call without a session
restart, which also measures that this build hot-loads hooks from a settings file. Both the probe
and the settings file were deleted afterwards.

Because the values are equal, `baseline.sh` reads the environment variable and writes the pointer
itself, and no new hook was needed to carry the value across. That is the whole reason the change
adds no fifth hook. The cost is an undocumented dependency, recorded above and in `99-pending.md`:
if the variable disappears, the seal says the brief was not bound and both hooks use their
fallbacks, so the failure is visible and safe rather than silent and wrong.

## The record

`working/active-tasks/<session id>`, one line:

```
working/<task>/brief.md
```

Nothing else: no JSON, no timestamps, no status. It is volatile coordination state under the
ignored `working/` folder, and it is never committed. The durable facts about the task live in the
brief's own front matter, which D-17 put there.

Written by `baseline.sh seal`, in the same step that seals the brief and only after the seal is on
disk, so a failed seal binds nothing. Replaced when the same session seals a different task, which
is how one session moves from one agreement to the next. Nothing else writes it: neither hook ever
does.

**Validation, in both shells.** The session id must match `^[A-Za-z0-9][A-Za-z0-9_-]{7,63}$` before
it is used as a file name, so it cannot carry a separator or a traversal. The line must match
`^working/[A-Za-z0-9][A-Za-z0-9._-]*/brief\.md$`, one task folder and one brief, which refuses a
relay path by shape (it has one more segment), an absolute path, and any `..` segment, whose first
character is not alphanumeric. The target must exist as a file. This is a shape check, not a
security boundary: the pointer lives in a folder the assistant can write.

## What each hook does now

**`resume-brief`**, on a compaction: read `session_id` from the payload, read the pointer, validate,
and print `working/status.md` plus that brief, described as the brief this session is carrying. No
scan, no recency. With no valid pointer it prints the newest `working/<task>/brief.md` one level
deep, which no relay brief can ever be, and says plainly that it is a guess and not this session's
agreement. A pointer that no longer resolves says so before falling back.

**`verify-on-finish`**, at the end of every turn: the same pointer, then that brief's
`baseline_commit.<checkout>`, then the test-integrity comparison from that commit. With no valid
pointer, no seal in the named brief, or no line for this checkout, it compares against `HEAD`, which
is what it did before the baseline existed. It never picks among sealed briefs, because choosing
would be the inference this change removes.

So the chain is one line: session id, active task brief, baseline commit, comparison.

## What became of the close lifecycle

`baseline.sh close` and the `closed_at` key are removed, and the hook no longer scans for sealed
briefs. D-17 introduced them only because the hook had to decide by itself which of several sealed
briefs was live; the pointer answers that directly. Two consequences worth stating:

- A builder can no longer retire its own baseline. Before, `close` was one command away from
  putting a committed weakening back behind `HEAD`. Now the binding moves only when the owner
  agrees another task and that new brief is sealed.
- Nothing retires a baseline at acceptance. After the owner accepts, the session keeps measuring
  against that task's commit until the next agreement or the end of the session. A legitimate test
  change in later unrelated work in the same session would block, naming the old brief. That is the
  same friction D-17 accepted, and it is recorded in `99-pending.md` rather than fixed here.

## The suite

`bash .claude/tools/hooks.test.sh`: **107 passed, 0 failed**, both shells, against 65 before this
change. Forty-two new checks: the resume section grew from 2 to 24, and the task-baseline section
of the Stop hook from 30 to 50.

| Case | What it proves |
|---|---|
| 1 | the pointer's brief is restored while a newer relay brief exists, and the relay content never appears |
| 2 | two sessions in one checkout each get their own brief, and neither reads the other's |
| 3 | a Stop event for session A blocks on A's baseline while session B, sealed after the weakening, does not block, and A's finding names only A's brief |
| 4 | a newer unrelated task brief does not win over the pointer |
| 5 | a pointer whose target is gone says so and falls back, with no crash and no other file read |
| 6 | with no pointer at all, resume restores the newest task brief and calls it a guess, the relay brief still cannot win, and the Stop hook compares against `HEAD` |
| 7 | a pointer naming a relay path, and one naming a path outside the project, are both refused by resume and by the Stop hook |
| 8 | sealing another task in the same session moves that session to it, with no timestamp involved |

The D-17 coverage is intact and still runs: committed weakening, staged rename with an assertion
removed, a test added during the task and then weakened, a rebased baseline compared from its
merge-base, a nonexistent baseline commit, pre-existing work recorded, front matter preserved, the
digest catching a brief edited after approval, and the refusal to seal twice.

One test failed on the first run and the failure was correct: the second shell pass tried to seal a
task the first pass had already sealed, and the new rule refused it. The case now uses a fresh task
per shell.

The review then mutated the shipped hooks, one change at a time, and ran the suite against each
copy, because a case that cannot go red proves nothing. Four mutations, four reds:

| Mutation | Result |
|---|---|
| the resume fallback searches one level deeper again, so relay briefs are candidates | 4 failed |
| the Stop hook stops validating the pointer's shape and follows whatever it names | 4 failed |
| resume ignores the pointer and takes the newest brief | 6 failed |
| `seal` never writes the pointer | 25 failed |

The first two were green against the first version of these cases, which is how the review found
them: the fixture gave the relay brief and the decoy the same modification time, so the relay lost
by the spelling of its path rather than by the rule, and the refusal cases asserted only an exit
code that the wrong behaviour also produces. The relay brief is now strictly newer, both decoys are
sealed at the baseline so following either would block, the traversal target exists so only the
shape check can refuse it, and every absence check carries a positive half.

## What the review corrected in the hooks

Three reviewers read the change against the tree and ran the two shells side by side. Nine
corrections landed before it was committed. Four were parity breaks that would have made the two
shells disagree about the same repository: PowerShell matched patterns case-insensitively, so a
pointer spelled `WORKING/t/brief.md` bound in one shell and not the other; a short or malformed
commit value threw inside `Substring` and killed the whole PowerShell hook at exit 1; the
PowerShell test-file pattern required a separator before `tests/`, so a repository-root `tests/`
folder was unguarded there; and the two assertion counters disagreed because only one had word
boundaries, so `submit(` counted as `test(` in Bash. Two were Bash parsing faults: an unanchored
`grep -F` let a line that merely mentioned a key win over the real one, and a trailing space after
a commit value produced an empty value with no note. Two were honesty defects in the text: the
hooks claimed every fallback prints a note when two are deliberately quiet, and `resume-brief` said
nothing at all when a stale pointer had no fallback to offer, which is the one case where a session
silently loses its agreement. The last was recovery: a failed pointer write left a sealed brief
that could never be bound, since a seal cannot be repeated; it now prints the one line that fixes
it.

## What can be said, and what cannot

True after this change: the active task is explicitly associated with a Claude session; both hooks
use that association when it is present; a relay brief cannot become the active task by being
newer; two sessions sharing a checkout have separate pointers; a failed seal binds nothing.

One boundary measured while reviewing this change: a subagent runs with its parent's
`CLAUDE_CODE_SESSION_ID`, so a subagent that sealed a brief would move the parent's binding. No
skill dispatches a subagent that seals, and `/codex-relay` runs read-only, so nothing in the kit
does this today. It is in `99-pending.md`.

Not true, and not to be written anywhere: that the kit knows all work happening in the checkout;
that there is any concurrency control; that sessions cannot interfere through git; that the pointer
is a security boundary; that stale pointers are cleaned up, since nothing removes them; that a
subagent is a separate session; or that the fallback carries the same guarantee as an explicit
binding. The fallback is a guess and says so.
