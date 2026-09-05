---
title: What the sealed task baseline records, what the Stop hook mechanically detects since it, what /work only instructs, and the runs that proved the two cases a HEAD comparison cannot detect
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: hooks.test.sh run in both shells on the owner's Windows machine on 2026-09-05, plus scratch repositories in which each case was fired by hand and the hook's stderr captured; the outputs are quoted below. The design was reviewed by eight finder subagents and twelve verifiers against the working tree, each reproducing its candidate in a scratch repository before it was accepted
scope: The change decided as D-17: baseline.sh, the two verify-on-finish hooks, the hook test suite, and the /work, /pr, codex-relay, and standing-orders text. Not the active-task pointer, the review contract, or any waiver
confidence: High for what the tests and the runs showed; each is a command and its output. The live Stop hook on the desktop app was not observed against a committed weakening in a real session
known_gaps: Only JavaScript-shaped fixtures were exercised; the assertion heuristics are unchanged and still JavaScript and C# shaped. Shape B with several checkouts was exercised by hand in a scratch workspace, not by the suite. Nothing was tried on macOS, whose bash is 3.2. Nothing kept only in the disposable working/ folder can be made tamper-proof against the builder who can write there: the guards below raise the cost of the obvious routes and do not remove the class
reverify_when: On any change to baseline.sh, either verify-on-finish hook, or hooks.test.sh; before quoting the case count
---

> **Amended twice on the same day.** Task Integrity 1.1 closed two holes in what this change
> shipped: the seal metadata itself was outside every digest, so `baseline_commit` could be moved
> to a later commit with the approved body untouched; and a test added during the task could be
> weakened and the weakening committed, which made it invisible. Both are fixed and both have
> cases. The sentences below that described the old behaviour are marked. See "Task Integrity
> 1.1" at the end of this page.
>
> **Amended the same day by D-18.** This page records what this change shipped, in the past tense
> where D-18 replaced it hours later: the Stop hook no longer reads every sealed brief and decides
> which are open, and `baseline.sh close` and the `closed_at` key are gone. A session-scoped pointer
> now names the one brief whose baseline applies, and the fallback rules below are unchanged. The
> sentences that describe the replaced parts are marked. See
> `../2026-09-05-active-task/methodology.md`.

## What changed, and where

| File | Change |
|---|---|
| `.claude/tools/baseline.sh` | new: `seal`, `check`, and (until D-18) `close`, writing into the brief's front matter |
| `.claude/hooks/verify-on-finish.sh`, `.ps1` | compare test files against the sealed brief's commit, with rename detection and an added-file case; fall back to `HEAD` or a merge-base with a note; the workspace marker now wins over `.git` at cwd |
| `.claude/tools/hooks.test.sh` | 35 new cases: 15 per shell plus 5 for the tool; the scratch repository ignores `working/` and carries a multi-line fixture |
| `.claude/skills/work/SKILL.md` | step 3 seals the brief; step 5 keeps commits on task-owned paths and leaves pre-existing files alone; step 7 checks the digest before reporting, and closed the baseline at acceptance until D-18 removed that step |
| `.claude/skills/pr/SKILL.md` | the clean-tree precondition no longer tells the assistant to commit or stash the owner's pre-existing files |
| `.claude/skills/codex-relay/SKILL.md` | "the last checkpoint commit" becomes the task baseline; the relay's own point is no longer called a baseline |
| `.claude/rules/standing-orders.md` | seal before an autonomous run, or commit a checkpoint when there is no brief to seal |
| `README.md`, `working/README.md` | the tool and the two files named, with the fallback stated |

## The record

`baseline.sh seal <task>` writes front matter at the top of `working/<task>/brief.md`, the file the
owner approved, and keeps any front matter the brief already had (D-19: the command takes the tier,
`seal <task> <tier>`, records it as a `tier:` line, and strips any `review_` key the brief arrived
with):

```yaml
task: <slug>
approved_at: <UTC, ISO seconds>
tier: <1|2|3>                                 # added by D-19
baseline_commit.<checkout>: <full commit>     # one line per checkout
brief_sha256: <sha256 of the text below the front matter>
pre_existing: <count>
seal_sha256: <sha256 of all of the above>     # added by Task Integrity 1.1
closed_at: <UTC>                              # added by close; removed by D-18
```

