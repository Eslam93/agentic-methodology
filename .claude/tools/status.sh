#!/usr/bin/env bash
# What the estate is doing right now, computed rather than remembered.
#
#   bash .claude/tools/status.sh             run the project's probes and the declared deadlines
#   bash .claude/tools/status.sh --check     parse the two inputs, run no probe (verify.sh uses this)
#   bash .claude/tools/status.sh --canary    MUST FAIL: proves a RED is reported and a malformed line is refused
#   bash .claude/tools/status.sh --root <d>  act on another tree (fixtures, tests)
#
# Two inputs, both optional, both owned by the project, never by this kit:
#
#   .claude/tools/status.project.sh   the project's own read-only probes. One finding per line on stdout:
#                                       LEVEL <TAB> section <TAB> subject <TAB> detail <TAB> remedy
#                                     LEVEL is RED, AMBER, OK or SKIP. RED and AMBER need a remedy, and the
#                                     remedy is something a person can paste, not a worry.
#   .claude/deadlines.conf            dates no system can answer (a vendor's billing change, a renewal set
#                                     by hand). One per line:
#                                       <yyyy-mm-dd>  <warn_days>  <owner> :: <what> :: <where it is written up>
#                                     AMBER from warn_days out, RED from a quarter of that (at most 21 days),
#                                     RED once it is past. Lead-time-relative, so a 120-day runway does not
#                                     shout four months early and a 14-day item does not stay green until
#                                     the day before.
#
# THE RULE THIS ENCODES: if it can be read from a system, it is not a document. On one installation a
# spot-check on 2026-08-24 found five of seven written operational claims stale or wrong (a licence
# date, a certificate expiry, a deployed version, a restart count, a parking timer), every one of them
# computable from a live system. Prose is true for a week and then lies silently, and a reader cannot
# tell the two apart. A program has no memory and cannot be out of date. The only thing this trusts
# from a file is deadlines.conf, which must hold only dates that genuinely cannot be read anywhere.
#
# Two design choices, both paid for. Symptoms are reported as a condition, not a list: a probe that
# prints twenty tombstones for one full disk trains the reader to ignore it, so status.project.sh
# should count and name the cause. And a finding that cannot be parsed is a RED of its own, because a
# check whose output nobody can read cannot gate.
#
# Exit 0 = nothing RED. Exit 1 = at least one RED, so it works as a gate. Exit 2 = a bad invocation.
# It never writes, approves, cancels or deploys anything; a probe in status.project.sh that does is a
# defect in that script, and the rules say so.

set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"

mode=""; root=""
while [ $# -gt 0 ]; do
  case "$1" in
    --canary|--check) mode="$1"; shift ;;
    --root) root="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,36p' "$0"; exit 0 ;;
    *) echo "unknown option: $1"; exit 2 ;;
  esac
done
if [ -n "$root" ]; then
  [ -d "$root" ] || { echo "root does not exist: $root"; exit 2; }
  ROOT="$(cd "$root" && pwd)"
fi
cd "$ROOT" || { echo "cannot cd to $ROOT"; exit 2; }

PROJECT=".claude/tools/status.project.sh"
DEADLINES=".claude/deadlines.conf"
TMP="$(mktemp -d 2>/dev/null || mktemp -d -t status)"
trap 'rm -rf "$TMP"' EXIT
: > "$TMP/RED"; : > "$TMP/AMBER"; : > "$TMP/OK"; : > "$TMP/SKIP"

# Records are joined with the unit separator (037), never a tab: `read` treats a tab as whitespace and
# collapses two in a row, so an empty subject would shift the detail into its place.
emit() {   # LEVEL section subject detail remedy -> 1 when LEVEL is not one of the four
  case "$1" in RED|AMBER|OK|SKIP) ;; *) return 1 ;; esac
  printf '%s\037%s\037%s\037%s\n' "$2" "$3" "$4" "$5" >> "$TMP/$1"
}

