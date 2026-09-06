#!/usr/bin/env bash
# Install or update the kit in a repository (shape A) or a workspace above several clones (shape B).
#
#   bash <kit>/.claude/tools/install.sh <target> [--shape A|B] [--repos <dir>]
#   bash <kit>/.claude/tools/install.sh <target> --update        bring managed files up to date
#   bash <kit>/.claude/tools/install.sh <target> --update --check say what an update would do
#
# Copies .claude/ from the kit (the folder two levels above this script) into the target. Never
# overwrites: an existing file in the target is left alone and listed. Merges nothing into an
# existing settings.json; it writes settings.kit.json beside it and says so. Creates working/, the
# knowledge-base skeleton, and the ignore and attribute lines, then runs verify.sh.
#
# Hook commands are written for this operating system: PowerShell on Windows, bash elsewhere.
#
# THE UPDATE MODEL. The kit is copied into the adopter's repository on purpose: the rules and hooks
# that govern a project should be readable in that project, reviewed in its pull requests, pinned
# with its history, and changeable locally. That makes upgrading a real problem, because a later
# release cannot tell an untouched file from one the adopter edited. So the installer records what
# it installed:
#
#   .claude/install-manifest.txt   the version installed, and the sha256 of each managed file as
#                                  it was delivered. Installer metadata, not project content.
#
# and an update replaces only what it can prove the adopter has not changed:
#
#   local hash == the hash in the manifest  ->  safe to replace with the new upstream file
#   local hash != the hash in the manifest  ->  the adopter changed it; preserve it and say so
#
# Nothing is merged, no conflict markers are written, no backup is made, and no LLM is consulted. A
# locally modified file is a supported state, not an error: it has deliberately stepped outside
# automatic replacement until the owner reconciles it. Modification is decided by content, never by
# a timestamp. Absence of manifest data is never permission to overwrite.

set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT="$(cd "$HERE/../.." && pwd)"

target="${1:-}"; shape="A"; repos=""; update=0; check=0
shift || true
while [ $# -gt 0 ]; do
  case "$1" in
    --shape) shape="${2:-A}"; shift 2 ;;
    --repos) repos="${2:-}"; shift 2 ;;
    --update) update=1; shift ;;
    --check|--dry-run) check=1; shift ;;
    *) echo "unknown option: $1"; exit 1 ;;
  esac
done
[ -z "$target" ] && { echo "usage: install.sh <target> [--shape A|B] [--repos <dir>] [--update] [--check]"; exit 1; }
[ -d "$target" ] || { echo "target does not exist: $target"; exit 1; }
[ -d "$KIT/.claude/rules" ] || { echo "kit not found at $KIT (expected .claude/rules)"; exit 1; }
target="$(cd "$target" && pwd)"
case "$shape" in A|B) ;; *) echo "--shape must be A or B"; exit 1 ;; esac

# --- managed files, the manifest, and the one classification table -------------------------------
# Managed means "shipped by this kit", and the list is taken from the kit itself, never by scanning
# the target: an adopter's own skill, hook, rule, or tool must never be mistaken for upstream
# content and must never be touched.
MANIFEST=".claude/install-manifest.txt"
managed_files() {
  ( cd "$KIT" && find .claude/rules .claude/skills .claude/hooks .claude/tools -type f 2>/dev/null ) \
    | sed 's|\\|/|g' | LC_ALL=C sort
}
digest_tool() {
  if command -v sha256sum >/dev/null 2>&1; then echo "sha256sum"
  elif command -v shasum >/dev/null 2>&1; then echo "shasum -a 256"; fi
}
DT="$(digest_tool)"
[ -n "$DT" ] || { echo "neither sha256sum nor shasum on PATH; the installer cannot record what it installed"; exit 1; }
# The bytes on disk, not the text: nothing here reads a file as text and writes it back, so a
# newline never changes under the installer and the same file always hashes the same way.
hash_file() { [ -f "$1" ] || return 1; $DT < "$1" | cut -d' ' -f1 | tr 'A-F' 'a-f'; }

kit_version() {
  local v
  v=$(git -C "$KIT" describe --tags --always 2>/dev/null) && [ -n "$v" ] && { printf '%s' "$v"; return; }
  printf 'unknown'
}

tmp="$(mktemp -d 2>/dev/null || mktemp -d -t kitinst)"
trap 'rm -rf "$tmp"' EXIT
: > "$tmp/old"; : > "$tmp/unman"
if [ -f "$target/$MANIFEST" ]; then
  grep '^managed '   "$target/$MANIFEST" 2>/dev/null | sed 's/^managed //'   > "$tmp/old"   || :
  grep '^unmanaged ' "$target/$MANIFEST" 2>/dev/null | sed 's/^unmanaged //' > "$tmp/unman" || :
