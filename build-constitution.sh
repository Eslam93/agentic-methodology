#!/usr/bin/env sh
# Assemble the canonical AGENTS.md from the constitution spine.
#
# Why a build step: Codex reads ONLY the literal bytes of AGENTS.md (git-root -> cwd,
# 32 KiB cap, no @import, no link-following). The spine MUST be inlined, not referenced,
# or the independent reviewer never sees conventions / security / definition-of-done.
# Claude Code reads it via CLAUDE.md's `@AGENTS.md` import.
set -eu

OUT="AGENTS.md"
DIR="docs/constitution"
LIMIT=32768  # Codex project_doc_max_bytes default (32 KiB)

{
  printf '# Project Constitution\n'
  printf '<!-- GENERATED from %s/*.md by build-constitution.sh — edit the spine, not this file. -->\n\n' "$DIR"
  for f in principles conventions security definition-of-done; do
    cat "$DIR/$f.md"
    printf '\n\n'
  done
} > "$OUT"

bytes=$(wc -c < "$OUT")
if [ "$bytes" -gt "$LIMIT" ]; then
  printf 'WARNING: %s is %s bytes (> %s KiB Codex cap) — tighten the spine.\n' \
    "$OUT" "$bytes" "$((LIMIT/1024))" >&2
elif [ "$bytes" -gt 12288 ]; then
  printf 'note: %s is %s bytes (> 12 KiB target) — keep operational rules only; move rationale to DECISIONS.md.\n' \
    "$OUT" "$bytes" >&2
fi
printf 'Built %s (%s bytes). Verify loads: Claude `/memory`; Codex echoes its instruction files.\n' \
  "$OUT" "$bytes"