`working/<task>/pre-existing.txt` beside it holds `git status --porcelain --untracked-files=all`
at approval, one line per change, prefixed by the checkout name. It is a list, not metadata:
nothing reads it but the owner and `/work`. Both files sit under `working/`, which git ignores.

**Why the metadata is in the brief and not in a state file.** The first build of this change put it
in `working/<task>/baseline`, a sidecar with its own lifecycle, and the hook picked the newest
unclosed one by modification time. The owner rejected that on the day: one agreed task owns one
baseline, and a later check should know which task it is evaluating rather than choose among
candidates. Putting the three values in the brief's own front matter removes the choice, because
`check` is given the task by name and the hook names the brief in every finding; it also means the
values survive a compaction, since `resume-brief` already prints the brief. The tool remains,
because three values must be produced the same way every time: the commit from `git rev-parse`, the
digest over the same bytes at seal and at check, and the dirty files captured before the first
edit.

This task's own seal was taken on a clean tree at `7f8620b` on 2026-09-05T12:13:54Z and then moved
from the sidecar into the brief. The digest recomputed byte for byte as
`7c48a83b3b5f44381fa0e266a6cf628038087b845afba29ba13ece7ca5db8686`, which is the evidence that the
baseline itself did not move: only where it is stored changed.

## What is enforced, what is instructed, what is not verified

**Mechanically detected (layer c).** For each brief carrying an unclosed seal, and each checkout
it names, which D-18 narrowed to the one brief this session carries, the Stop hook runs
`git diff --name-status -M <commit>` against the working tree, so every change since approval
counts, committed or not. A test file (`.test.`, `.spec.`, `Tests.cs`, under
`tests/` or `__tests__/`) that is deleted, that lost assertion markers, that gained skip markers, or
that was renamed and lost assertions, blocks the turn with exit 2. Every finding names the commit
and the brief it was measured against. A test file added during the task has no version at the
baseline, so it is compared against `HEAD`, which is what the hook did before this change.

**Fallback (layer c).** No brief with an open seal, or none naming this checkout, which D-18
restated as no pointer for this session or none naming this checkout: compare against `HEAD`,
exactly as before. A sealed commit rewritten by a rebase, amend, or squash: compare from
`git merge-base <sealed> HEAD`, so the weakening stays visible. A sealed commit that does not exist
in the checkout at all: `HEAD`. Each fallback prints a note; none of them blocks, and the hook never
writes a baseline.

**Instructed only (layer b).** That `/work` seals at the yes and checks the digest at hand-back;
that a changed agreement becomes a new task brief rather than a moved seal. Refusing to seal twice
closed the explicit path; it did not stop a hand edit, which is what Task Integrity 1.1 closed; that commits use
`git add -- <paths>` and never sweep the files in `pre-existing.txt`; that an edit to a pre-existing
file is asked about once. No hook checks any of these. In particular, nothing stops `git add -A`;
`guard-commands` has no entry for it, by D-11. Closing a baseline early was a hole here and is gone
with `close` itself, under D-18.

**Not verified.** The live Stop hook on the desktop app against a committed weakening in a real
session. Shape B end to end: the marker-wins ordering was fixed and fired by hand in a scratch
workspace, but no suite case covers a workspace.

## The suite, 2026-09-05

`bash .claude/tools/hooks.test.sh` when this change landed: **65 passed, 0 failed**, both shells,
against 30 before it. The count moved again within the day, to 107, when D-18 replaced the
open-seal scan and the review strengthened several cases; the current cases are listed on that
page. What this change added and D-18 kept:
seal recorded the commit in the brief · the approved text survives sealing · sealed clean tree
allowed · committed weakening blocked · the block names the task baseline · staged rename plus
removed assertion blocked · the block names the rename · a test added during the task then weakened
blocked · rebased task branch compared from its merge-base · the rewritten baseline is announced ·
a nonexistent baseline commit falls back to HEAD · the fallback is announced · seal records a
pre-existing untracked file · seal keeps front matter the brief already had · seal refuses to
re-seal a sealed brief · check passes on an unchanged brief · check detects a brief changed after
approval.

The first run of the new cases failed nine times, all in the tests, not the hooks: `git mv` has no
`-q`; the scratch repository did not ignore `working/`, so `git add -A` staged the seal and
`reset --hard` deleted it; a one-line fixture was too dissimilar after one change for git to record
a rename; two assertions read `$?` after an arithmetic step. Recorded because a suite that goes red
for the wrong reason and is then made green is the case the canary rule exists for.

