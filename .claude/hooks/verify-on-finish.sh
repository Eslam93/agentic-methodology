#!/usr/bin/env bash
# Stop hook: blocks a turn that weakened, skipped, or deleted a test.
# Deliberately light: pure git work, nothing that compiles. The full suite is behind verify.sh --full.
# Contract: exit 0 fine; exit 2 blocks and stderr goes to Claude. Honours stop_hook_active or it
# loops against itself. Claude Code overrides a Stop hook after eight consecutive blocks.
# Where it looks: the repository at cwd when cwd is a git checkout (shape A); otherwise every git
# checkout under WS_REPOS from the .workspace marker at cwd (shape B). If neither, exit 0.

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
if [ -d "$cwd/.git" ]; then
  repos=("$cwd")
elif [ -f "$cwd/.workspace" ]; then
  reposRoot=$(grep -E -e '^WS_REPOS=' "$cwd/.workspace" | head -1 | cut -d= -f2-)
  if [ -n "$reposRoot" ] && [ -d "$reposRoot" ]; then
    for d in "$reposRoot"/*/; do [ -d "$d/.git" ] && repos+=("${d%/}"); done
  fi
fi
[ "${#repos[@]}" -eq 0 ] && exit 0
command -v git >/dev/null 2>&1 || exit 0

is_test_file() { printf '%s' "$1" | grep -Eiq '(\.test\.|\.spec\.|Tests?\.cs$|(^|/)(tests?|__tests__)/)'; }
assertions()   { grep -oE 'it[[:space:]]*\(|test[[:space:]]*\(|expect[[:space:]]*\(|\[Fact\]|\[Theory\]|Assert\.|\bShould\b|\bassert[[:space:]]' | wc -l | tr -d ' '; }
skips()        { grep -oiE '\.skip[[:space:]]*\(|\.only[[:space:]]*\(|\[Skip|@skip|xit[[:space:]]*\(|xdescribe[[:space:]]*\(' | wc -l | tr -d ' '; }

problems=""
for repo in "${repos[@]}"; do
  name=$(basename "$repo")
  status=$(git -C "$repo" diff --name-status HEAD 2>/dev/null) || continue
  [ -z "$status" ] && continue
  while IFS=$'\t' read -r code file; do
    [ -z "$file" ] && continue
    is_test_file "$file" || continue
    case "$code" in
      D*) problems="$problems
  DELETED  $name/$file" ;;
      M*)
        before=$(git -C "$repo" show "HEAD:$file" 2>/dev/null)
        after=$(cat "$repo/$file" 2>/dev/null)
        b=$(printf '%s' "$before" | assertions); a=$(printf '%s' "$after" | assertions)
        [ "$a" -lt "$b" ] && problems="$problems
  WEAKENED $name/$file  (assertions $b -> $a)"
        sb=$(printf '%s' "$before" | skips); sa=$(printf '%s' "$after" | skips)
        [ "$sa" -gt "$sb" ] && problems="$problems
  SKIPPED  $name/$file  (skip markers $sb -> $sa)" ;;
    esac
  done <<< "$status"
done

[ -z "$problems" ] && exit 0
{
  echo "STOP: a test was weakened, skipped, or deleted in this change."
  echo "$problems"
  echo
  echo "Removing or editing a test to make a suite pass hides the behaviour the test existed"
  echo "to protect. Do one of these, then finish:"
  echo "  - restore the assertions and fix the code instead; or"
  echo "  - if the test genuinely encoded wrong behaviour, say so explicitly to the user,"
  echo "    explain why the old assertion was wrong, and get their agreement."
  echo
  echo "Do not silence this by reverting the file and re-applying the same edit."
} >&2
exit 2
