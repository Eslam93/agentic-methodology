#!/usr/bin/env bash
# Runs the real installer against a fake kit and a real target, one case per state in the update
# table. This is how the updater proves it is a file-state machine and not decoration: every case
# builds files, runs install.sh, and reads the files and the manifest afterwards.
#
#   bash .claude/tools/install.test.sh
#
# The kit is faked so a release can be changed between runs. Nothing here greps the installer's
# source: a test that reads the script instead of running it passes over a broken script.

unset MSYS_NO_PATHCONV
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T="$(mktemp -d 2>/dev/null || mktemp -d -t insttest)"
trap 'rm -rf "$T"' EXIT
fails=0; total=0
K="$T/kit"; P="$T/proj"; MAN=".claude/install-manifest.txt"

ok_()   { total=$((total+1)); printf '  ok    %s\n' "$1"; }
bad_()  { total=$((total+1)); fails=$((fails+1)); printf '  FAIL  %s\n        %s\n' "$1" "$2"; }
is()    { if [ "$2" = "$3" ]; then ok_ "$1"; else bad_ "$1" "expected [$3] got [$2]"; fi; }
has()   { if grep -qF -e "$3" "$2"; then ok_ "$1"; else bad_ "$1" "no match for [$3] in $2"; fi; }
hasnt() { if grep -qF -e "$3" "$2"; then bad_ "$1" "unexpected [$3] in $2"; else ok_ "$1"; fi; }

sha() { if command -v sha256sum >/dev/null 2>&1; then sha256sum < "$1" | cut -d' ' -f1
        else shasum -a 256 < "$1" | cut -d' ' -f1; fi; }
man_hash() { grep -E "^managed [0-9a-f]+ $1\$" "$P/$MAN" 2>/dev/null | awk '{print $2}'; }

new_kit() {   # a minimal kit the installer will accept
  rm -rf "$K"; mkdir -p "$K/.claude/rules" "$K/.claude/hooks" "$K/.claude/skills/work" "$K/.claude/tools" "$K/working"
  printf 'rule v1\n'  > "$K/.claude/rules/standing-orders.md"
  printf 'hook v1\n'  > "$K/.claude/hooks/guard.sh"
  printf 'skill v1\n' > "$K/.claude/skills/work/SKILL.md"
  printf '# working\n' > "$K/working/README.md"
  cp "$HERE/install.sh" "$K/.claude/tools/install.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$K/.claude/tools/verify.sh"   # the real one needs a real kit
}
new_proj() { rm -rf "$P"; mkdir -p "$P"; git -C "$P" init -q 2>/dev/null; }
install_() { bash "$K/.claude/tools/install.sh" "$P" "$@" > "$T/out" 2>&1; echo $?; }

echo "case 1 - initial install"
new_kit; new_proj
rc=$(install_)
is "install exits 0"                        "$rc" 0
is "a managed rule was copied"              "$(cat "$P/.claude/rules/standing-orders.md" 2>/dev/null)" "rule v1"
is "the manifest exists"                    "$([ -f "$P/$MAN" ] && echo yes)" "yes"
is "the recorded hash is the file's hash"   "$(man_hash '.claude/rules/standing-orders.md')" "$(sha "$K/.claude/rules/standing-orders.md")"
has "a version is recorded"                 "$P/$MAN" "version "
is "every managed file is recorded"         "$(grep -c '^managed ' "$P/$MAN")" 5
hasnt "the manifest is not project content" "$P/$MAN" "do not edit by hand, honestly"

echo "case 2 - untouched file, changed upstream"
printf 'rule v2\n' > "$K/.claude/rules/standing-orders.md"
rc=$(install_ --update)
is "update exits 0"                         "$rc" 0
is "the untouched file took the new version" "$(cat "$P/.claude/rules/standing-orders.md")" "rule v2"
is "the manifest moved to the new hash"     "$(man_hash '.claude/rules/standing-orders.md')" "$(sha "$K/.claude/rules/standing-orders.md")"
has "it is reported as updated"             "$T/out" "Updated:"

echo "case 3 - locally modified, changed upstream"
printf 'rule MINE\n' > "$P/.claude/rules/standing-orders.md"
mine=$(sha "$P/.claude/rules/standing-orders.md")
printf 'rule v3\n' > "$K/.claude/rules/standing-orders.md"
rc=$(install_ --update)
is "update still exits 0 with a skip"       "$rc" 0
is "the local version is untouched"         "$(cat "$P/.claude/rules/standing-orders.md")" "rule MINE"
has "it is reported as locally modified"    "$T/out" "Locally modified, preserved:"
is "the manifest keeps the upstream basis, not the local hash" \
   "$([ "$(man_hash '.claude/rules/standing-orders.md')" = "$mine" ] && echo local || echo upstream)" "upstream"

echo "case 4 - locally modified, upstream unchanged"
before=$(man_hash '.claude/rules/standing-orders.md')
rc=$(install_ --update)
is "no destructive action"                  "$(cat "$P/.claude/rules/standing-orders.md")" "rule MINE"
is "the recorded basis does not drift"      "$(man_hash '.claude/rules/standing-orders.md')" "$before"

echo "case 5 - a new upstream file"
printf 'brand new\n' > "$K/.claude/tools/newtool.sh"
rc=$(install_ --update)
is "the new file was installed"             "$(cat "$P/.claude/tools/newtool.sh" 2>/dev/null)" "brand new"
is "it entered the manifest"                "$(man_hash '.claude/tools/newtool.sh')" "$(sha "$K/.claude/tools/newtool.sh")"
has "it is reported as added"               "$T/out" "Added:"