## The two cases, fired by hand

A scratch repository with a nine-line `tests/z.test.js` (five assertion markers), sealed at its
first commit `8b2946d`.

**Committed weakening.** One `expect` line removed, `git commit -am weaken`. `git diff
--name-status HEAD` printed nothing: the comparison this change replaced had nothing left to see.
Both hooks, exit 2:

```
STOP: a test was weakened, skipped, or deleted.

  WEAKENED demo/tests/z.test.js  (assertions 5 -> 4) since the task baseline 8b2946d (working/demo/brief.md)
```

**Staged rename.** Back at the fixture: `git mv tests/z.test.js tests/w.test.js`, one `expect` line
removed, `git add -A`. `git diff --name-status -M <baseline>` printed
`R084	tests/z.test.js	tests/w.test.js`. Both hooks, exit 2, naming the rename.

## What the review found, and what it changed

A fresh-context review at high effort ran eight finder angles and twelve verifiers against the
working tree; every accepted finding was reproduced in a scratch repository first. Nine held and
were fixed in this change:

1. **A test added during the task was invisible.** `A` in the diff was handled by no branch, so a
   test the task committed and then weakened passed. Fixed by comparing an added file against
   `HEAD`, and covered by a case.
2. **A closed task hid every open one.** The selector took the newest file and dropped it if
   closed, and `close` bumped that file's modification time. The fix removed the selector; D-18 then
   removed closing itself, so the case that proved it became the two-session isolation case.
3. **The hooks classified a shape-B root as shape A.** They tested `.git` before `.workspace`, so a
   workspace root, which is itself a checkout by D-02, was inspected alone and its clones never
   were. The ordering was pre-existing; the tool disagreeing with it was new. Both now let the
   marker win, as `layout.sh` does.
4. **A checkout name with a space or a regex character broke the bash hook.** The sha was taken with
   `cut -d' ' -f2` and the name interpolated into `grep -E`. The value is now the last field and the
   key is matched literally, in both shells.
5. **`seal` wrote its own error into the record.** The failure path ran inside the redirected group,
   leaving a partial file and printing nothing. It now validates first and writes the file whole,
   through a temporary file.
6. **A rebase silently dropped the protection.** A rewritten sealed commit fell back to `HEAD`. It
   now falls back to the merge-base, which `codex-relay` already did for its own point, and a case
   covers it.
7. **Documents contradicted the change:** `codex-relay` still named a checkpoint commit and used
   "baseline" for two different commits; `/pr` told the assistant to commit or stash the owner's
   pre-existing files; the standing orders told a Tier 1 task with no brief to seal; nothing ran
   `baseline.sh check`. All four are fixed in the text.
8. **Redundant and dead code:** `cat-file -e` before `merge-base --is-ancestor` changes no outcome,
   the header named only the first checkout's comparison base, and `show` had no caller. Removed;
   the base is now named per finding.
9. **Portability:** `sed -i` and `mapfile` are GNU and bash 4 only. Both are gone from the tool and
   the suite.

Two findings were recorded rather than fixed, because they belong to other work and are now in
`99-pending.md`: the PowerShell hooks cannot resolve the MSYS-form `WS_REPOS` path that `install.sh`
writes on Git Bash, and every note the hook prints on exit 0 reaches the debug log only, per the
hooks documentation, so no fallback note reaches the assistant.

## Limits found on the way

- A rename that changes more than half the file is a delete plus an add to git, so it blocks as
  `DELETED`, which is the right outcome with a less precise label.
- `hooks.test.sh` itself matches the hook's test-file pattern, so the hook counts its own `test(`
  and `expect(` strings; adding cases raised the count, and removing cases would read as a
  weakening. Harmless here, and a reminder that the heuristic is lexical.
- **Corrected by Task Integrity 1.1.** `brief_sha256` covers the text below the front matter only,
  so at first nothing covered the seal metadata itself. There are now two digests, and the section
  below says which protects what.
- A merge or pull that legitimately deletes a test keeps blocking for the rest of the session, since
  D-18 leaves no way to retire a baseline early and a seal cannot move. That is the friction D-17
  accepted; the block names the file, and a real incident is what would earn a waiver.

