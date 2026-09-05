#!/usr/bin/env bash
# Install the kit into a repository (shape A) or a workspace above several clones (shape B).
#
#   bash <kit>/.claude/tools/install.sh <target> [--shape A|B] [--repos <dir>]
#
# Copies .claude/ from the kit (the folder two levels above this script) into the target. Never
# overwrites: an existing file in the target is left alone and listed. Merges nothing into an
# existing settings.json; it writes settings.kit.json beside it and says so. Creates working/, the
# knowledge-base skeleton, and the ignore and attribute lines, then runs verify.sh.
#
# Hook commands are written for this operating system: PowerShell on Windows, bash elsewhere.

set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT="$(cd "$HERE/../.." && pwd)"

target="${1:-}"; shape="A"; repos=""
shift || true
while [ $# -gt 0 ]; do
  case "$1" in
    --shape) shape="${2:-A}"; shift 2 ;;
    --repos) repos="${2:-}"; shift 2 ;;
    *) echo "unknown option: $1"; exit 1 ;;
  esac
done
[ -z "$target" ] && { echo "usage: install.sh <target> [--shape A|B] [--repos <dir>]"; exit 1; }
[ -d "$target" ] || { echo "target does not exist: $target"; exit 1; }
[ -d "$KIT/.claude/rules" ] || { echo "kit not found at $KIT (expected .claude/rules)"; exit 1; }
target="$(cd "$target" && pwd)"
case "$shape" in A|B) ;; *) echo "--shape must be A or B"; exit 1 ;; esac

kept=""; copied=0
copy_tree() {
  local sub="$1"
  [ -d "$KIT/.claude/$sub" ] || return 0
  while IFS= read -r -d '' f; do
    rel="${f#$KIT/}"; dest="$target/$rel"
    if [ -e "$dest" ]; then kept="$kept $rel"; continue; fi
    mkdir -p "$(dirname "$dest")"; cp "$f" "$dest"; copied=$((copied+1))
  done < <(find "$KIT/.claude/$sub" -type f -print0)
}
for sub in rules skills hooks tools; do copy_tree "$sub"; done

# settings.json for this operating system
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT) runner='powershell -NoProfile -ExecutionPolicy Bypass -File \"${CLAUDE_PROJECT_DIR}/.claude/hooks/%s.ps1\"' ;;
  *)                               runner='bash \"${CLAUDE_PROJECT_DIR}/.claude/hooks/%s.sh\"' ;;
esac
hook() { printf "$runner" "$1"; }
settings=$(cat <<EOF
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Edit|Write", "hooks": [ { "type": "command", "command": "$(hook guard-secrets)", "timeout": 15 } ] },
      { "matcher": "Bash|PowerShell", "hooks": [ { "type": "command", "command": "$(hook guard-commands)", "timeout": 10 } ] }
    ],
    "Stop": [
      { "hooks": [ { "type": "command", "command": "$(hook verify-on-finish)", "timeout": 30, "statusMessage": "Checking no test was weakened" } ] }
    ],
    "SessionStart": [
      { "matcher": "compact", "hooks": [ { "type": "command", "command": "$(hook resume-brief)", "timeout": 10 } ] }
    ]
  }
}
EOF
)
if [ -f "$target/.claude/settings.json" ]; then
  printf '%s\n' "$settings" > "$target/.claude/settings.kit.json"
  echo "settings.json already exists; the kit's hooks are in .claude/settings.kit.json. Merge the hooks block by hand and delete that file."
else
  printf '%s\n' "$settings" > "$target/.claude/settings.json"
fi

# working/
mkdir -p "$target/working"
[ -f "$target/working/README.md" ] || cp "$KIT/working/README.md" "$target/working/README.md"

# ignore and attribute lines, appended only when absent
touch "$target/.gitignore" "$target/.gitattributes"
for line in 'working/*' '!working/README.md' '.claude/settings.local.json' 'codex-relay.json'; do
  grep -qxF -- "$line" "$target/.gitignore" || printf '%s\n' "$line" >> "$target/.gitignore"
done
for line in '* text=auto eol=lf' '*.md text eol=lf' '*.sh text eol=lf' '*.ps1 text eol=lf' '*.json text eol=lf'; do
  grep -qxF -- "$line" "$target/.gitattributes" || printf '%s\n' "$line" >> "$target/.gitattributes"
done

# knowledge base skeleton
if [ "$shape" = "A" ]; then kb="$target/docs/knowledge-base"; where="inside the repository, under docs/knowledge-base/ (shape A)"; else kb="$target/knowledge-base"; where="at the workspace root, above the clones (shape B)"; fi
if [ ! -d "$kb" ]; then
  mkdir -p "$kb/00-orientation" "$kb/_investigations" "$kb/_readings"
  cat > "$kb/README.md" <<EOF
# Knowledge base

**Two warnings, before anything else.**

1. **Nothing here has been raised with the team.** Every finding was recorded from reading and measuring. Treat it as input to a conversation, not a verdict.
2. **Everything here is point-in-time.** Every substantial page carries a header saying when the facts were gathered, how they were verified, and what was not checked.

**The absence of a subject here is not evidence about it.** Silence is a gap, not a clean bill of health.

## Where it lives, and why

This knowledge base is committed $where. Record here the reason this shape was chosen, so the next person does not assume it was an accident.

## The rules for writing here

The path-scoped rule \`.claude/rules/knowledge-base.md\` loads whenever a file here is touched. Never a secret value. Describe the system, not the people. Keep negative results. Never assert a changeable condition in the present tense: write the measurement, dated, with its source.
EOF
  cat > "$kb/00-orientation/index.md" <<'EOF'
# Index

## Start with one of these

| If you are | Read |
|---|---|
| new to the project | `start-here.md` (to be written from the first measurements) |
| about to change something | `../99-pending.md` |

## Every page, and what it settles

| Page | What it settles |
|---|---|
| `README.md` | the two warnings and where this base lives |

## What is empty, and deliberately

Everything not listed above. Each section is added when its first measured page exists.
EOF
  cat > "$kb/99-pending.md" <<'EOF'
# Pending

Everything found and not acted on. One line each, same turn, grouped by who can act. `P0` blocks the current goal · `P1` matters soon · `P2` worth doing · `?` needs a decision. This is the index of what is open, not the evidence.

## 1 · Only the project team can answer these

## 2 · Needs a decision

## 3 · We can do this ourselves

## 4 · Worth doing when someone is in that code anyway
EOF
  cat > "$kb/decisions.md" <<'EOF'
# Decisions

One entry per real fork, newest first. Fields: decision · options considered · why · decided by · reversible or not · revisit when · supersedes.
EOF
fi

# shape B marker
if [ "$shape" = "B" ]; then
  if [ -n "$repos" ] && [ -d "$repos" ]; then
    printf 'WS_REPOS=%s\n' "$(cd "$repos" && pwd)" > "$target/.workspace"
  elif [ ! -f "$target/.workspace" ]; then
    echo "shape B: pass --repos <dir> so .workspace records where the clones are, or write it by hand (WS_REPOS=...)."
  fi
fi

echo "copied $copied files into $target/.claude/"
[ -n "$kept" ] && echo "left alone (already existed):$kept"
echo
echo "Next: open the assistant at $target and say: read START-HERE.md and follow it."
echo "Rules and hooks load at session start, so start a new session after this install."
echo
bash "$target/.claude/tools/verify.sh" || true
