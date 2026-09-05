#!/usr/bin/env bash
# Fires every hook by hand, in both shells where they exist, and prints one line per case.
# This is how the harness proves its guards can go red: a hook that has never blocked anything
# is not known to work. Run it after installing, and after any change to a hook.
#
#   bash .claude/tools/hooks.test.sh
#
# Secret-shaped values are assembled at runtime so this file never carries one. PowerShell cases
# run only where powershell is on PATH; bash cases always run.

unset MSYS_NO_PATHCONV
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
H="$(cd "$HERE/../hooks" && pwd)"
T="$(mktemp -d 2>/dev/null || mktemp -d -t hooks)"
trap 'rm -rf "$T"' EXIT

have_ps=0; command -v powershell >/dev/null 2>&1 && have_ps=1
winpath() { if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi; }
ps() { powershell -NoProfile -ExecutionPolicy Bypass -File "$(winpath "$1")"; }
shells="sh"; [ "$have_ps" = 1 ] && shells="ps1 sh"

fails=0; total=0
case_() { total=$((total+1)); if [ "$2" = "$3" ]; then printf '  ok    %-58s exit %s\n' "$1" "$3"; else printf '  FAIL  %-58s expected %s got %s\n' "$1" "$2" "$3"; fails=$((fails+1)); fi; }
run() { # shell hook payload -> exit code; stdout to $T/out, stderr to $T/err
  if [ "$1" = ps1 ]; then printf '%s' "$3" | ps "$H/$2.ps1" >"$T/out" 2>"$T/err"; else printf '%s' "$3" | bash "$H/$2.sh" >"$T/out" 2>"$T/err"; fi; echo $?
}

tok="ghp_$(printf 'A%.0s' $(seq 1 40))"
pw="$(printf 'Sup3r%s' 'SecretValue')"
p_token='{"tool_name":"Write","tool_input":{"file_path":"x.md","content":"token: '"$tok"'"}}'
p_pwvar='{"tool_name":"Write","tool_input":{"file_path":"x.js","content":"const password = process.argv[2];"}}'
p_conn='{"tool_name":"Edit","tool_input":{"file_path":"a.json","new_string":"Server=db1;Database=app;User Id=sa;Password='"$pw"';"}}'
p_shape='{"tool_name":"Write","tool_input":{"file_path":"doc.md","content":"a GitHub token looks like ghp_[A-Za-z0-9]{36}"}}'
p_placeholder='{"tool_name":"Write","tool_input":{"file_path":"a.json","content":"Server=db1;Database=app;Password=<your-password>;"}}'
p_prose='{"tool_name":"Write","tool_input":{"file_path":"note.md","content":"a connection string with a `Server=` field and a `Password=` field on one line"}}'

echo "guard-secrets"
for shell in $shells; do
  case_ "$shell: fake GitHub token blocked"             2 "$(run $shell guard-secrets "$p_token")"
  case_ "$shell: const password = argv allowed"         0 "$(run $shell guard-secrets "$p_pwvar")"
  case_ "$shell: connection-string password blocked"    2 "$(run $shell guard-secrets "$p_conn")"
  case_ "$shell: token shape description allowed"       0 "$(run $shell guard-secrets "$p_shape")"
  case_ "$shell: placeholder password allowed"          0 "$(run $shell guard-secrets "$p_placeholder")"
  case_ "$shell: prose naming the fields allowed"       0 "$(run $shell guard-secrets "$p_prose")"
done

echo "guard-commands"
p_cmd='{"tool_name":"Bash","tool_input":{"command":"git status"}}'
p_mark='{"tool_name":"PowerShell","tool_input":{"command":"echo __guard_commands_selftest__"}}'
for shell in $shells; do
  case_ "$shell: ordinary command allowed"              0 "$(run $shell guard-commands "$p_cmd")"
  case_ "$shell: self-test marker without env allowed"  0 "$(run $shell guard-commands "$p_mark")"
  case_ "$shell: self-test marker with env blocked"     2 "$(GUARD_COMMANDS_SELFTEST=1 run $shell guard-commands "$p_mark")"
done