## Task Integrity 1.1, the same day

Two gaps in the implementation of what D-17 and D-18 decided, found by the owner reading the pushed
tree. Neither was a reason to change the design, and neither did.

### The approved starting point could be moved by hand

`brief_sha256` covers the body below the front matter, which answers "is the agreement still the
text that was approved". Nothing covered the front matter, which is where the approval itself lives.
So an edit from

```text
baseline_commit.repo: A
```

to a later commit `B` left the body untouched, the body digest happy, and `check` reporting "brief
unchanged since approval" while every weakening between `A` and `B` disappeared from what the Stop
hook could see. Reproduced before the fix: with the true baseline the hook exited 2, and after the
one-line edit it exited 0 and `check` exited 0 as well. Removing `--force` had closed the explicit
re-seal path and left this one open.

`seal_sha256` now covers the approval fields, and only those:

| Protected by `brief_sha256` | Protected by `seal_sha256` | Deliberately mutable |
|---|---|---|
| the brief body, which is the agreement | `task`, `approved_at`, `tier`, every `baseline_commit.<checkout>`, `brief_sha256`, `pre_existing` | `review_status`, `review_route`, `review_evidence`, `review_waiver`, `review_at`, and any front matter the brief already carried |

The third column is the point of having two digests rather than hashing the whole front matter: the
Tier 3 review record is written later in the task, by design, and must not invalidate the approval.
A case proves that recording a waiver after sealing is not read as tampering.

The canonical input is a fixed field order, one `key: value` line each with a single space after the
colon and the value trimmed, the per-checkout lines sorted by bytes, and a trailing newline, hashed
as UTF-8. It is written to the brief in exactly that order, so the bytes behind the digest are the
bytes on the page. Three implementations must agree: `baseline.sh`, and both Stop hooks. The
PowerShell twin sorts with `StringComparer.Ordinal` rather than the culture sort, because
`LC_ALL=C sort` is byte order and the culture sort is not, and a one-byte disagreement would make a
valid seal read as tampered on one platform only.

**A broken seal blocks; it does not fall back.** Every other failure in this hook falls back to
`HEAD` and says so. This one cannot: the recorded starting point is what the comparison is measured
from, so an edited seal can hide a weakening rather than merely lose the protection, and falling
back to `HEAD` is exactly the outcome the edit produces.

**A brief that records a baseline and carries no digest blocks too.** The first build treated that
as an absent legacy seal and trusted it, which meant deleting one line disarmed the whole
mechanism: the baseline could then be moved and the tier rewritten with nothing to notice. The
review of 2026-09-06 demonstrated it. Every seal this tool has ever written carries the digest, and
no released kit ever produced a brief without one, so requiring it costs nothing real. A brief with
no baseline at all is still the ordinary no-task case and still falls back quietly. All three are
cases.

The `tier` line is inside the seal, which closes the `P2` recorded by the verifier of D-19: a
one-line edit turning `tier: 3` into `tier: 2` used to remove the review contract, and now blocks.

### A test added during the task could be weakened by committing it

The `A` branch compared an added file against `HEAD`, because it has no version at the baseline.
That catches a weakening still in the working tree, and nothing else: after

```text
baseline A
commit B   add a test with two assertions
commit C   remove one of them
```

`HEAD` is `C`, the working tree equals `C`, and the comparison has nothing to see. Reproduced before
the fix at exit 0 with a clean tree.

The fix is one git command: the version to compare against is the one at the commit that first added
the file during this task, found with
`git log --diff-filter=A --reverse --format=%H <baseline>..HEAD -- <file>`, taking the oldest. When
that returns nothing, because the file was staged and never committed or because there is no task
baseline, `HEAD` is still the only earlier version and is used. Ordinary baseline-existing tests and
renames are untouched.

The block names the commit that added the test:

```
WEAKENED repo/tests/n.test.js (added during the task)  (assertions 3 -> 2) since ede1296, the
commit that added it during this task
```

### The suite

`bash .claude/tools/hooks.test.sh`: **159 passed, 0 failed**, both shells, against 120 before this
correction. The count includes the assertions added by the review of 2026-09-06, below. Every D-17 and D-18 regression listed on this page and
on the active-task page still passes, unchanged: committed weakening, staged rename, added test with
an uncommitted weakening, rebased baseline, nonexistent baseline, body digest, refusal to re-seal,
pre-existing recording, two-session isolation, pointer validation, the relay-brief refusal, and the
resume fallbacks.