fi
old_hash() { awk -v p="$1" '{h=$1; sub(/^[^ ]+ /, ""); if ($0 == p) { print h; exit } }' "$tmp/old"; }
was_unmanaged() { grep -qxF -- "$1" "$tmp/unman" 2>/dev/null; }

# One pass, one table, and every line of it readable. `apply` is 0 for --check.
r_added=""; r_updated=""; r_unchanged=""; r_modified=""; r_unverified=""
r_removedlocal=""; r_upstreamgone=""; r_failed=""; r_outdated=""; copied=0
# Write, then prove the bytes landed. A destination that is a directory, a full disk, or a
# read-only file must never end with the manifest recording a version that is not there: the
# manifest's whole value is that it describes what is actually on disk.
install_file() {   # src dest expected-hash
  local src="$1" dest="$2" want="$3"
  [ -d "$dest" ] && return 1
  mkdir -p "$(dirname "$dest")" 2>/dev/null || return 1
  cp "$src" "$dest" 2>/dev/null || return 1
  [ "$(hash_file "$dest" 2>/dev/null)" = "$want" ]
}
# $1 apply: 0 for --check, which writes nothing.
# $2 replace: 1 only for --update. A plain install never replaces an existing file, which is the
# promise in this script's header and the reason an update has to be asked for by name.
sync_managed() {
  local apply="$1" replace="${2:-0}" rel up loc old dest
  : > "$tmp/manifest.body"
  managed_files > "$tmp/new"
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    dest="$target/$rel"
    up="$(hash_file "$KIT/$rel")" || { r_failed="$r_failed $rel"; continue; }
    old="$(old_hash "$rel")"
    if [ -e "$dest" ]; then loc="$(hash_file "$dest")"; else loc=""; fi

    if [ -z "$old" ]; then
      # not managed by any previous installation of this kit
      if was_unmanaged "$rel" && [ -n "$loc" ]; then
        # Recorded once as the adopter's own. A later release whose bytes happen to match does not
        # make the path ours: it was theirs, and only their removing the file changes that. Without
        # this, a collision quietly became managed the first time upstream drifted into agreement,
        # and the release after that would have overwritten their file.
        r_unverified="$r_unverified $rel"; printf 'unmanaged %s\n' "$rel" >> "$tmp/manifest.body"
      elif [ -z "$loc" ]; then
        if [ "$apply" = 1 ]; then
          install_file "$KIT/$rel" "$dest" "$up" || { r_failed="$r_failed $rel"; continue; }
          copied=$((copied+1))
        fi
        r_added="$r_added $rel"; printf 'managed %s %s\n' "$up" "$rel" >> "$tmp/manifest.body"
      elif [ "$loc" = "$up" ]; then
        # byte-identical to what this release ships, so adopting it loses nothing
        r_unchanged="$r_unchanged $rel"; printf 'managed %s %s\n' "$up" "$rel" >> "$tmp/manifest.body"
      else
        # A path that exists and was never recorded. It may be an adopter's own file, or an older
        # upstream version from an install that predates the manifest. Those cannot be told apart,
        # so it is never overwritten and never recorded as an upstream basis: writing its hash as
        # though it were upstream is exactly what would defeat the mechanism later.
        r_unverified="$r_unverified $rel"; printf 'unmanaged %s\n' "$rel" >> "$tmp/manifest.body"
      fi
      continue
    fi

    if [ -z "$loc" ]; then
      # the adopter deleted a managed file. Putting it back would silently restore a control they
      # removed on purpose, so it is reported and the old basis is kept.
      r_removedlocal="$r_removedlocal $rel"; printf 'managed %s %s\n' "$old" "$rel" >> "$tmp/manifest.body"
    elif [ "$loc" = "$old" ]; then
      if [ "$up" = "$old" ]; then
        r_unchanged="$r_unchanged $rel"; printf 'managed %s %s\n' "$up" "$rel" >> "$tmp/manifest.body"
      elif [ "$replace" != 1 ]; then
        # a plain install: the file is still ours and still untouched, but replacing it is what
        # --update is for. Record what is actually on disk, which is the old version.
        r_outdated="$r_outdated $rel"; printf 'managed %s %s\n' "$old" "$rel" >> "$tmp/manifest.body"
      else
        if [ "$apply" = 1 ]; then
          install_file "$KIT/$rel" "$dest" "$up" || { r_failed="$r_failed $rel"; printf 'managed %s %s\n' "$old" "$rel" >> "$tmp/manifest.body"; continue; }
          copied=$((copied+1))
        fi
        r_updated="$r_updated $rel"; printf 'managed %s %s\n' "$up" "$rel" >> "$tmp/manifest.body"
      fi
    elif [ "$loc" = "$up" ]; then
      # diverged once and now byte-identical to this release: it has converged, so it rejoins the
      # managed set rather than being reported as modified for the rest of its life.
      r_unchanged="$r_unchanged $rel"; printf 'managed %s %s\n' "$up" "$rel" >> "$tmp/manifest.body"
    else
      # changed since it was installed. Preserve it, and keep the LAST UPSTREAM hash, not the local
      # one: the manifest records the version to compare against, not whatever happens to be there.
      r_modified="$r_modified $rel"; printf 'managed %s %s\n' "$old" "$rel" >> "$tmp/manifest.body"
    fi
  done < "$tmp/new"

  # managed once, gone from this release: reported, never deleted. Deletion is more consequential
  # than replacement, and a file the adopter still depends on is not ours to remove on a guess.
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    rel="${line#* }"
    grep -qxF -- "$rel" "$tmp/new" && continue
    r_upstreamgone="$r_upstreamgone $rel"
    printf 'managed %s %s\n' "${line%% *}" "$rel" >> "$tmp/manifest.body"
  done < "$tmp/old"
  # a path recorded as unmanaged that this release no longer ships stays recorded, so it is not
  # quietly forgotten and then collided with later
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    grep -qxF -- "$rel" "$tmp/new" && continue
    printf 'unmanaged %s\n' "$rel" >> "$tmp/manifest.body"
  done < "$tmp/unman"
}