echo "verify-on-finish"
R="$T/repo"; mkdir -p "$R/tests"
git -C "$R" init -q
git -C "$R" config core.autocrlf false
printf 'working/\n' > "$R/.gitignore"    # as an installed repository has it; the seal must never be staged
printf 'test("a", () => { expect(1).toBe(1); expect(2).toBe(2); });\n' > "$R/tests/x.test.js"
printf 'skip the tests for now, this is a pre-existing bug\n' > "$T/transcript.jsonl"
git -C "$R" add -A && git -C "$R" -c user.email=t@t -c user.name=t commit -qm init 2>/dev/null
for shell in $shells; do
  if [ "$shell" = ps1 ]; then cwdv="$(winpath "$R")"; tp="$(winpath "$T/transcript.jsonl")"; else cwdv="$R"; tp="$T/transcript.jsonl"; fi
  git -C "$R" checkout -q -- tests/x.test.js
  case_ "$shell: clean tree allowed"                    0 "$(run $shell verify-on-finish '{"cwd":"'"$cwdv"'","stop_hook_active":false}')"
  printf 'test("a", () => { expect(1).toBe(1); });\n' > "$R/tests/x.test.js"
  case_ "$shell: weakened test blocked"                 2 "$(run $shell verify-on-finish '{"cwd":"'"$cwdv"'","stop_hook_active":false}')"
  case_ "$shell: weakened but stop_hook_active allowed" 0 "$(run $shell verify-on-finish '{"cwd":"'"$cwdv"'","stop_hook_active":true}')"
  git -C "$R" checkout -q -- tests/x.test.js; rm "$R/tests/x.test.js"
  case_ "$shell: deleted test blocked"                  2 "$(run $shell verify-on-finish '{"cwd":"'"$cwdv"'","stop_hook_active":false}')"
  git -C "$R" checkout -q -- tests/x.test.js
  run $shell verify-on-finish '{"cwd":"'"$cwdv"'","stop_hook_active":false,"transcript_path":"'"$tp"'"}' >/dev/null
  total=$((total+1)); if grep -q rationalization "$T/out"; then echo "  ok    $shell: rationalization note printed, non-blocking"; else echo "  FAIL  $shell: no rationalization note"; fails=$((fails+1)); fi
done

