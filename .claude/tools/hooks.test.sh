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
