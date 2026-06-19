#!/usr/bin/env sh
# lint-methodology.sh — run the Machine plane on the methodology docs THEMSELVES.
# Hard errors exit 1; soft issues warn. Run from repo root (alongside build-constitution.sh).
# Wire into CI next to the constitution build.
set -u
err=0; warn=0
fail() { printf 'ERROR: %s\n' "$1" >&2; err=$((err+1)); }
note() { printf 'warn:  %s\n' "$1" >&2; warn=$((warn+1)); }
DIR="docs/constitution"

# 1. AGENTS.md exists + size budget (32 KiB hard cap, 12 KiB target)
if [ ! -f AGENTS.md ]; then
  fail "AGENTS.md missing — run build-constitution.sh"
else
  bytes=$(wc -c < AGENTS.md)
  if [ "$bytes" -gt 32768 ]; then fail "AGENTS.md ${bytes}B > 32 KiB Codex cap"; fi
  if [ "$bytes" -gt 12288 ]; then note "AGENTS.md ${bytes}B > 12 KiB target — trim or path-scope"; fi

  # 2. AGENTS.md is FRESH — rebuild to a temp and compare (stale law is a top-class bug)
  tmp=$(mktemp 2>/dev/null || printf '%s' "./.agents.lint.tmp")
  {
    printf '# Project Constitution\n'
    printf '<!-- GENERATED from %s/*.md by build-constitution.sh — edit the spine, not this file. -->\n\n' "$DIR"
    for f in principles conventions security definition-of-done; do
      cat "$DIR/$f.md"; printf '\n\n'
    done
  } > "$tmp" 2>/dev/null
  if ! cmp -s "$tmp" AGENTS.md; then fail "AGENTS.md is STALE vs the spine — run 'sh build-constitution.sh' and commit the result"; fi
  rm -f "$tmp"
fi

# 3. CLAUDE.md imports AGENTS.md
if ! { [ -f CLAUDE.md ] && grep -q '@AGENTS.md' CLAUDE.md; }; then fail "CLAUDE.md missing or lacks @AGENTS.md"; fi

# 4. deep-review prompt vendored (deep mode needs it)
if [ ! -f codex-relay.deep-review-prompt.md ]; then fail "codex-relay.deep-review-prompt.md missing"; fi

# 5. security spine has its real sections
for h in "Threat model" "Secret handling" "external reviewer"; do
  if ! grep -qi "$h" "$DIR/security.md" 2>/dev/null; then fail "security.md missing section: $h"; fi
done

# 6. severity digest: contract present in DoD + a real, VALID schema file
if ! grep -q 'merge_allowed' "$DIR/definition-of-done.md" 2>/dev/null; then fail "definition-of-done.md missing the JSON digest contract"; fi
SCHEMA=docs/schemas/severity-digest.schema.json
if [ ! -f "$SCHEMA" ]; then
  fail "$SCHEMA missing"
else
  PY=""
  for c in python3 python py; do
    # require an interpreter that actually RUNS (skips the Windows Store python3 stub)
    if command -v "$c" >/dev/null 2>&1 && "$c" -c "import json" >/dev/null 2>&1; then PY="$c"; break; fi
  done
  if [ -n "$PY" ]; then
    "$PY" -c "import json; json.load(open('$SCHEMA'))" >/dev/null 2>&1 || fail "$SCHEMA is not valid JSON"
  else
    note "no working python on PATH — skipped JSON validity check on $SCHEMA"
  fi
fi

# 7. no mojibake / encoding corruption (broadened; exclude this script, which holds the patterns literally)
if grep -rq --exclude=lint-methodology.sh --exclude-dir=.git \
   -e 'â€' -e 'ðŸ' -e 'Ã¢' -e 'â‰' -e 'â†' -e 'âœ' -e 'âš' -e 'â‡' . 2>/dev/null; then
  fail "mojibake / encoding corruption detected (Windows-1252/UTF-8 double-encoding)"
fi

# 8. config smell: AGENTS.md shouldn't restate what the toolchain enforces
if [ -f AGENTS.md ] && grep -qiE 'prettier|eslint|gofmt|rustfmt|ruff|stylelint' AGENTS.md 2>/dev/null; then
  note "AGENTS.md names a formatter/linter — toolchain-first: let the tool enforce it, don't restate"
fi

# 9. constitution filled? (soft — placeholders mean Phase-0 incomplete)
if grep -q -e 'Template —' -e '<!--' AGENTS.md 2>/dev/null; then
  note "AGENTS.md still has template placeholders — Phase-0 constitution incomplete (expected in this template repo)"
fi

printf '\nlint-methodology: %s error(s), %s warning(s).\n' "$err" "$warn"
[ "$err" -eq 0 ]