echo "verify-on-finish with a task baseline"
# The two cases a HEAD-only comparison cannot detect, measured 2026-09-05: a weakening that was
# committed before the turn ended, and a staged rename with an assertion removed. Both must block
# while the task's brief carries an open seal, and so must a test added during the task and then
# weakened. Once the brief is closed, or when the recorded commit no longer exists, the hook falls
# back to HEAD and the committed weakening is invisible again, which is the documented limit, not a
# bug. A rewritten (rebased) baseline is compared from its merge-base instead. The brief is sealed
# by the real tool, so the tool is under test too. Every check here fires the hook and reads its
# exit code or its text; none reads the scripts.
# A multi-line fixture, so that a rename with one assertion removed is still a rename to git
# (similarity above 50 percent); a one-line file would show as delete plus add.
printf 'describe("z", () => {\n  test("one", () => {\n    expect(1).toBe(1);\n  });\n  test("two", () => {\n    expect(2).toBe(2);\n    expect(3).toBe(3);\n  });\n});\n' > "$R/tests/z.test.js"
git -C "$R" add -A && git -C "$R" -c user.email=t@t -c user.name=t commit -qm fixture 2>/dev/null
init=$(git -C "$R" rev-parse HEAD)
trunk=$(git -C "$R" rev-parse --abbrev-ref HEAD)
gitc() { git -C "$R" -c user.email=t@t -c user.name=t "$@"; }
seal_() { rm -rf "$R/working/$1"; mkdir -p "$R/working/$1"; printf '# brief\noutcome: tests stay whole\n' > "$R/working/$1/brief.md"; (cd "$R" && bash "$HERE/baseline.sh" seal "$1" >"$T/seal.out" 2>&1); }
weaken_commit() { printf 'test("a", () => { expect(1).toBe(1); });\n' > "$R/tests/x.test.js"; gitc commit -qam weaken 2>/dev/null; }
for shell in $shells; do
  if [ "$shell" = ps1 ]; then cwdv="$(winpath "$R")"; else cwdv="$R"; fi
  p_stop='{"cwd":"'"$cwdv"'","stop_hook_active":false}'
  git -C "$R" reset -q --hard "$init"; rm -rf "$R/working"
  seal_ task-1; sealed=$?
  total=$((total+1)); if [ "$sealed" -eq 0 ] && grep -q "^baseline_commit.repo: $init" "$R/working/task-1/brief.md"; then echo "  ok    $shell: baseline.sh seal recorded the commit in the brief"; else echo "  FAIL  $shell: baseline.sh seal did not record the commit in the brief"; fails=$((fails+1)); cat "$T/seal.out"; fi
  total=$((total+1)); if [ "$(sed -n '2,$p' "$R/working/task-1/brief.md" | grep -c '^# brief$')" = 1 ]; then echo "  ok    $shell: the approved text survives sealing"; else echo "  FAIL  $shell: sealing damaged the brief body"; fails=$((fails+1)); fi
  case_ "$shell: sealed, clean tree allowed"            0 "$(run $shell verify-on-finish "$p_stop")"
  # committed weakening: weaken, commit, then try to finish
  weaken_commit
  case_ "$shell: committed weakening blocked"           2 "$(run $shell verify-on-finish "$p_stop")"
  total=$((total+1)); if grep -q "since the task baseline" "$T/err"; then echo "  ok    $shell: the block names the task baseline"; else echo "  FAIL  $shell: the block does not name the baseline"; fails=$((fails+1)); fi
  # renamed weakening: git mv, remove one assertion, stage it
  git -C "$R" reset -q --hard "$init"
  git -C "$R" mv tests/z.test.js tests/w.test.js
  printf 'describe("z", () => {\n  test("one", () => {\n    expect(1).toBe(1);\n  });\n  test("two", () => {\n    expect(2).toBe(2);\n  });\n});\n' > "$R/tests/w.test.js"
  git -C "$R" add -A
  case_ "$shell: staged rename plus removed assertion blocked" 2 "$(run $shell verify-on-finish "$p_stop")"
  total=$((total+1)); if grep -q "renamed" "$T/err"; then echo "  ok    $shell: the block names the rename"; else echo "  FAIL  $shell: the block does not name the rename"; fails=$((fails+1)); fi
  # a test added during the task, committed, then weakened: it has no baseline version, so HEAD is used
  git -C "$R" reset -q --hard "$init"
  printf 'test("n", () => { expect(1).toBe(1); expect(2).toBe(2); });\n' > "$R/tests/n.test.js"
  git -C "$R" add -A; gitc commit -qm add-test 2>/dev/null
  printf 'test("n", () => { expect(1).toBe(1); });\n' > "$R/tests/n.test.js"
  case_ "$shell: test added during the task, then weakened, blocked" 2 "$(run $shell verify-on-finish "$p_stop")"
  # a second brief, sealed later and closed, must not disable the one still open
  git -C "$R" reset -q --hard "$init"
  seal_ task-2; (cd "$R" && bash "$HERE/baseline.sh" close task-2 >/dev/null 2>&1)
  weaken_commit
  case_ "$shell: a closed brief does not disable the open one" 2 "$(run $shell verify-on-finish "$p_stop")"
  total=$((total+1)); if grep -q "working/task-1/brief.md" "$T/err"; then echo "  ok    $shell: the finding names the open brief"; else echo "  FAIL  $shell: the finding does not name the open brief"; fails=$((fails+1)); fi
  rm -rf "$R/working/task-2"
  # a rewritten baseline: the task branch is rebased, so the sealed commit is gone; the merge-base is used
  git -C "$R" reset -q --hard "$init"; git -C "$R" checkout -q -b "feat-$shell"
  printf 'f1\n' > "$R/f1.txt"; git -C "$R" add -A; gitc commit -qm f1 2>/dev/null
  seal_ task-1
  weaken_commit
  git -C "$R" checkout -q "$trunk"; printf 'm1\n' > "$R/m1.txt"; git -C "$R" add -A; gitc commit -qm m1 2>/dev/null
  git -C "$R" checkout -q "feat-$shell"; gitc rebase -q "$trunk" >/dev/null 2>&1
  case_ "$shell: rebased task branch compared from the merge-base" 2 "$(run $shell verify-on-finish "$p_stop")"
  total=$((total+1)); if grep -q "merge-base" "$T/out"; then echo "  ok    $shell: the rewritten baseline is announced"; else echo "  FAIL  $shell: no merge-base note"; fails=$((fails+1)); fi
  git -C "$R" checkout -q "$trunk"; git -C "$R" branch -q -D "feat-$shell"; git -C "$R" reset -q --hard "$init"
  # closed brief: back to HEAD, so a committed weakening is invisible again (the documented limit)
  seal_ task-1
  weaken_commit
  (cd "$R" && bash "$HERE/baseline.sh" close task-1 >/dev/null 2>&1)
  case_ "$shell: closed brief falls back to HEAD"        0 "$(run $shell verify-on-finish "$p_stop")"
  # a baseline commit that does not exist: HEAD again, with a note
  awk '/^baseline_commit\.repo: /{print "baseline_commit.repo: 0123456789abcdef0123456789abcdef01234567"; next} /^closed_at:/{next} {print}' "$R/working/task-1/brief.md" > "$T/b.tmp" && mv "$T/b.tmp" "$R/working/task-1/brief.md"
  case_ "$shell: nonexistent baseline commit falls back to HEAD" 0 "$(run $shell verify-on-finish "$p_stop")"
  total=$((total+1)); if grep -q "does not exist" "$T/out"; then echo "  ok    $shell: the fallback is announced"; else echo "  FAIL  $shell: no fallback note"; fails=$((fails+1)); fi
