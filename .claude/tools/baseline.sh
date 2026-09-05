#!/usr/bin/env bash
# The task baseline: the approved starting point, written into the task's own brief.
#
#   bash .claude/tools/baseline.sh seal  <task> [--force]   record the approval in the brief
#   bash .claude/tools/baseline.sh check <task>             brief unchanged; every commit still reachable
#   bash .claude/tools/baseline.sh close <task>             the task is accepted; the Stop hook goes back to HEAD
#
# Run it from the repository root (shape A) or the workspace root (shape B; the .workspace marker
# wins when both exist, as in layout.sh).
#
# It writes front matter at the top of working/<task>/brief.md, the file the owner approved:
#
#   task, approved_at, one baseline_commit.<checkout> per checkout, brief_sha256 (the digest of
#   the body below the front matter), pre_existing (a count); closed_at is added by close.
#
# The metadata therefore travels with the agreement, one brief, one baseline, no separate state
# file: `check` is told which task to check, and the Stop hook reads the same keys and names the
# brief in every finding. The list of files that were already dirty goes to
# working/<task>/pre-existing.txt beside the brief, because it is a list, not metadata; nothing
# reads it but the owner and /work.
#
# The tool exists so that three values are produced the same way every time: the commit from
# `git rev-parse`, not from memory; the digest over the same bytes at seal and at check; the dirty
# files captured before the first edit. It signs nothing and locks nothing.

set -uo pipefail

usage() { sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 1; }
die()   { echo "baseline.sh: $*" >&2; exit 1; }

cmd="${1:-}"; task="${2:-}"; flag="${3:-}"
[ -z "$cmd" ] && usage
[ -z "$task" ] && usage

root="$PWD"
repos=()
if [ -f "$root/.workspace" ]; then
  _here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  . "$_here/layout.sh"
  while IFS= read -r r; do [ -n "$r" ] && repos+=("$r"); done < <(ws_repos)
elif [ -d "$root/.git" ]; then
  repos=("$root")
else
  die "run it from the repository root or the workspace root (no .git and no .workspace here)"
fi
[ "${#repos[@]}" -eq 0 ] && die "no git checkout found"

dir="$root/working/$task"; brief="$dir/brief.md"
[ -f "$brief" ] || die "no brief at working/$task/brief.md; write the agreed brief first"

# The seal's own keys. Everything else in an existing front matter is kept as it was.
SEAL_KEYS='^(task|approved_at|baseline_commit(\.[^:]*)?|brief_sha256|pre_existing|closed_at):'

front_matter() { # the lines between the opening and closing --- , or nothing
  [ "$(head -1 "$1" 2>/dev/null)" = "---" ] || return 0
  awk 'NR==1 {next} /^---$/ {exit} {print}' "$1"
}
body() {        # everything that is not the front matter: what the owner approved
  if [ "$(head -1 "$1" 2>/dev/null)" = "---" ]; then
    awk 'NR==1 {next} !seen && /^---$/ {seen=1; next} seen {print}' "$1"
  else cat "$1"; fi
}
digest_tool() {
  if command -v sha256sum >/dev/null 2>&1; then echo "sha256sum"
  elif command -v shasum >/dev/null 2>&1; then echo "shasum -a 256"; fi
}
digest_body() { local t; t=$(digest_tool); [ -n "$t" ] || return 1; body "$1" | $t | cut -d' ' -f1; }

fm=$(front_matter "$brief")
sealed=0; printf '%s\n' "$fm" | grep -Eq '^baseline_commit(\.[^:]*)?:' && sealed=1
closed=0; printf '%s\n' "$fm" | grep -Eq '^closed_at:' && closed=1