write_manifest() {   # last, and atomically, so it never claims a copy that did not happen
  local out="$target/$MANIFEST"
  mkdir -p "$(dirname "$out")"
  {
    echo "# methodology installation manifest. Written by install.sh."
    echo "# Installer metadata, not project content: it records the upstream version of each managed"
    echo "# file so a later update can tell a file you have not touched from one you changed. An"
    echo "# update replaces only the first kind. Do not edit by hand; delete it only to start over,"
    echo "# which makes every managed file unverifiable again."
    echo "version $(kit_version)"
    echo "installed $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    LC_ALL=C sort "$tmp/manifest.body"
  } > "$out.tmp" && mv "$out.tmp" "$out"
}

report() {
  local label="$1" list="$2"
  [ -n "$list" ] || return 0
  echo "$label"
  for f in $list; do echo "  $f"; done
}

if [ "$update" = 1 ] || [ "$check" = 1 ]; then
  # --check goes down this path whether or not --update was given, because the one thing it must
  # never do is write. Read on its own it used to fall through to a full install, which is the
  # opposite of a preview and the easiest typo to make.
  if [ "$update" = 1 ] && [ ! -d "$target/.claude" ]; then
    echo "no .claude/ in $target; run the installer without --update first"; exit 1
  fi
  [ "$update" = 1 ] && [ ! -f "$target/$MANIFEST" ] && echo "no $MANIFEST here: this installation predates it. Files identical to this release are adopted; anything that differs is left alone and listed, because nothing records what it started as."
  sync_managed "$([ "$check" = 1 ] && echo 0 || echo 1)" "$update"
  if [ "$check" = 1 ]; then
    echo "check only, nothing was written. Version on offer: $(kit_version)"
    [ "$update" = 1 ] || echo "This is what a first install would copy; add --update to preview an update instead."
  else write_manifest || { echo "could not write $MANIFEST"; exit 1; }; fi
  echo
  report "Updated:"                             "$r_updated"
  report "Added:"                               "$r_added"
  report "Locally modified, preserved:"         "$r_modified"
  report "Present but never recorded, left alone:" "$r_unverified"
  report "Deleted here, not restored:"          "$r_removedlocal"
  report "Upstream removed, left in place:"     "$r_upstreamgone"
  report "Older than this release, not replaced:" "$r_outdated"
  report "FAILED:"                              "$r_failed"
  n_mod=$(printf '%s' "$r_modified $r_unverified" | wc -w | tr -d ' ')
  echo
  if [ -n "$r_failed" ]; then
    echo "the update did not complete: the files under FAILED were not written, and the manifest still records their previous version"
    exit 1
  fi
  if [ "$check" = 1 ]; then
    echo "nothing was written. $n_mod file(s) would be preserved for you to reconcile."
    exit 0
  fi
  echo "$n_mod file(s) were preserved for you to reconcile; nothing was merged or overwritten."
  echo
  bash "$target/.claude/tools/verify.sh"; vrc=$?
  echo
  if [ "$vrc" -ne 0 ]; then
    echo "FILES UPDATED, NOT YET VERIFIED: verification is red above. Fix what it names, then run"
    echo "  bash $target/.claude/tools/verify.sh"
    echo "until it is green. Until then this harness is not known to work."
    exit 1
  fi
  echo "UPDATED AND VERIFIED."
  echo "Rules and hooks load at session start, so start a new session after this update."
  exit 0