# Seconds since the epoch for a yyyy-mm-dd: GNU date first, BSD date second.
epoch_of() {
  local e
  e="$(date -d "$1" +%s 2>/dev/null)" && [ -n "$e" ] && { printf '%s' "$e"; return 0; }
  e="$(date -j -f '%Y-%m-%d' "$1" +%s 2>/dev/null)" && [ -n "$e" ] && { printf '%s' "$e"; return 0; }
  return 1
}
days_until() {
  local e
  e="$(epoch_of "$1")" || return 1
  echo $(( (e - $(date +%s)) / 86400 ))
}
trim() { printf '%s' "$1" | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'; }

# --- the declared deadlines --------------------------------------------------------------------
read_deadlines() {   # $1 = "check" to validate only
  local checkonly="${1:-}" valid=0
  local n=0 line head rest what where d warn owner days lvl red detail
  [ -f "$DEADLINES" ] || { emit SKIP deadlines "$DEADLINES" "no declared deadlines file" ""; return 0; }
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    case "$(trim "$line")" in ''|'#'*) continue ;; esac
    n=$((n+1))
    head="${line%%::*}"; rest="${line#*::}"
    if [ "$rest" = "$line" ]; then
      emit RED deadlines "line $n" "no '::' separator: $(printf '%s' "$line" | head -c 100)" "write: <yyyy-mm-dd> <warn_days> <owner> :: <what> :: <where it is written up>"
      continue
    fi
    what="$(trim "${rest%%::*}")"; where="${rest#*::}"
    [ "$where" = "$rest" ] && where=""
    where="$(trim "$where")"
    # shellcheck disable=SC2086
    set -- $head
    d="${1:-}"; warn="${2:-}"; owner="${3:-UNASSIGNED}"
    case "$d" in
      [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
      *) emit RED deadlines "line $n" "date is not yyyy-mm-dd: '$d'" "fix $DEADLINES"; continue ;;
    esac
    case "$warn" in ''|*[!0-9]*) emit RED deadlines "line $n" "warn_days is not a number: '$warn'" "fix $DEADLINES"; continue ;; esac
    [ -n "$what" ] || { emit RED deadlines "line $n" "no 'what' between the separators" "fix $DEADLINES"; continue; }
    valid=$((valid+1))
    [ "$checkonly" = "check" ] && continue
    days="$(days_until "$d")" || { emit RED deadlines "line $n" "date does not parse on this machine: $d" "fix $DEADLINES, or install GNU date"; continue; }
    red=$(( warn / 4 )); [ "$red" -gt 21 ] && red=21; [ "$red" -lt 1 ] && red=1
    if   [ "$days" -lt 0 ];       then lvl=RED;   detail="overdue by $(( -days )) d ($d): $what"
    elif [ "$days" -le "$red" ];  then lvl=RED;   detail="in $days d ($d): $what"
    elif [ "$days" -le "$warn" ]; then lvl=AMBER; detail="in $days d ($d): $what"
    else                               lvl=OK;    detail="in $days d ($d): $what"; fi
    emit "$lvl" deadlines "$owner" "$detail" "$where"
  done < "$DEADLINES"
  [ "$n" -eq 0 ] && emit SKIP deadlines "$DEADLINES" "the file has no deadline lines" ""
  [ "$checkonly" = "check" ] && [ "$valid" -gt 0 ] && emit OK deadlines "$DEADLINES" "$valid line(s) parse (not evaluated)" ""
  return 0
}

