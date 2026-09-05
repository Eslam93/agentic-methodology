---
title: What the sealed task baseline records, what the Stop hook mechanically detects since it, what /work only instructs, and the runs that proved the two cases a HEAD comparison cannot detect
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: hooks.test.sh run in both shells on the owner's Windows machine on 2026-09-05, plus scratch repositories in which each case was fired by hand and the hook's stderr captured; the outputs are quoted below. The design was reviewed by eight finder subagents and twelve verifiers against the working tree, each reproducing its candidate in a scratch repository before it was accepted
scope: The change decided as D-17: baseline.sh, the two verify-on-finish hooks, the hook test suite, and the /work, /pr, codex-relay, and standing-orders text. Not the active-task pointer, the review contract, or any waiver
confidence: High for what the tests and the runs showed; each is a command and its output. The live Stop hook on the desktop app was not observed against a committed weakening in a real session
known_gaps: Only JavaScript-shaped fixtures were exercised; the assertion heuristics are unchanged and still JavaScript and C# shaped. Shape B with several checkouts was exercised by hand in a scratch workspace, not by the suite. Nothing was tried on macOS, whose BSD find lacks -printf and whose bash is 3.2; Linux GNU find has -printf and CI runs the bash cases
reverify_when: On any change to baseline.sh, either verify-on-finish hook, or hooks.test.sh; before quoting the case count
---

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
owner approved, and keeps any front matter the brief already had:

```yaml
task: <slug>
approved_at: <UTC, ISO seconds>
baseline_commit.<checkout>: <full commit>     # one line per checkout
brief_sha256: <sha256 of the text below the front matter>
pre_existing: <count>
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
that a changed agreement becomes a new task brief rather than a moved seal, which the tool enforces
by refusing to seal twice; that commits use
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
- The digest covers the text below the front matter, so an edit to the front matter itself is not
  what `check` compares; the recorded commit is checked against git separately.
- A merge or pull that legitimately deletes a test keeps blocking for the rest of the session, since
  D-18 leaves no way to retire a baseline early and a seal cannot move. That is the friction D-17
  accepted; the block names the file, and a real incident is what would earn a waiver.
