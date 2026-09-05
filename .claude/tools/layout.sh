#!/usr/bin/env bash
# Work out where this workspace's pieces are, on THIS machine. Source it; never hardcode a path.
#
#   . .claude/tools/layout.sh            sets WS_ROOT, WS_REPOS, WS_LAYOUT
#   bash .claude/tools/layout.sh --report
#
# WHY: a previous workspace lost people at the first step by requiring a specific folder on a
# specific drive. The clones live wherever they already live; everything else adapts.
#
# RESOLVES
#   WS_ROOT    the root: where .claude/, the knowledge base, and working/ live
#   WS_REPOS   the folder CONTAINING the clones (shape B), or WS_ROOT itself (shape A)
#   WS_LAYOUT  single | nested | flat | external | recorded | env | missing
#
# ORDER, first hit wins:
#   1. shape A: WS_ROOT is itself a git checkout and has no .workspace marker
#   2. the .workspace marker at the root (WS_REPOS=... and optionally WS_ANCHOR=...)
#   3. the WS_REPOS environment variable
#   4. discovery: the anchor repository (WS_ANCHOR, default: any git checkout) in the usual places
#
# It never returns an empty root: when nothing is found it falls back to the caller's directory
# and says so with WS_LAYOUT=missing. Branch on that, never on an empty variable.

ws_resolve_layout() {
    local start="${1:-$PWD}"
    WS_ROOT=""
    local d="$start"
    for _ in 1 2 3 4 5 6; do
        if [ -f "$d/.workspace" ] || [ -d "$d/.claude" ]; then WS_ROOT="$d"; break; fi
        local parent; parent="$(cd "$d/.." 2>/dev/null && pwd)" || break
        [ "$parent" = "$d" ] && break
        d="$parent"
    done
    [ -z "$WS_ROOT" ] && WS_ROOT="$start"

    # 1. shape A
    if [ -d "$WS_ROOT/.git" ] && [ ! -f "$WS_ROOT/.workspace" ]; then
        WS_REPOS="$WS_ROOT"; WS_LAYOUT="single"; return 0
    fi

    # 2. the marker
    if [ -f "$WS_ROOT/.workspace" ]; then
        local v
        v=$(grep -E -e '^WS_REPOS=' "$WS_ROOT/.workspace" 2>/dev/null | head -1 | cut -d= -f2-)
        WS_ANCHOR=$(grep -E -e '^WS_ANCHOR=' "$WS_ROOT/.workspace" 2>/dev/null | head -1 | cut -d= -f2-)
        if [ -n "$v" ] && [ -d "$v" ]; then
            WS_REPOS="$(cd "$v" && pwd)"; WS_LAYOUT="recorded"; return 0
        fi
    fi

    # 3. the environment
    if [ -n "${WS_REPOS:-}" ] && [ -d "${WS_REPOS}" ]; then WS_LAYOUT="env"; return 0; fi

    # 4. discovery
    local candidate
    for candidate in "$WS_ROOT/repos" "$WS_ROOT" "$WS_ROOT/src" "$WS_ROOT/source" "$WS_ROOT/code" "$WS_ROOT/.."; do
        [ -d "$candidate" ] || continue
        if [ -n "${WS_ANCHOR:-}" ]; then
            [ -d "$candidate/$WS_ANCHOR/.git" ] || continue
        else
            ls -d "$candidate"/*/.git >/dev/null 2>&1 || continue
        fi
        WS_REPOS="$(cd "$candidate" && pwd)"
        case "$candidate" in
            "$WS_ROOT/repos") WS_LAYOUT="nested" ;;
            "$WS_ROOT")       WS_LAYOUT="flat" ;;
            *)                WS_LAYOUT="external" ;;
        esac
        return 0
    done

    WS_REPOS="$WS_ROOT/repos"; WS_LAYOUT="missing"; return 1
}

# Path to one clone, or nothing.
ws_repo()  { [ -d "$WS_REPOS/$1/.git" ] && printf '%s' "$WS_REPOS/$1"; }

# Every clone present, one path per line. In shape A, the root itself.
ws_repos() {
    if [ "${WS_LAYOUT:-}" = "single" ]; then printf '%s\n' "$WS_ROOT"; return; fi
    local d
    for d in "$WS_REPOS"/*/; do [ -d "$d/.git" ] && printf '%s\n' "${d%/}"; done
}

ws_resolve_layout "$PWD"

if [ "${1:-}" = "--report" ]; then
    echo "WS_ROOT    $WS_ROOT"
    echo "WS_REPOS   $WS_REPOS"
    echo "WS_LAYOUT  $WS_LAYOUT"
    echo "checkouts  $(ws_repos | wc -l | tr -d ' ')"
fi
