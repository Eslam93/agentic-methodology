#!/usr/bin/env bash
# Runs status.sh and preflight.sh against fixture trees and asserts the exit code and the message.
# This is how the two estate tools prove they can go red: a gate that has never failed is not known
# to gate, and a failure with the wrong message is not actionable.
#
#   bash .claude/tools/estate.test.sh
#
# Every case builds a real tree and runs the real tool with --root. Nothing here greps the tools'
# source, because a test that reads the script instead of running it passes over a broken script.

unset MSYS_NO_PATHCONV
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ST="$HERE/status.sh"; PF="$HERE/preflight.sh"
[ -f "$ST" ] && [ -f "$PF" ] || { echo "status.sh or preflight.sh not found beside this suite"; exit 1; }
T="$(mktemp -d 2>/dev/null || mktemp -d -t estatetest)"
trap 'rm -rf "$T"' EXIT

fails=0; total=0; got=""
check() {   # name expected-exit needle
  total=$((total+1))
  if [ "$got" != "$2" ]; then
    printf '  FAIL  %-58s expected exit %s got %s\n' "$1" "$2" "$got"; fails=$((fails+1))
    sed 's/^/          /' "$T/out" | head -8; return
  fi
  if [ -n "$3" ] && ! grep -qF -e "$3" "$T/out"; then
    printf '  FAIL  %-58s exit %s, no message matching: %s\n' "$1" "$got" "$3"; fails=$((fails+1))
    sed 's/^/          /' "$T/out" | head -8; return
  fi
  printf '  ok    %-58s exit %s\n' "$1" "$got"
}
plus_days() {   # n -> yyyy-mm-dd, GNU date first, BSD second
  date -d "$1 days" +%Y-%m-%d 2>/dev/null || date -v"+$1d" +%Y-%m-%d
}
R="$T/p"
mk() { rm -rf "$R"; mkdir -p "$R/.claude/tools" "$R/docs/knowledge-base/00-orientation"; }
run_st() { got="$(bash "$ST" --root "$R" "$@" >"$T/out" 2>&1; echo $?)"; }
run_pf() { got="$(bash "$PF" --root "$R" "$@" >"$T/out" 2>&1; echo $?)"; }

echo "status.sh: nothing to check"
mk; run_st; check "no probes and no deadlines is not a failure"                 0 "no status.project.sh"
mk; run_st; check "it says the estate answers nothing yet"                     0 "not checked."

echo "status.sh: declared deadlines"
mk; printf '%s 30 owner :: a thing that is overdue :: some-page.md\n' "$(plus_days -3)" > "$R/.claude/deadlines.conf"
run_st; check "an overdue date is RED and the run fails"                       1 "overdue by 3 d"
mk; printf '%s 30 owner :: within the warning window :: some-page.md\n' "$(plus_days 20)" > "$R/.claude/deadlines.conf"
run_st; check "a date inside warn_days is AMBER, run passes"                   0 "-- AMBER (1) --"
mk; printf '%s 30 owner :: a red-zone date :: some-page.md\n' "$(plus_days 5)" > "$R/.claude/deadlines.conf"
run_st; check "a date inside a quarter of warn_days is RED"                    1 "-- RED (1) --"
mk; printf '%s 30 owner :: far away :: some-page.md\n' "$(plus_days 200)" > "$R/.claude/deadlines.conf"
run_st; check "a far date is OK"                                               0 "-- OK (1) --"
mk; printf '%s 400 owner :: long runway, still near :: p.md\n' "$(plus_days 25)" > "$R/.claude/deadlines.conf"
run_st; check "the RED zone is capped at 21 days, so 25 days out is AMBER"    0 "-- AMBER (1) --"
mk; printf 'not-a-date 30 owner :: bad line :: p.md\n' > "$R/.claude/deadlines.conf"
run_st; check "a bad date is a RED about the file, not a silent skip"          1 "date is not yyyy-mm-dd"
mk; printf '%s 30 owner no separators at all\n' "$(plus_days 9)" > "$R/.claude/deadlines.conf"
run_st; check "a line without :: is a RED about the file"                      1 "no '::' separator"
mk; printf '# only a comment\n\n' > "$R/.claude/deadlines.conf"
run_st; check "a file with no deadline lines is reported, not passed silently" 0 "has no deadline lines"

