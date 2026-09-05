#!/usr/bin/env bash
# Stop hook: blocks a turn that weakened, skipped, or deleted a test.
# Deliberately light: pure git work, nothing that compiles. The full suite is behind verify.sh --full.
# Contract: exit 0 fine; exit 2 blocks and stderr goes to Claude. Honours stop_hook_active or it
# loops against itself. Claude Code overrides a Stop hook after eight consecutive blocks.
# Where it looks: every git checkout under WS_REPOS when cwd carries a .workspace marker (shape B;
# the marker wins, because a workspace root is itself a checkout); otherwise the repository at cwd
# when cwd is a git checkout (shape A). If neither, exit 0.
#
# What it compares against: the baseline of the task THIS session is carrying. baseline.sh seal
# writes baseline_commit.<checkout> into the front matter of working/<task>/brief.md at the owner's
# yes and binds it to the session in working/active-tasks/<session id>. This hook reads the pointer
# for the session id the host gives it, so two sessions sharing one checkout each measure their own
# task, and no brief is chosen by recency.
#   - a weakening that was committed stays visible: a diff against HEAD alone shows nothing once the
#     weakened test is committed (measured 2026-09-05);
#   - renames are detected (-M), so a staged git mv plus a removed assertion is compared old path
#     to new path;
#   - a test added during the task has no version at the baseline, so it is compared against HEAD,
#     as it was before the baseline existed.
# Fallback, never a block, and never a guess at which task is active: no session id, no pointer, a
# pointer that does not resolve, a brief with no seal, or a seal that does not name this checkout,
# and the comparison is against HEAD as it was before this mechanism. A sealed commit rewritten by
# a rebase, amend, or squash is compared from its merge-base with HEAD; one that does not exist here
# falls back to HEAD. The last four print a note; a session with no id and a session with no pointer
# are the ordinary case and stay quiet. A note goes to stdout, which Claude Code keeps in its debug
# log for a Stop hook that exits 0: it is for a person reading the log, not for the assistant.
# The hook never writes a pointer and never seals anything.

payload=$(cat)
printf '%s' "$payload" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

