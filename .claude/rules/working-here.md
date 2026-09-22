# Things that fail silently

Every entry here returns something that looks normal and is wrong. That is why each one cost a day
the first time, and why it earns a line in every session's context. These are the cross-project
entries, measured on Windows with Git Bash and PowerShell 5.1. The project's own traps are appended
below them: symptom first, then mechanism, then fix, then the date measured. Before adding one,
search for the same root cause. Same cause with a different symptom means merge, not a new entry.

## Shell and tooling

- **`${BASH_SOURCE[0]}` is whatever the caller typed**, so a `cd` early in a script breaks every
  path derived from it, including the script's own, and a missing dependency then fails silently.
  Resolve `_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` before any `cd`, and `exit 1` on
  a missing dependency, never `&&`. 2026-08-31.
- **An argument starting with `-` is parsed as an option**, by `grep`, `yes`, `printf`, and most
  tools. `grep` and `grep -v` both return empty, so a static check goes green with none of the work
  done; `yes "- text"` fails silently inside a pipeline. Use `grep -E -e "$pattern"`, `printf --`,
  and `--` before any such argument. 2026-08-24, again 2026-09-05.
- **An empty set passes every "is it small enough" check.** An unmatched glob runs the loop once
  with a name that does not exist. Count the files as well as the lines, and fail on zero. 2026-08-31.
- **A pipeline of two commands reports the exit code of the last one.** `git push a; git push b`
  exits 0 when the first push failed. Check each separately and confirm with `git ls-remote`.
  2026-08-18.
- **A quote character inside `${var:-default}` is syntax, and `bash -n` cannot see it.** One
  apostrophe in a default swallowed three hundred lines into one string. Assign the default on its
  own line in single quotes. 2026-08-25.
- **`git ls-files` lists only tracked files**, so a sweep built on it is blind to new ones, which is
  exactly when it matters. Use `git ls-files --cached --others --exclude-standard`. 2026-08-25.
- **`cmd /c` in Git Bash runs nothing and exits 0**, and `gh api /repos/...` with a leading slash
  is rewritten into a filesystem path. MSYS converts a leading `/x` for native programs. Write
  `cmd //c` and `gh api repos/...` without the slash. **Do not cure this with
  `MSYS_NO_PATHCONV=1` in the environment:** it also stops every POSIX path from being converted,
  so `git -C /d/repo` and `node /d/x` fail with "no such file" while `D:/repo` works. Measured
  2026-09-05 after the variable broke every install test. 2026-08-25.
- **`node -e` from Bash mangles backslashes and reports the error on the wrong line**, and `node`
  reads an MSYS path like `/d/x` as `D:\d\x`. Put any one-liner with a backslash or a regex in a
  `.js` file, and pass Windows paths to native programs. 2026-08-31.

## PowerShell 5.1

- **Redirecting a native command's stderr under `$ErrorActionPreference = 'Stop'` makes it
  terminating.** One ordinary git warning kills the script, and `2>$null` does it exactly as much as
  `2>&1`. Suspend the preference for the call in a try/finally, or do not redirect. 2026-09-01.
- **A here-string does not reach a native command's stdin.** `git commit -F - @'...'@` passes the
  text as arguments, and the next command's success hides it. Use the Bash tool's heredoc for stdin,
  and verify the result, not the API's message. 2026-08-24.
- **Piping a string to a native command prepends a UTF-8 BOM**, so the far side fails on the first
  token only. Use `scp`, or write the file first with a BOM-less encoding. 2026-08-16.
- **No `&&`, `||`, `??`, or ternary.** Parse errors, not warnings.
- **A healthy install printed "FILES COPIED, NOT YET VERIFIED" and exited 1: `Get-Command bash`
  returned WSL.** `System32\bash.exe` is the WSL launcher and comes before Git on PATH wherever WSL
  is installed; it runs Linux and reads `D:\x` as `D:x`. Tests launched from Git Bash never see it,
  because Git leads PATH there. Find bash from git's install folder and accept it only if
  `uname -s` says MINGW, MSYS, or CYGWIN. 2026-09-13.

- **A `.ps1` without a UTF-8 BOM is read in the ANSI codepage by PowerShell 5.1**, so every
  non-ASCII character in the source becomes two wrong ones, and anything the script writes carries
  them. `install.ps1` gave Windows adopters a corrupted knowledge base for exactly this reason while
  the bash twin wrote the same text correctly. Give any `.ps1` holding non-ASCII a BOM; `verify.sh`
  checks it. 2026-09-06.

## Git and branches

- **A branch that is behind makes the world look like the moment it was cut.** Check any claim about
  a shared file against the branch it will merge into: `git show origin/<target>:<path>`. 2026-08.
- **Before taking anything from a team branch, check what it deletes:** `git merge-tree
  --write-tree`, then `--diff-filter=D`. The diff people read is the one they asked for. 2026-08.
- **`git diff --stat` draws an all-minus bar for any heavily negative change.** Use `--name-status`
  to ask about deletions.
- **`git -C <subfolder>` acts on the enclosing repository when the subfolder is not a repository of
  its own.** `git -C working remote -v` printed the parent's remote, so a "no remote" check answers
  about the wrong repository. Test for `<subfolder>/.git` before asking git anything about it.
  2026-09-05.

## Hooks

- **A hook matched on `Bash` alone misses commands that run through PowerShell.** Match both. Hook
  `timeout` is in seconds. The first character of stdout decides how output is parsed, so keep it
  quiet. Normalise path separators before matching file paths. Hooks do not hot-reload: restart the
  session after changing one. 2026-08.
- **A path-scoped rule does not load for a shell read or a shell edit.** `cat`, `grep`, and `awk` on
  a file under `docs/knowledge-base/` left `knowledge-base.md` out of context for a whole turn; the
  `Read` tool on the same file brought it in at once. A session that prefers the shell writes
  knowledge-base pages without the rule that says how. Open one page with `Read` first. 2026-09-05.

## Reasoning

The traps above are about shells. These are about judgement, and they cost more. All five were
measured on production questions on one installation.

- **The size of a mechanism reported as its effect.** A migration said to "revoke entitlements from
  353 subscriptions" read a collection holding zero documents; "86 of 88 messages dropped" counted
  52 correct skips and the system's own echoes; a dead-token alarm fired on channels where 1,083
  sends had just succeeded. Count the thing the customer has, not the thing the code touches; trace
  one item end to end before trusting an aggregate; check whose. 2026-08-02 to 2026-08-08.
- **A green test on an unreachable path.** A fix recorded as proven by an offline replay (12 of 77
  cases to 44 of 77) had fired zero times in production: the replay supplied an input the running
  system never produces. Ask of any passing suite which line would fail if the claim were false,
  and after a deploy look for the success line the fix emits, not the failure line. 2026-08-24.
- **The dangerous zero.** Three zeros in one day meant "my question could not see it": a query that
  had never run, a grep for a guard an upstream check made unreachable, and a health query reporting
  zero healthy targets on a system that was visibly serving. Before believing a zero, confirm the
  same query sees something you are certain exists. A zero that fits your hypothesis deserves more
  scrutiny than one that contradicts it. 2026-08-24.
- **An instrument that measures itself.** A counter built to measure a behaviour scanned the very
  text it was measuring and always agreed with itself. Validate a new instrument against a case
  whose answer you already know before citing it. 2026-08-24.
- **Log volume read as usage.** A service with 26 log lines a day was written down as idle; it
  carried all console traffic and logged at Warning. A quiet log is a mechanism; find the callers in
  configuration and client code, which is the effect. 2026-09-20.