echo "status.sh: the project's probes"
mk; printf '#!/usr/bin/env bash\nprintf "OK\\tpods\\tprod\\tall 12 running\\t\\n"\n' > "$R/.claude/tools/status.project.sh"
run_st; check "an OK finding passes and is shown"                              0 "all 12 running"
mk; printf '#!/usr/bin/env bash\nprintf "RED\\tcerts\\t*.example.test\\texpires in 3 d\\trenew: run the cert job\\n"\n' > "$R/.claude/tools/status.project.sh"
run_st; check "a RED finding fails the run and prints its remedy"              1 "> renew: run the cert job"
mk; printf '#!/usr/bin/env bash\nprintf "RED\\tcerts\\tx\\tno remedy here\\t\\n"\n' > "$R/.claude/tools/status.project.sh"
run_st; check "a RED without a remedy is itself reported"                      1 "RED finding without a remedy"
mk; printf '#!/usr/bin/env bash\necho "this is not a finding"\n' > "$R/.claude/tools/status.project.sh"
run_st; check "a malformed line is a RED, never dropped"                       1 "malformed finding"
mk; printf '#!/usr/bin/env bash\nprintf "PURPLE\\ta\\tb\\tc\\td\\n"\n' > "$R/.claude/tools/status.project.sh"
run_st; check "an unknown level is malformed"                                  1 "malformed finding"
mk; printf '#!/usr/bin/env bash\nexit 3\n' > "$R/.claude/tools/status.project.sh"
run_st; check "a probe script that exits non-zero is RED"                      1 "exited 3"
mk; printf '#!/usr/bin/env bash\n:\n' > "$R/.claude/tools/status.project.sh"
run_st; check "a probe that prints nothing is reported, not passed"            0 "printed no findings"
mk; printf '#!/usr/bin/env bash\nprintf "SKIP\\tlicence\\tpilot\\tno kubectl context\\t\\n"\n' > "$R/.claude/tools/status.project.sh"
run_st; check "SKIP is allowed without a remedy"                               0 "no kubectl context"

echo "status.sh: --check and --canary"
mk; printf '#!/usr/bin/env bash\nif then fi\n' > "$R/.claude/tools/status.project.sh"
run_st --check; check "--check catches a probe script that does not parse"     1 "does not parse"
mk; printf '#!/usr/bin/env bash\nprintf "RED\\ta\\tb\\tc\\td\\n"\n' > "$R/.claude/tools/status.project.sh"
run_st --check; check "--check runs no probe, so a RED probe does not fire"    0 "parses (not run)"
mk; run_st --canary; check "--canary fails and says both injections were seen" 1 "a synthetic RED and a malformed line were both reported"

echo "preflight.sh"
cap="$R/docs/knowledge-base/00-orientation/capabilities.md"
mkcap() {
  mk
  cat > "$cap" <<'EOF'
---
title: fixture capabilities
status: verified
as_of: 2026-09-22
last_verified: 2026-09-22
verification_method: estate.test.sh
scope: fixture
confidence: High. fixture
known_gaps: none
reverify_when: never
---

| Token | Blast | Grants | Proof (read-only) | Expected | Obtain |
|---|---|---|---|---|---|
| `TOOL-TRUE` | 🟢 | a command that exits 0 | `true` | | install nothing |
| `TOOL-FALSE` | 🟢 | a command that exits 1 | `false` | | ask nobody |
| `TOOL-MATCH` | 🟢 | output matches | `echo hello world` | ^hello | none |
| `TOOL-NOMATCH` | 🟡 | output does not match | `echo hello world` | ^goodbye | the docs |
| `TOOL-PIPE` | 🟢 | a pipe inside the proof | `printf 'a\nb\n' \| wc -l` | 2 | none |
| `GAP-ONE` | 🔴 | nobody knows how | `false` | UNRESOLVED | the platform owner |
EOF
}
mkcap; run_pf --list; check "--list runs nothing and exits 0"                  0 "TOOL-FALSE"
mkcap; run_pf -c TOOL-TRUE; check "a passing proof"                            0 "PASS  TOOL-TRUE"
mkcap; run_pf -c TOOL-FALSE; check "a failing proof fails the run"             1 "FAIL  TOOL-FALSE"
mkcap; run_pf -c TOOL-MATCH; check "expected regex matched"                    0 "PASS  TOOL-MATCH"
mkcap; run_pf -c TOOL-NOMATCH; check "expected regex not matched fails"        1 "output did not match"
mkcap; run_pf -c TOOL-PIPE; check "an escaped pipe inside the proof works"     0 "PASS  TOOL-PIPE"
mkcap; run_pf -c GAP-ONE; check "UNRESOLVED is reported and does not fail"     0 "UNRESOLVED"
mkcap; run_pf -c NOPE-X; check "a token the page does not define fails"        1 "not defined"
mkcap; run_pf -c TOOL-TRUE,TOOL-FALSE; check "one failing token fails the set" 1 "1 failed"
mk; run_pf; check "no capabilities page is exit 2, not a pass"                 2 "no capabilities page"
mkcap; printf '# nothing here\n' > "$cap"; run_pf; check "a page with no token rows is exit 2" 2 "no token rows"

echo
if [ "$fails" -eq 0 ]; then echo "  $total cases, 0 failed"; else echo "  $total cases, $fails FAILED"; fi
[ "$fails" -eq 0 ]