field() { printf '%s' "$payload" | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" | head -1 | sed 's/^[^:]*:[[:space:]]*"//; s/"$//; s#\\\\#/#g'; }
cwd=$(field cwd); [ -z "$cwd" ] && cwd="$PWD"
session=$(field session_id)
transcript=$(field transcript_path)

# ---- rationalization note (never blocks) -------------------------------------------------
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  phrase=$(tail -n 40 "$transcript" | grep -oiE 'skip (the )?tests? for now|pre-existing (bug|issue|failure)|good enough for now|can be fixed later|temporarily disabl|out of scope for this|will fix in a follow-?up' | head -1)
  [ -n "$phrase" ] && echo "note from verify-on-finish: the last message carries a rationalization phrase ($phrase). Worth a second look before accepting."
fi

# ---- where to look -------------------------------------------------------------------------
repos=()
if [ -f "$cwd/.workspace" ]; then
  reposRoot=$(grep -E -e '^WS_REPOS=' "$cwd/.workspace" | head -1 | cut -d= -f2-)
  if [ -n "$reposRoot" ] && [ -d "$reposRoot" ]; then
    for d in "$reposRoot"/*/; do [ -d "$d/.git" ] && repos+=("${d%/}"); done
  fi
elif [ -d "$cwd/.git" ]; then
  repos=("$cwd")
fi
[ "${#repos[@]}" -eq 0 ] && exit 0
command -v git >/dev/null 2>&1 || exit 0

# ---- the brief this session is carrying, if any ----------------------------------------------
briefFile=""; briefName=""
if printf '%s' "$session" | grep -Eq '^[A-Za-z0-9][A-Za-z0-9_-]{7,63}$'; then
  ptr="$cwd/working/active-tasks/$session"
  if [ -f "$ptr" ]; then
    rel=$(grep -m1 -vE '^[[:space:]]*$' "$ptr" 2>/dev/null | tr -d '\r' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    # one task folder, one brief: never a relay path, never an absolute path, never a traversal
    if printf '%s' "$rel" | grep -Eq '^working/[A-Za-z0-9][A-Za-z0-9._-]*/brief\.md$' && [ -f "$cwd/$rel" ]; then
      briefFile="$cwd/$rel"; briefName="$rel"
    else
      echo "note from verify-on-finish: the active-task pointer for this session does not resolve to a task brief; comparing against HEAD."
    fi
  fi
fi
# Trailing whitespace on a fence or a key must not change the answer, and it must not change it
# differently from the PowerShell twin, which trims.
front_matter() {
  head -1 "$1" 2>/dev/null | sed 's/[[:space:]]*$//' | grep -qx -- '---' || return 0
  awk 'NR==1 {next} {t=$0; sub(/[[:space:]]+$/, "", t)} t=="---" {exit} {print}' "$1"
}
fm=""
if [ -n "$briefFile" ]; then
  fm=$(front_matter "$briefFile")
  if ! printf '%s\n' "$fm" | grep -Eq '^baseline_commit(\.[^:]*)?:'; then
    echo "note from verify-on-finish: $briefName carries no baseline; comparing against HEAD."
    briefFile=""; fm=""
  fi
fi

is_test_file() { printf '%s' "$1" | grep -Eiq '(\.test\.|\.spec\.|Tests?\.cs$|(^|/)(tests?|__tests__)/)'; }
# Word boundaries, so that submit( and protest( are not counted as test( and it(, and so that this
# counter agrees with the PowerShell twin, which has always had them.
assertions()   { grep -oE '\bit[[:space:]]*\(|\btest[[:space:]]*\(|\bexpect[[:space:]]*\(|\[Fact\]|\[Theory\]|\bAssert\.|\bShould\b|\bassert[[:space:]]' | wc -l | tr -d ' '; }
skips()        { grep -oiE '\.skip[[:space:]]*\(|\.only[[:space:]]*\(|\[Skip|@skip|xit[[:space:]]*\(|xdescribe[[:space:]]*\(' | wc -l | tr -d ' '; }

problems=""
compare() { # repo base label oldpath newpath since -> appends to problems
  local repo="$1" base="$2" label="$3" old="$4" new="$5" since="$6" before after b a sb sa
  before=$(git -C "$repo" show "$base:$old" 2>/dev/null)
  after=$(cat "$repo/$new" 2>/dev/null)
  b=$(printf '%s' "$before" | assertions); a=$(printf '%s' "$after" | assertions)
  [ "$a" -lt "$b" ] && problems="$problems
  WEAKENED $label  (assertions $b -> $a) since $since"
  sb=$(printf '%s' "$before" | skips); sa=$(printf '%s' "$after" | skips)
  [ "$sa" -gt "$sb" ] && problems="$problems
  SKIPPED  $label  (skip markers $sb -> $sa) since $since"
}

for repo in "${repos[@]}"; do
  name=$(basename "$repo")
  base="HEAD"; since="HEAD"
  if [ -n "$briefFile" ]; then
    # index()==1 is a literal, anchored prefix match: a checkout name with a space, a regex
    # character, or a glob character is safe, and a line that merely mentions the key cannot win
    sha=$(printf '%s\n' "$fm" | awk -v key="baseline_commit.$name: " \
      'index($0, key)==1 {v=substr($0, length(key)+1); gsub(/^[[:space:]]+|[[:space:]]+$/, "", v); print v; exit}')
    if [ -z "$sha" ]; then
      echo "note from verify-on-finish: $briefName has no baseline for $name; comparing against HEAD."
    elif git -C "$repo" merge-base --is-ancestor "$sha" HEAD 2>/dev/null; then
      base="$sha"; since="the task baseline ${sha:0:7} ($briefName)"
    elif mb=$(git -C "$repo" merge-base "$sha" HEAD 2>/dev/null) && [ -n "$mb" ]; then
      base="$mb"; since="the merge-base ${mb:0:7} of the rewritten task baseline ${sha:0:7} ($briefName)"
      echo "note from verify-on-finish: the task baseline ${sha:0:7} in $briefName is not an ancestor of HEAD in $name (rewritten by a rebase, amend, or squash); comparing from its merge-base ${mb:0:7}."
    else
      echo "note from verify-on-finish: the task baseline ${sha:0:7} in $briefName does not exist in $name; comparing against HEAD instead."
    fi
  fi
  status=$(git -C "$repo" diff --name-status -M "$base" 2>/dev/null) || continue
  [ -z "$status" ] && continue
  while IFS=$'\t' read -r code file file2; do
    [ -z "$file" ] && continue
    case "$code" in
      D*) is_test_file "$file" || continue
          problems="$problems
  DELETED  $name/$file since $since" ;;
      M*) is_test_file "$file" || continue
          compare "$repo" "$base" "$name/$file" "$file" "$file" "$since" ;;
      R*) { is_test_file "$file" || is_test_file "$file2"; } || continue
          compare "$repo" "$base" "$name/$file -> $file2 (renamed)" "$file" "$file2" "$since" ;;
      A*) is_test_file "$file" || continue
          # added during the task: its only earlier version is the one committed since the baseline
          git -C "$repo" cat-file -e "HEAD:$file" 2>/dev/null || continue
          compare "$repo" "HEAD" "$name/$file (added during the task)" "$file" "$file" "HEAD" ;;
    esac
  done <<< "$status"
done

[ -z "$problems" ] && exit 0
{
  echo "STOP: a test was weakened, skipped, or deleted."
  echo "$problems"
  echo
  echo "Removing or editing a test to make a suite pass hides the behaviour the test existed"
  echo "to protect. Do one of these, then finish:"
  echo "  - restore the assertions and fix the code instead; or"
  echo "  - if the test genuinely encoded wrong behaviour, say so explicitly to the user,"
  echo "    explain why the old assertion was wrong, and get their agreement."
  echo
  echo "Do not silence this by reverting the file and re-applying the same edit. A change made"
  echo "since the task baseline stays visible, committed or not, for as long as this session"
  echo "carries this task."
} >&2
exit 2