# --- the project's own probes ------------------------------------------------------------------
parse_findings() {   # file source-name
  local n=0 lvl sec subj det rem line
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%$'\r'}"
    [ -n "$line" ] || continue
    n=$((n+1))
    lvl=""; sec=""; subj=""; det=""; rem=""
    IFS=$'\037' read -r lvl sec subj det rem <<< "$(printf '%s' "$line" | tr '\t' '\037')"
    if [ -z "$det" ] || ! emit "$lvl" "$sec" "$subj" "$det" "$rem"; then
      emit RED status "$2 line $n" "malformed finding, not LEVEL<TAB>section<TAB>subject<TAB>detail<TAB>remedy: $(printf '%s' "$line" | head -c 120)" "fix the probe; a finding that cannot be parsed cannot gate"
      continue
    fi
    case "$lvl" in RED|AMBER) [ -n "$rem" ] || emit RED status "$2 line $n" "$lvl finding without a remedy: $subj" "give every RED and AMBER a remedy a person can paste; a finding without a next step is a worry, not a check" ;; esac
  done < "$1"
  [ "$n" -eq 0 ] && emit SKIP estate "$2" "printed no findings" "a probe that finds nothing should print OK lines, so silence stays distinguishable from a probe that did not run"
  return 0
}
run_project() {
  local rc
  [ -f "$PROJECT" ] || { emit SKIP estate "$PROJECT" "no status.project.sh; the estate answers nothing yet" "write it: one finding per line, LEVEL<TAB>section<TAB>subject<TAB>detail<TAB>remedy, read-only"; return 0; }
  if command -v timeout >/dev/null 2>&1; then timeout 180 bash "$PROJECT" > "$TMP/out" 2> "$TMP/err"; rc=$?
  else bash "$PROJECT" > "$TMP/out" 2> "$TMP/err"; rc=$?; fi
  parse_findings "$TMP/out" "$PROJECT"
  if [ "$rc" -ne 0 ]; then
    emit RED estate "$PROJECT" "exited $rc$( [ -s "$TMP/err" ] && printf ': %s' "$(head -c 200 "$TMP/err" | tr '\n' ' ')" )" "run it by hand: bash $PROJECT"
  fi
  return 0
}

# --- report --------------------------------------------------------------------------------------
count() { wc -l < "$TMP/$1" | tr -d ' '; }
render() {
  local lvl sec subj det rem
  echo "status.sh  root=$ROOT  $(date -u +%Y-%m-%dT%H:%MZ)"
  for lvl in RED AMBER OK SKIP; do
    [ -s "$TMP/$lvl" ] || continue
    echo; echo "-- $lvl ($(count "$lvl")) --"
    while IFS=$'\037' read -r sec subj det rem; do
      printf '  %-10s %s\n' "$sec" "$subj"
      printf '             %s\n' "$det"
      [ -n "$rem" ] && printf '             > %s\n' "$rem"
    done < "$TMP/$lvl"
  done
  echo
  echo "$(count RED) RED, $(count AMBER) AMBER, $(count OK) OK, $(count SKIP) not checked."
  [ "$(count RED)" -gt 0 ] && echo "Lead with the RED items."
  return 0
}

case "$mode" in
  --canary)
    printf 'RED\tcanary\tsynthetic\tthis RED is injected by --canary\tnothing to do, it is the canary\n' > "$TMP/canary"
    printf 'this line is malformed on purpose and must be reported\n' >> "$TMP/canary"
    parse_findings "$TMP/canary" "canary"
    render
    if [ "$(count RED)" -lt 2 ]; then echo "canary: the parser LOST a RED; status.sh cannot gate and its greens are void"
    else echo "canary: this run must fail, and it does: a synthetic RED and a malformed line were both reported"; fi
    exit 1 ;;
  --check)
    read_deadlines check
    if [ -f "$PROJECT" ]; then
      if bash -n "$PROJECT" 2> "$TMP/syn"; then emit OK estate "$PROJECT" "parses (not run)" ""
      else emit RED estate "$PROJECT" "does not parse: $(head -c 200 "$TMP/syn" | tr '\n' ' ')" "fix the script"; fi
    fi
    render
    [ "$(count RED)" -eq 0 ] || exit 1
    exit 0 ;;
  "")
    read_deadlines
    run_project
    render
    [ "$(count RED)" -eq 0 ] || exit 1
    exit 0 ;;
esac
