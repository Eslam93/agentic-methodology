#!/usr/bin/env bash
# Prove, read-only, which capabilities this machine and this identity hold, before a runbook is followed.
#
#   bash .claude/tools/preflight.sh                prove every token on the capabilities page
#   bash .claude/tools/preflight.sh -c A,B         prove only these tokens (what one page requires)
#   bash .claude/tools/preflight.sh --list         list the tokens and their proof commands, run nothing
#   bash .claude/tools/preflight.sh --root <dir>   act on another tree (fixtures, tests)
#
# The vocabulary is the project's, on one page: docs/knowledge-base/00-orientation/capabilities.md in a
# single repository, knowledge-base/00-orientation/capabilities.md above several. One table row per token:
#
#   | `TOKEN` | blast | grants | `proof command` | expected | obtain |
#
#   TOKEN     a stable identifier: uppercase letters, digits and hyphens. A page names it in its `requires:`
#             header field, and the knowledge check refuses a token this page does not define.
#   blast     one marker: 🟢 read-only or non-production · 🟡 changes non-production, or reads production
#             data · 🔴 touches production. A task whose page requires a 🔴 token is Tier 3 by that alone.
#   proof     ONE read-only command, in backticks; a pipe inside it is written \| as Markdown requires.
#   expected  an extended regex the command's output must match; empty means "exits 0"; the word
#             UNRESOLVED means the project does not yet know how this capability is obtained, so the
#             row names who to ask and the tool reports it without failing.
#   obtain    who grants it, or which page has the script.
#
# WHY: runbooks used to state their author's access ("we are cluster admin", "the clones live at
# C:/..."). That is a snapshot, not a precondition: a second reader cannot tell whether THEY can follow
# the page, and it fails silently when the person changes. The sharpest case, measured 2026-08-01 on
# one installation: a required-reviewer gate records a non-member's approve vote and leaves the pull
# request blocked, so tooling that votes reports success while nothing moves. A capability with a
# read-only proof is the answer; a note is not.
#
# The proof commands are code the repository owns, reviewed like any other file in it. Never run this
# against a page from a branch you have not read.
#
# Exit 0 = every requested token PASSED (UNRESOLVED does not fail). Exit 1 = a requested token FAILED or
# is not defined. Exit 2 = no capabilities page, no token rows, or a bad invocation.

set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"

tokens=""; mode=""; root=""
while [ $# -gt 0 ]; do
  case "$1" in
    -c|--capabilities) tokens="${2:-}"; shift 2 ;;
    --list) mode=list; shift ;;
    --root) root="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,33p' "$0"; exit 0 ;;
    *) echo "unknown option: $1"; exit 2 ;;
  esac
done
if [ -n "$root" ]; then
  [ -d "$root" ] || { echo "root does not exist: $root"; exit 2; }
  ROOT="$(cd "$root" && pwd)"
fi
cd "$ROOT" || { echo "cannot cd to $ROOT"; exit 2; }

page=""
for p in docs/knowledge-base/00-orientation/capabilities.md knowledge-base/00-orientation/capabilities.md; do
  [ -f "$p" ] && { page="$p"; break; }
done
[ -n "$page" ] || { echo "no capabilities page: expected docs/knowledge-base/00-orientation/capabilities.md (or knowledge-base/... above several clones)"; exit 2; }

TMP="$(mktemp -d 2>/dev/null || mktemp -d -t preflight)"
trap 'rm -rf "$TMP"' EXIT

# One row per token. Cells are split on unescaped pipes; a \| inside a cell is a literal pipe.
awk '
/^\| *`[A-Z][A-Z0-9-]+` *\|/ {
  line = $0; sub(/\r$/, "", line)
  gsub(/\\\|/, "\001", line)
  n = split(line, c, "|")
  for (i = 1; i <= n; i++) { sub(/^[ \t]+/, "", c[i]); sub(/[ \t]+$/, "", c[i]); gsub(/\001/, "|", c[i]) }
  tok = c[2]; gsub(/`/, "", tok)
  proof = c[5]; sub(/^`/, "", proof); sub(/`$/, "", proof)
  printf "%s\037%s\037%s\037%s\037%s\n", tok, c[3], proof, c[6], c[7]
}' "$page" > "$TMP/rows"
[ -s "$TMP/rows" ] || { echo "the capabilities page has no token rows; expected: | \`TOKEN\` | blast | grants | \`proof\` | expected | obtain |"; exit 2; }

if [ "$mode" = list ]; then
  echo "capabilities from $page"
  while IFS=$'\037' read -r tok blast proof expected obtain; do
    printf '  %-24s %s  %s\n' "$tok" "$blast" "${proof:-(no proof)}"
  done < "$TMP/rows"
  exit 0
fi

if [ -z "$tokens" ]; then requested="$(cut -d $'\037' -f1 "$TMP/rows" | tr '\n' ' ')"
else requested="$(printf '%s' "$tokens" | tr ',' ' ')"; fi

pass=0; fail=0; unres=0
echo "preflight  page=$page"
for t in $requested; do
  row="$(awk -F'\037' -v t="$t" '$1 == t { print; exit }' "$TMP/rows")"
  if [ -z "$row" ]; then printf '  FAIL  %-22s not defined on %s\n' "$t" "$page"; fail=$((fail+1)); continue; fi
  IFS=$'\037' read -r tok blast proof expected obtain <<< "$row"
  if [ "$expected" = "UNRESOLVED" ]; then
    printf '  ????  %-22s UNRESOLVED: nobody has written how this is obtained. Ask: %s\n' "$t" "${obtain:-(no one named)}"
    unres=$((unres+1)); continue
  fi
  if [ -z "$proof" ]; then printf '  FAIL  %-22s no proof command on the page\n' "$t"; fail=$((fail+1)); continue; fi
  if command -v timeout >/dev/null 2>&1; then out="$(timeout 30 bash -c "$proof" 2>&1)"; rc=$?
  else out="$(bash -c "$proof" 2>&1)"; rc=$?; fi
  first="$(printf '%s' "$out" | head -1 | cut -c1-70)"
  if [ "$rc" -eq 0 ] && { [ -z "$expected" ] || printf '%s\n' "$out" | grep -qE -e "$expected"; }; then
    printf '  PASS  %-22s %s %s\n' "$t" "$blast" "$first"; pass=$((pass+1))
  else
    if [ "$rc" -ne 0 ]; then why="exit $rc"; else why="output did not match /$expected/"; fi
    printf '  FAIL  %-22s %s %s. %s. Obtain: %s\n' "$t" "$blast" "$why" "${first:-(no output)}" "${obtain:-(not written down)}"
    fail=$((fail+1))
  fi
done
echo
echo "$pass passed, $fail failed, $unres unresolved."
[ "$fail" -eq 0 ] || exit 1
exit 0