fi

kept=""
sync_managed 1 0
for f in $r_unchanged $r_unverified $r_outdated; do kept="$kept $f"; done

# settings.json for this operating system
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT) runner='powershell -NoProfile -ExecutionPolicy Bypass -File \"${CLAUDE_PROJECT_DIR}/.claude/hooks/%s.ps1\"' ;;
  *)                               runner='bash \"${CLAUDE_PROJECT_DIR}/.claude/hooks/%s.sh\"' ;;
esac
# Substitute, never use the runner as a printf format: printf would turn the \" that JSON needs
# into a bare quote and the generated settings.json would not parse (found 2026-09-05).
hook() { printf '%s' "${runner//%s/$1}"; }
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
for line in 'working/*' '!working/README.md' '.claude/settings.local.json' 'codex-relay.json' '.claude/worktrees/'; do
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
  today=$(date -u +%Y-%m-%d)
  # The skeleton has to satisfy the page schema knowledge-check.sh enforces from the first day,
  # or a fresh install fails its own verification. status: draft is what these are.
  cat > "$kb/00-orientation/index.md" <<EOF
---
title: Where every page is, and what each one settles
status: draft
as_of: $today
last_verified: $today
verification_method: Written by the kit installer; no page here has been measured yet
scope: This knowledge base only
confidence: Low. It is a skeleton, and each row is added when its first measured page exists
known_gaps: Everything. Nothing here has been written from a measurement
reverify_when: Every time a page is added, superseded, or removed
---
EOF
  cat >> "$kb/00-orientation/index.md" <<'EOF'

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
  cat > "$kb/decisions.md" <<EOF
---
title: Every decision in force, what each superseded, and when to revisit it
status: draft
as_of: $today
last_verified: $today
verification_method: Written by the kit installer; no decision has been recorded yet
scope: Decisions about this project, not about the kit
confidence: Low. It is empty until the first real fork is recorded
known_gaps: Every decision taken before this file existed is unrecorded
reverify_when: Whenever a decision is made or superseded
---
EOF
  cat >> "$kb/decisions.md" <<'EOF'

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

write_manifest || echo "warning: could not write $MANIFEST; a later --update will not be able to tell your edits from ours"
echo "copied $copied files into $target/.claude/"
[ -n "$kept" ] && echo "left alone (already existed):$kept"
echo "recorded $(grep -c '^managed ' "$target/$MANIFEST" 2>/dev/null || echo 0) managed files in $MANIFEST ($(kit_version))"
[ -n "$r_removedlocal" ] && { echo "these managed files are recorded but not present here; they were not restored:"; for f in $r_removedlocal; do echo "  $f"; done; }
[ -n "$r_failed" ] && { echo "these managed files could NOT be written, and the manifest does not claim them:"; for f in $r_failed; do echo "  $f"; done; }
[ -n "$r_outdated" ] && { echo "these managed files are older than this release and were NOT replaced, because a plain install never overwrites:"; for f in $r_outdated; do echo "  $f"; done; echo "run it again with --update to take them."; }
echo "To take a later release: bash <kit>/.claude/tools/install.sh $target --update  (add --check to preview)"
echo
echo "Next: open the assistant at $target and say: read START-HERE.md and follow it."
echo "Rules and hooks load at session start, so start a new session after this install."
echo
# The installer's own success is not the same as a usable harness. A copied tree whose hooks are not
# wired, or whose verification is red, is "files are here, now reconcile", not "installed".
bash "$target/.claude/tools/verify.sh"; vrc=$?
echo
if [ -n "$r_failed" ]; then
  echo "NOT INSTALLED: some managed files could not be written, listed above. The manifest does not"
  echo "claim them, so running this again retries them."
  exit 1
elif [ "$vrc" -ne 0 ]; then
  echo "FILES COPIED, NOT YET VERIFIED: verification is red above. Nothing here merges settings or"
  echo "edits your files, so the reconciliation is yours: fix what it names, then run"
  echo "  bash $target/.claude/tools/verify.sh"
  echo "until it is green. Until then this harness is not known to work."
  exit 1
fi
echo "INSTALLED AND VERIFIED."
exit 0
