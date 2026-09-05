#!/usr/bin/env bash
# SessionStart hook, matcher "compact": after a compaction, put the disposable state back in front
# of the assistant so the build continues from the agreed brief rather than from a summary.
# Prints working/status.md, then the newest working/*/brief.md, capped. Exit 0 always.

payload=$(cat)
cwd=$(printf '%s' "$payload" | grep -oE '"cwd"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' | head -1 | sed 's/^[^:]*:[[:space:]]*"//; s/"$//; s#\\\\#/#g')
[ -z "$cwd" ] && cwd="$PWD"
working="$cwd/working"
[ -d "$working" ] || exit 0

if [ -f "$working/status.md" ]; then
  echo "After compaction. Re-read before continuing. working/status.md:"
  head -n 60 "$working/status.md"
fi

brief=$(find "$working" -mindepth 2 -maxdepth 3 -name brief.md -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
if [ -z "$brief" ]; then
  brief=$(ls -t "$working"/*/brief.md 2>/dev/null | head -1)
fi
if [ -n "$brief" ] && [ -f "$brief" ]; then
  echo
  echo "The task brief in flight, ${brief#$cwd/} (agreed with the owner; do not re-plan it):"
  head -n 80 "$brief"
fi
exit 0