One existing case had to be rebuilt rather than kept. "A nonexistent baseline commit falls back to
HEAD" used to edit `baseline_commit` by hand to a commit that does not exist, which is now tampering
and blocks. The state it was modelling is real, so it is now reached honestly: a brief is sealed in a
second checkout of the same name and carried into the first, which is what happens in shape B when
one clone lacks the commit. The seal stays valid because the brief was never edited.

Both fixes were mutation-tested. Disabling the seal check failed three assertions, including the
moved baseline and the edited tier; reverting the added-test branch to `HEAD` failed two, including
the committed weakening. Restoring both returned 146 and 0.

### Two limits confirmed and left alone

**Pre-existing dirty tests are attributed to the task.** `seal` writes `pre-existing.txt`, and the
Stop hook does not read it. Reproduced: weaken a test, leave it dirty, seal, change nothing at all,
and the hook blocks with `WEAKENED ... since the task baseline`, naming the owner's own work. The
snapshot exists and nothing consumes it. Recorded rather than fixed, because consuming it means
deciding what happens when the owner's dirty file is later edited by the task, and that is a design
question, not a patch.

**`working/status.md` is still global.** The brief is session-scoped; the status file is not, and
`resume-brief` prints it before the brief. Two concurrent sessions each get their own brief and both
see whichever status was written last. D-18 never claimed general concurrency control, so this is a
limit of the surrounding state, not a defect in the pointer.

## What an independent review found, 2026-09-06

Six independent readers ran this code against fixtures they built themselves, and each finding was
verified by a second reader who tried to refute it. Four defects in the seal work held. All four are
fixed, and each has a case.

**The seal could be moved by making the brief look unsealed.** "Already sealed" was decided by
`front_matter()`, which requires line 1 to be exactly `---`. A blank line before the fence, a BOM, or
deleting the header outright made a sealed brief present as unsealed, and `seal` ran again and wrote
a fresh, self-consistent approval at whatever `HEAD` had become. `check` then said "brief unchanged
since approval" and "seal intact", and both hooks exited 0. Removing `--force` had closed the front
door and left this open.

Two guards now. Whether a brief is sealed is decided by scanning the whole file for an approval line,
so a brief that carries one and cannot be parsed is refused rather than re-sealed. And
`pre-existing.txt`, which only `seal` writes, is treated as proof that this task was sealed once
already, whatever the brief now contains, so stripping the approval out is refused as well. Removing
the task folder entirely still starts the task over, because that is the documented way to do it and
`working/` is disposable by design.

**A tab defeated the baseline while keeping the digest valid.** The canonical form trims whitespace
after the colon, so `baseline_commit.repo:` followed by a tab hashes identically. The hooks looked
the key up as `"baseline_commit.<name>: "` with a literal space, found nothing, and fell back to
`HEAD` with a note nobody reads on exit 0. One character removed the protection while every check
still said the seal was intact. Both hooks now read the key up to the colon and trim exactly as the
digest does.

**A rename cleared the added-test block.** `git log` with a single pathspec cannot pair a rename, so
it reports the commit that renamed a file as an add of the new name. For a test created during the
task, that made the already-weakened file its own comparison base: weaken, commit, `git mv`, commit,
and the turn passed. Both hooks now follow the rename back through the commit's own full diff,
bounded at five hops, and the block names the old path and the new one.

**The PowerShell hook read the brief in the ANSI codepage.** `Get-Content` with no `-Encoding`
returns mojibake for the UTF-8 bytes `baseline.sh` writes, so the digest disagreed with both bash
implementations. A checkout folder with an accent in its name was enough to report a valid seal as
tampered and stop every turn on Windows only. It reads UTF-8 now.

### What is still not closed

`working/` is writable by the builder, so no record kept only there can be made tamper-proof against
it. What these guards buy is that each obvious route now says no, and that the routes which remain
require deleting more than one artefact. The honest sentence is that the seal makes moving a baseline
expensive and visible, not impossible.

The rename follow is bounded at five hops, so a sixth chained rename inside one task falls back to
the last commit it found. Splitting a test created during the task into two files still blocks every
turn, because the original loses assertions and nothing knows they moved; that is the same friction
D-17 accepted, and it is in `99-pending.md`.