case "$cmd" in
  seal)
    if [ "$sealed" = 1 ] && [ "$flag" != "--force" ]; then
      echo "baseline.sh: working/$task/brief.md is already sealed. A baseline does not move once sealed." >&2
      echo "If the owner changed the agreement, re-seal deliberately with --force and say so; if the task is done, close it." >&2
      exit 1
    fi
    [ -n "$(digest_tool)" ] || die "neither sha256sum nor shasum on PATH"
    sum=$(digest_body "$brief") || die "could not digest $brief"
    lines=()
    for repo in "${repos[@]}"; do
      name=$(basename "$repo")
      sha=$(git -C "$repo" rev-parse HEAD 2>/dev/null) || die "$name has no commit yet; commit something first"
      lines+=("baseline_commit.$name: $sha")
    done
    pre="$dir/pre-existing.txt"; : > "$pre.tmp"
    for repo in "${repos[@]}"; do
      name=$(basename "$repo")
      # working/ is ignored in an installed repository; skip it anyway so the seal never lists itself
      git -C "$repo" status --porcelain --untracked-files=all 2>/dev/null \
        | grep -vE '^.. "?working/' | sed "s|^|$name |" >> "$pre.tmp"
    done
    n=$(wc -l < "$pre.tmp" | tr -d ' ')
    when=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    kept=$(printf '%s\n' "$fm" | grep -Ev "$SEAL_KEYS" | grep -v '^$')
    {
      echo "---"
      echo "task: $task"
      echo "approved_at: $when"
      printf '%s\n' "${lines[@]}"
      echo "brief_sha256: $sum"
      echo "pre_existing: $n"
      [ -n "$kept" ] && printf '%s\n' "$kept"
      echo "---"
      body "$brief"
    } > "$brief.tmp" && mv "$brief.tmp" "$brief" && mv "$pre.tmp" "$pre" || die "could not write working/$task/brief.md"
    echo "sealed working/$task/brief.md at $when"
    printf '  %s\n' "${lines[@]}"
    if [ "$n" -eq 0 ]; then echo "  working tree clean: nothing pre-existing"
    else echo "  $n pre-existing change(s) recorded in working/$task/pre-existing.txt; they belong to the owner:"; sed 's/^/    /' "$pre"; fi
    ;;

  check)
    [ "$sealed" = 1 ] || die "working/$task/brief.md carries no baseline; seal it at the owner's yes"
    bad=0
    [ "$closed" = 1 ] && echo "closed: $(printf '%s\n' "$fm" | grep -E '^closed_at:' | head -1 | cut -d' ' -f2-)"
    want=$(printf '%s\n' "$fm" | grep -E '^brief_sha256:' | head -1 | awk '{print $NF}')
    have=$(digest_body "$brief") || die "neither sha256sum nor shasum on PATH"
    if [ "$want" = "$have" ]; then echo "brief unchanged since approval"
    else echo "BRIEF CHANGED since approval: sealed $want, now $have"; bad=1; fi
    while IFS= read -r line; do
      rest="${line#baseline_commit.}"; sha="${rest##* }"; name="${rest% *}"; name="${name%:}"
      repo=""; for r in "${repos[@]}"; do [ "$(basename "$r")" = "$name" ] && repo="$r"; done
      if [ -z "$repo" ]; then echo "$name: checkout not found"; bad=1; continue; fi
      if git -C "$repo" merge-base --is-ancestor "$sha" HEAD 2>/dev/null; then
        echo "$name: baseline ${sha:0:7} is an ancestor of HEAD ($(git -C "$repo" rev-list --count "$sha..HEAD") commit(s) since)"
      elif mb=$(git -C "$repo" merge-base "$sha" HEAD 2>/dev/null) && [ -n "$mb" ]; then
        echo "$name: baseline ${sha:0:7} was REWRITTEN (rebase, amend, or squash); the Stop hook compares from its merge-base ${mb:0:7}"; bad=1
      else
        echo "$name: baseline ${sha:0:7} does NOT exist in this checkout; the Stop hook compares against HEAD instead"; bad=1
      fi
    done < <(printf '%s\n' "$fm" | grep -E '^baseline_commit\.')
    exit $bad
    ;;

  close)
    [ "$sealed" = 1 ] || die "working/$task/brief.md carries no baseline"
    [ "$closed" = 1 ] && { echo "already closed"; exit 0; }
    when=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    awk -v w="closed_at: $when" 'NR==1 {print; next} !done && /^---$/ {print w; print; done=1; next} {print}' "$brief" > "$brief.tmp" \
      && mv "$brief.tmp" "$brief" || die "could not write working/$task/brief.md"
    echo "closed working/$task/brief.md at $when; the Stop hook compares against HEAD from now on"
    ;;

  *) usage ;;
esac