echo "case 6 - a new upstream path collides with an adopter's own file"
printf 'collide upstream\n' > "$K/.claude/skills/work/EXTRA.md"
mkdir -p "$P/.claude/skills/work"; printf 'mine already\n' > "$P/.claude/skills/work/EXTRA.md"
rc=$(install_ --update)
is "the adopter's file is untouched"        "$(cat "$P/.claude/skills/work/EXTRA.md")" "mine already"
has "the collision is reported"             "$T/out" "Present but never recorded, left alone:"
is "no upstream hash was claimed for it"    "$(man_hash '.claude/skills/work/EXTRA.md')" ""
has "it is recorded as unmanaged instead"   "$P/$MAN" "unmanaged .claude/skills/work/EXTRA.md"

echo "case 7 - upstream removes a file"
rm "$K/.claude/tools/newtool.sh"
rc=$(install_ --update)
is "the file is left in place, not deleted" "$(cat "$P/.claude/tools/newtool.sh" 2>/dev/null)" "brand new"
has "the removal is reported"               "$T/out" "Upstream removed, left in place:"
is "update still exits 0"                   "$rc" 0
printf 'and I changed it\n' > "$P/.claude/tools/newtool.sh"
rc=$(install_ --update)
is "a locally changed removed-upstream file survives" "$(cat "$P/.claude/tools/newtool.sh")" "and I changed it"

echo "case 8 - idempotence"
cp "$P/$MAN" "$T/man.before"
rc=$(install_ --update)
is "the second run exits 0"                 "$rc" 0
is "no file was updated"                    "$(grep -c '^Updated:' "$T/out")" 0
is "no file was added"                      "$(grep -c '^Added:' "$T/out")" 0
if diff -q <(grep -v '^installed ' "$T/man.before") <(grep -v '^installed ' "$P/$MAN") >/dev/null; then
  ok_ "the manifest is byte-stable across runs"
else bad_ "the manifest is byte-stable across runs" "$(diff <(grep -v '^installed ' "$T/man.before") <(grep -v '^installed ' "$P/$MAN") | head -4)"; fi

echo "case 9 - an installation that predates the manifest"
new_kit; new_proj
install_ >/dev/null
rm -f "$P/$MAN"
printf 'rule CUSTOM\n' > "$P/.claude/rules/standing-orders.md"     # customized, basis unknown
printf 'rule v2\n'     > "$K/.claude/rules/standing-orders.md"     # and upstream moved
rc=$(install_ --update)
is "it says the installation predates the manifest" "$(grep -c 'predates it' "$T/out")" 1
is "the differing file was NOT overwritten"  "$(cat "$P/.claude/rules/standing-orders.md")" "rule CUSTOM"
has "it is reported for review"              "$T/out" "Present but never recorded, left alone:"
is "no upstream hash was invented for it"    "$(man_hash '.claude/rules/standing-orders.md')" ""
is "a file identical to this release is adopted" "$(man_hash '.claude/hooks/guard.sh')" "$(sha "$K/.claude/hooks/guard.sh")"

echo "case 10 - the manifest is behavioural, not decorative"
new_kit; new_proj; install_ >/dev/null
printf 'tampered\n' > "$P/.claude/hooks/guard.sh"
printf 'hook v9\n'  > "$K/.claude/hooks/guard.sh"
rc=$(install_ --update)
is "a file edited after install is recognised" "$(cat "$P/.claude/hooks/guard.sh")" "tampered"
has "and reported rather than replaced"        "$T/out" "Locally modified, preserved:"

echo "check mode"
new_kit; new_proj; install_ >/dev/null
printf 'rule v2\n' > "$K/.claude/rules/standing-orders.md"
cp "$P/$MAN" "$T/man.check"
rc=$(install_ --update --check)
is "check exits 0"                           "$rc" 0
is "check changed no file"                   "$(cat "$P/.claude/rules/standing-orders.md")" "rule v1"
if diff -q "$T/man.check" "$P/$MAN" >/dev/null; then ok_ "check wrote no manifest"; else bad_ "check wrote no manifest" "the manifest changed"; fi
has "check still says what it would do"      "$T/out" "Updated:"
has "check says it wrote nothing"            "$T/out" "check only, nothing was written"

echo "safety - a file the adopter created is never managed"
new_kit; new_proj; install_ >/dev/null
mkdir -p "$P/.claude/skills/company-thing"; printf 'ours\n' > "$P/.claude/skills/company-thing/SKILL.md"
printf 'rule v2\n' > "$K/.claude/rules/standing-orders.md"
install_ --update >/dev/null
is "an adopter-created skill is untouched"   "$(cat "$P/.claude/skills/company-thing/SKILL.md")" "ours"
hasnt "and never appears in the manifest"    "$P/$MAN" "company-thing"

echo "safety - a managed file deleted by the adopter is not restored"
rm "$P/.claude/hooks/guard.sh"
rc=$(install_ --update)
is "it stays deleted"                        "$([ -e "$P/.claude/hooks/guard.sh" ] && echo present || echo gone)" "gone"
has "and the deletion is reported"           "$T/out" "Deleted here, not restored:"

echo
if [ "$fails" -eq 0 ]; then echo "  $total checks, 0 failed"; else echo "  $total checks, $fails FAILED"; fi
[ "$fails" -eq 0 ]