done
git -C "$R" reset -q --hard "$init"; rm -rf "$R/working"

echo "baseline.sh"
mkdir -p "$R/working/task-2"; printf -- '---\nowner: someone\n---\n\n# brief\n' > "$R/working/task-2/brief.md"; printf 'wip\n' > "$R/owner-wip.txt"
(cd "$R" && bash "$HERE/baseline.sh" seal task-2 >/dev/null 2>&1)
total=$((total+1)); if grep -q "owner-wip.txt" "$R/working/task-2/pre-existing.txt" && grep -q '^pre_existing: 1$' "$R/working/task-2/brief.md"; then echo "  ok    seal records a pre-existing untracked file"; else echo "  FAIL  seal missed the pre-existing file"; fails=$((fails+1)); fi
total=$((total+1)); if grep -q '^owner: someone$' "$R/working/task-2/brief.md"; then echo "  ok    seal keeps front matter the brief already had"; else echo "  FAIL  seal dropped existing front matter"; fails=$((fails+1)); fi
(cd "$R" && bash "$HERE/baseline.sh" seal task-2 >"$T/reseal.out" 2>&1); rc=$?
total=$((total+1)); if [ "$rc" -ne 0 ] && grep -q "does not move" "$T/reseal.out"; then echo "  ok    seal refuses to re-seal a sealed brief"; else echo "  FAIL  seal re-sealed a sealed brief"; fails=$((fails+1)); fi
(cd "$R" && bash "$HERE/baseline.sh" check task-2 >/dev/null 2>&1); rc=$?
total=$((total+1)); if [ "$rc" -eq 0 ]; then echo "  ok    check passes on an unchanged brief"; else echo "  FAIL  check failed on an unchanged brief"; fails=$((fails+1)); fi
printf 'changed after approval\n' >> "$R/working/task-2/brief.md"
(cd "$R" && bash "$HERE/baseline.sh" check task-2 >"$T/check.out" 2>&1); rc=$?
total=$((total+1)); if [ "$rc" -ne 0 ] && grep -q "BRIEF CHANGED" "$T/check.out"; then echo "  ok    check detects a brief changed after approval"; else echo "  FAIL  check missed a changed brief"; fails=$((fails+1)); fi
rm -f "$R/owner-wip.txt"

echo "resume-brief"
W="$T/ws"; mkdir -p "$W/working/task-1"
printf '# status\nlast session: hooks tested\n' > "$W/working/status.md"
printf '# brief\noutcome: the brief survives compaction\n' > "$W/working/task-1/brief.md"
for shell in $shells; do
  if [ "$shell" = ps1 ]; then cwdv="$(winpath "$W")"; else cwdv="$W"; fi
  run $shell resume-brief '{"cwd":"'"$cwdv"'","source":"compact"}' >/dev/null
  total=$((total+1)); if grep -q "hooks tested" "$T/out" && grep -q "survives compaction" "$T/out"; then echo "  ok    $shell: status and brief printed after compaction"; else echo "  FAIL  $shell: resume output missing"; fails=$((fails+1)); fi
done

echo; echo "  $((total-fails)) passed, $fails failed"
[ "$fails" -eq 0 ]
