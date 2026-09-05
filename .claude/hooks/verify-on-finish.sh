#!/usr/bin/env bash
# Stop hook: blocks a turn that weakened, skipped, or deleted a test.
# Deliberately light: pure git work, nothing that compiles. The full suite is behind verify.sh --full.
# Contract: exit 0 fine; exit 2 blocks and stderr goes to Claude. Honours stop_hook_active or it
# loops against itself. Claude Code overrides a Stop hook after eight consecutive blocks.
# Where it looks: every git checkout under WS_REPOS when cwd carries a .workspace marker (shape B;
# the marker wins, because a workspace root is itself a checkout); otherwise the repository at cwd
# when cwd is a git checkout (shape A). If neither, exit 0.
#
# What it compares against: the task baseline, when a brief carries one. baseline.sh seal writes
# baseline_commit.<checkout> into the front matter of working/<task>/brief.md at the owner's yes,
# and close adds closed_at. This hook reads every brief that carries an open seal and names the
# brief in each finding, so the comparison is always attributable to one agreed task; it never
# picks a task by recency. Normally exactly one brief is open.
#   - a weakening that was committed stays visible until the task closes: a diff against HEAD alone
#     shows nothing once the weakened test is committed (measured 2026-09-05);
#   - renames are detected (-M), so a staged git mv plus a removed assertion is compared old path
#     to new path;
#   - a test added during the task has no version at the baseline, so it is compared against HEAD,
#     as before this change.
# Fallback, never a block: no open seal, or none naming this checkout, and the comparison is
# against HEAD as before; a sealed commit rewritten by a rebase, amend, or squash is compared from
# its merge-base with HEAD; a sealed commit that does not exist here falls back to HEAD. Each
# fallback prints a note to stdout, which Claude Code keeps in its debug log for a Stop hook that
# exits 0: the note is for a person reading the log, not for the assistant. The hook never writes
# a baseline.

payload=$(cat)
printf '%s' "$payload" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

field() { printf '%s' "$payload" | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*\"([^\"\\\\]|\\\\.)*\"" | head -1 | sed 's/^[^:]*:[[:space:]]*"//; s/"$//; s#\\\\#/#g'; }
cwd=$(field cwd); [ -z "$cwd" ] && cwd="$PWD"
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

# ---- the briefs that carry an open seal -----------------------------------------------------
front_matter() { [ "$(head -1 "$1" 2>/dev/null)" = "---" ] || return 0; awk 'NR==1 {next} /^---$/ {exit} {print}' "$1"; }
seals=(); closedSeen=0
for b in "$cwd"/working/*/brief.md; do
  [ -f "$b" ] || continue
  fm=$(front_matter "$b")
  printf '%s\n' "$fm" | grep -Eq '^baseline_commit(\.[^:]*)?:' || continue
  if printf '%s\n' "$fm" | grep -Eq '^closed_at:'; then closedSeen=1; continue; fi
  seals+=("$b")
done
[ "${#seals[@]}" -eq 0 ] && [ "$closedSeen" = 1 ] && echo "note from verify-on-finish: every sealed brief under working/ is closed; comparing against HEAD."
[ "${#seals[@]}" -gt 1 ] && echo "note from verify-on-finish: ${#seals[@]} briefs carry an open baseline; each is evaluated in turn. Close the finished ones."

is_test_file() { printf '%s' "$1" | grep -Eiq '(\.test\.|\.spec\.|Tests?\.cs$|(^|/)(tests?|__tests__)/)'; }
assertions()   { grep -oE 'it[[:space:]]*\(|test[[:space:]]*\(|expect[[:space:]]*\(|\[Fact\]|\[Theory\]|Assert\.|\bShould\b|\bassert[[:space:]]' | wc -l | tr -d ' '; }
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

scan() { # repo base since
  local repo="$1" base="$2" since="$3" name status code file file2
  name=$(basename "$repo")
  status=$(git -C "$repo" diff --name-status -M "$base" 2>/dev/null) || return 0
  [ -z "$status" ] && return 0
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
}

if [ "${#seals[@]}" -eq 0 ]; then
  for repo in "${repos[@]}"; do scan "$repo" "HEAD" "HEAD"; done
else
  for b in "${seals[@]}"; do
    fm=$(front_matter "$b"); briefName="${b#$cwd/}"
    for repo in "${repos[@]}"; do
      name=$(basename "$repo")
      # the value is the last field, so a checkout folder with a space in its name still parses,
      # and grep -F means a name with a regex character does not become a pattern
      line=$(printf '%s\n' "$fm" | grep -F "baseline_commit.$name: " | head -1)
      sha="${line##* }"
      if [ -z "$line" ]; then
        echo "note from verify-on-finish: $briefName has no baseline for $name; comparing against HEAD."
        scan "$repo" "HEAD" "HEAD"
      elif git -C "$repo" merge-base --is-ancestor "$sha" HEAD 2>/dev/null; then
        scan "$repo" "$sha" "the task baseline ${sha:0:7} ($briefName)"
      elif mb=$(git -C "$repo" merge-base "$sha" HEAD 2>/dev/null) && [ -n "$mb" ]; then
        echo "note from verify-on-finish: the task baseline ${sha:0:7} in $briefName is not an ancestor of HEAD in $name (rewritten by a rebase, amend, or squash); comparing from its merge-base ${mb:0:7}."
        scan "$repo" "$mb" "the merge-base ${mb:0:7} of the rewritten task baseline ${sha:0:7} ($briefName)"
      else
        echo "note from verify-on-finish: the task baseline ${sha:0:7} in $briefName does not exist in $name; comparing against HEAD instead."
        scan "$repo" "HEAD" "HEAD"
      fi
    done
  done
fi

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
  echo "since the task baseline stays visible, committed or not, until the task is closed at hand-back."
} >&2
exit 2
