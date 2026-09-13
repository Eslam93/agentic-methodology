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
  [ "$have_ps" = 1 ] && cp "$HERE/install.ps1" "$K/.claude/tools/install.ps1"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$K/.claude/tools/verify.sh"   # the real one needs a real kit
}
new_proj() { rm -rf "$P"; mkdir -p "$P"; git -C "$P" init -q 2>/dev/null; }
install_() { bash "$K/.claude/tools/install.sh" "$P" "$@" > "$T/out" 2>&1; echo $?; }

have_ps=0; command -v powershell >/dev/null 2>&1 && have_ps=1
winpath() { if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi; }
install_ps() { powershell -NoProfile -ExecutionPolicy Bypass -File "$(winpath "$K/.claude/tools/install.ps1")" \
                 -Target "$(winpath "$P")" "$@" > "$T/out" 2>&1; echo $?; }

echo "case 1 - initial install"
new_kit; new_proj
rc=$(install_)
is "install exits 0"                        "$rc" 0
is "a managed rule was copied"              "$(cat "$P/.claude/rules/standing-orders.md" 2>/dev/null)" "rule v1"
is "the manifest exists"                    "$([ -f "$P/$MAN" ] && echo yes)" "yes"
is "the recorded hash is the file's hash"   "$(man_hash '.claude/rules/standing-orders.md')" "$(sha "$K/.claude/rules/standing-orders.md")"
has "a version is recorded"                 "$P/$MAN" "version "
is "every managed file is recorded"         "$(grep -c '^managed ' "$P/$MAN")"    "$(find "$K/.claude/rules" "$K/.claude/skills" "$K/.claude/hooks" "$K/.claude/tools" -type f | wc -l | tr -d ' ')"

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

echo "check mode on its own is still a preview, not an install"
new_kit; new_proj
rc=$(install_ --check)
is "--check alone exits 0"                    "$rc" 0
is "--check alone wrote no file"              "$(find "$P" -path "$P/.git" -prune -o -type f -print | wc -l | tr -d ' ')" 0
has "and says nothing was written"            "$T/out" "check only, nothing was written"
has "and says what it would have copied"      "$T/out" "Added:"

echo "a file that diverged and was put back rejoins the managed set"
new_kit; new_proj; install_ >/dev/null
printf 'rule MINE\n' > "$P/.claude/rules/standing-orders.md"
printf 'rule v2\n' > "$K/.claude/rules/standing-orders.md"
install_ --update >/dev/null
is "while it differs it stays preserved"      "$(cat "$P/.claude/rules/standing-orders.md")" "rule MINE"
printf 'rule v2\n' > "$P/.claude/rules/standing-orders.md"   # the owner reconciled it by hand
rc=$(install_ --update)
is "once reconciled it is managed again"      "$(man_hash '.claude/rules/standing-orders.md')" "$(sha "$K/.claude/rules/standing-orders.md")"
hasnt "and is no longer reported as modified" "$T/out" "Locally modified, preserved:"
printf 'rule v3\n' > "$K/.claude/rules/standing-orders.md"
install_ --update >/dev/null
is "and a later release updates it normally"  "$(cat "$P/.claude/rules/standing-orders.md")" "rule v3"

echo "a half install reports failure instead of success"
new_kit; new_proj
printf 'not a directory\n' > "$P/.claude"      # blocks every copy under .claude/
rc=$(install_)
is "a plain install that could not write exits 1" "$rc" 1
has "and says which files it could not write"     "$T/out" "could NOT be written"

echo "safety - the manifest never claims a write that did not happen"
new_kit; new_proj
mkdir -p "$P/.claude/rules/standing-orders.md"     # a directory exactly where a managed file goes
rc=$(install_)
is "the directory is still a directory"       "$([ -d "$P/.claude/rules/standing-orders.md" ] && echo yes)" "yes"
is "the manifest does not claim that file"    "$(man_hash '.claude/rules/standing-orders.md')" ""
has "and the failure is reported"             "$T/out" "could NOT be written"

echo "safety - a plain install never replaces, even a file it owns and you have not touched"
new_kit; new_proj; install_ >/dev/null
printf 'rule v2\n' > "$K/.claude/rules/standing-orders.md"
rc=$(install_)
is "a plain re-install exits 0"               "$rc" 0
is "an untouched managed file is NOT replaced" "$(cat "$P/.claude/rules/standing-orders.md")" "rule v1"
is "the manifest still records what is on disk" "$(man_hash '.claude/rules/standing-orders.md')" "$(printf 'rule v1\n' > "$T/v1" && sha "$T/v1")"
has "and it says --update would take it"      "$T/out" "run it again with --update"
rc=$(install_ --update)
is "and --update then takes it"               "$(cat "$P/.claude/rules/standing-orders.md")" "rule v2"

echo "the installer cannot call a red harness installed"
new_kit; new_proj
# a verify.sh that fails: files are copied, but the harness is not known to work
printf '#!/usr/bin/env bash\necho "  FAIL  something is wrong"\nexit 1\n' > "$K/.claude/tools/verify.sh"
rc=$(install_)
is "an install whose verification is red exits 1" "$rc" 1
has "and says the files are copied, not verified" "$T/out" "FILES COPIED, NOT YET VERIFIED"
hasnt "and never claims it is installed"          "$T/out" "INSTALLED AND VERIFIED"
printf '#!/usr/bin/env bash\nexit 0\n' > "$K/.claude/tools/verify.sh"
new_proj; rc=$(install_)
is "a green install exits 0"                      "$rc" 0
has "and says so plainly"                         "$T/out" "INSTALLED AND VERIFIED"
# and the same contract on update
printf 'rule v2\n' > "$K/.claude/rules/standing-orders.md"
printf '#!/usr/bin/env bash\nexit 1\n' > "$K/.claude/tools/verify.sh"
rc=$(install_ --update)
is "an update whose verification is red exits 1"  "$rc" 1
has "and says the files are updated, not verified" "$T/out" "FILES UPDATED, NOT YET VERIFIED"
printf '#!/usr/bin/env bash\nexit 0\n' > "$K/.claude/tools/verify.sh"
printf 'rule v3\n' > "$K/.claude/rules/standing-orders.md"
rc=$(install_ --update)
is "a green update exits 0"                       "$rc" 0
has "and says so plainly"                         "$T/out" "UPDATED AND VERIFIED"
rc=$(install_ --update --check)
is "check still writes nothing and exits 0"       "$rc" 0
hasnt "and does not claim to have verified"       "$T/out" "UPDATED AND VERIFIED"

echo "an unmanaged path stays unmanaged across releases"
new_kit; new_proj; install_ >/dev/null
printf 'collide upstream v1\n' > "$K/.claude/tools/collide.sh"
printf 'MINE, and I had this path first\n' > "$P/.claude/tools/collide.sh"
install_ --update >/dev/null
is "release 1: the collision is preserved"    "$(cat "$P/.claude/tools/collide.sh")" "MINE, and I had this path first"
has "and recorded unmanaged"                  "$P/$MAN" "unmanaged .claude/tools/collide.sh"
# release 2: upstream drifts into byte-for-byte agreement with the adopter's file
printf 'MINE, and I had this path first\n' > "$K/.claude/tools/collide.sh"
rc=$(install_ --update)
is "release 2: matching bytes do not claim it" "$(man_hash '.claude/tools/collide.sh')" ""
has "it is still recorded unmanaged"           "$P/$MAN" "unmanaged .claude/tools/collide.sh"
# release 3: upstream moves again. The adopter's file must still be theirs.
printf 'upstream v3, quite different\n' > "$K/.claude/tools/collide.sh"
rc=$(install_ --update)
is "release 3: the adopter file is still preserved" "$(cat "$P/.claude/tools/collide.sh")" "MINE, and I had this path first"
is "and still never claimed"                   "$(man_hash '.claude/tools/collide.sh')" ""
# and the managed-then-reconciled case must still rejoin, which is a different thing
printf 'rule v2\n' > "$K/.claude/rules/standing-orders.md"
install_ --update >/dev/null
printf 'rule MINE\n' > "$P/.claude/rules/standing-orders.md"
install_ --update >/dev/null
printf 'rule v2\n' > "$P/.claude/rules/standing-orders.md"
install_ --update >/dev/null
is "a managed file reconciled by hand still rejoins" "$(man_hash '.claude/rules/standing-orders.md')" "$(sha "$K/.claude/rules/standing-orders.md")"

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

# The same states again, driven through the PowerShell installer. The two must classify identically
# and write the same manifest: an adopter on Windows without Git Bash gets install.ps1 and nothing
# else, so a divergence here is a divergence in the product, not in a test.
if [ "$have_ps" = 1 ]; then
  echo "powershell - the same states through install.ps1"
  new_kit; new_proj
  rc=$(install_ps)
  is "ps: initial install exits 0"             "$rc" 0
  is "ps: a managed file landed"               "$(cat "$P/.claude/rules/standing-orders.md" 2>/dev/null)" "rule v1"
  is "ps: its hash is recorded"                "$(man_hash '.claude/rules/standing-orders.md')" "$(sha "$K/.claude/rules/standing-orders.md")"
  printf 'rule v2\n' > "$K/.claude/rules/standing-orders.md"
  rc=$(install_ps)
  is "ps: a plain re-install does not replace"  "$(cat "$P/.claude/rules/standing-orders.md")" "rule v1"
  rc=$(install_ps -Update)
  is "ps: update exits 0"                      "$rc" 0
  is "ps: an untouched file was replaced"      "$(cat "$P/.claude/rules/standing-orders.md")" "rule v2"
  is "ps: the manifest moved"                  "$(man_hash '.claude/rules/standing-orders.md')" "$(sha "$K/.claude/rules/standing-orders.md")"
  printf 'rule MINE\n' > "$P/.claude/rules/standing-orders.md"; psmine=$(sha "$P/.claude/rules/standing-orders.md")
  printf 'rule v3\n' > "$K/.claude/rules/standing-orders.md"
  rc=$(install_ps -Update)
  is "ps: update with a local change exits 0"  "$rc" 0
  is "ps: the local change survives"           "$(cat "$P/.claude/rules/standing-orders.md")" "rule MINE"
  has "ps: and is reported"                    "$T/out" "Locally modified, preserved:"
  is "ps: the manifest keeps the upstream basis" "$([ "$(man_hash '.claude/rules/standing-orders.md')" = "$psmine" ] && echo local || echo upstream)" "upstream"
  printf 'new tool\n' > "$K/.claude/tools/nt.sh"
  rc=$(install_ps -Update)
  is "ps: a new upstream file is added"        "$(cat "$P/.claude/tools/nt.sh" 2>/dev/null)" "new tool"
  printf 'ours\n' > "$P/.claude/skills/work/EXTRA.md"; printf 'theirs\n' > "$K/.claude/skills/work/EXTRA.md"
  rc=$(install_ps -Update)
  is "ps: a colliding path is preserved"       "$(cat "$P/.claude/skills/work/EXTRA.md")" "ours"
  has "ps: and recorded unmanaged"             "$P/$MAN" "unmanaged .claude/skills/work/EXTRA.md"
  rm "$K/.claude/tools/nt.sh"
  rc=$(install_ps -Update)
  is "ps: an upstream removal deletes nothing" "$(cat "$P/.claude/tools/nt.sh")" "new tool"
  cp "$P/$MAN" "$T/psman"
  rc=$(install_ps -Update)
  if diff -q <(grep -v '^installed ' "$T/psman") <(grep -v '^installed ' "$P/$MAN") >/dev/null; then
    ok_ "ps: idempotent, the manifest is byte-stable"
  else bad_ "ps: idempotent, the manifest is byte-stable" "it drifted"; fi
  printf 'rule v9\n' > "$K/.claude/rules/standing-orders.md"; cp "$P/$MAN" "$T/psman2"
  rc=$(install_ps -Update -Check)
  is "ps: -Check exits 0"                      "$rc" 0
  is "ps: -Check changed no file"              "$(cat "$P/.claude/rules/standing-orders.md")" "rule MINE"
  if diff -q "$T/psman2" "$P/$MAN" >/dev/null; then ok_ "ps: -Check wrote no manifest"
  else bad_ "ps: -Check wrote no manifest" "the manifest changed"; fi

  echo "powershell - the two installers agree byte for byte"
  new_kit; new_proj; install_ >/dev/null; cp "$P/$MAN" "$T/from-bash"
  new_proj; install_ps >/dev/null
  if diff -q <(grep '^managed ' "$T/from-bash") <(grep '^managed ' "$P/$MAN") >/dev/null; then
    ok_ "ps: the same managed lines and hashes as bash"
  else bad_ "ps: the same managed lines and hashes as bash" \
      "$(diff <(grep '^managed ' "$T/from-bash") <(grep '^managed ' "$P/$MAN") | head -4)"; fi

  # C:\Windows\System32\bash.exe is the WSL launcher, and wherever WSL is installed it comes before
  # Git on PATH. It runs Linux and cannot read a Windows path, so an installer that takes the first
  # bash it finds reports every healthy install as red. The suite itself runs with Git Bash leading
  # PATH, which is why the plain cases above never saw it. The stand-in answers like WSL did on
  # 2026-09-13: `-c 'uname -s'` prints Linux and succeeds, and running a D:\ script path fails.
  wsl_like() {
    mkdir -p "$1"
    printf '@if "%%~1"=="-c" (echo Linux& exit /b 0)\r\n@echo /bin/bash: %%1: No such file or directory\r\n@exit /b 127\r\n' > "$1/bash.cmd"
  }
  echo "powershell - verification runs through Git Bash when a WSL-like bash leads PATH"
  wsl_like "$T/fakebin"
  new_kit; new_proj
  printf '#!/usr/bin/env bash\necho "verify ran under $(uname -s)"\nexit 0\n' > "$K/.claude/tools/verify.sh"
  rc=$(PATH="$T/fakebin:$PATH" install_ps)
  is "ps: a non-Git bash first on PATH does not fail the install" "$rc" 0
  has "ps: verify.sh really ran, under Git Bash"                  "$T/out" "verify ran under M"
  has "ps: and the install says so"                               "$T/out" "INSTALLED AND VERIFIED"

  # With no Git anywhere, the only bash left is the impostor. It must be refused by its uname answer,
  # not merely outranked by Git's own folder, which is what the case above exercises.
  echo "powershell - a WSL-like bash is refused when no Git Bash exists"
  new_kit; new_proj
  ps1="$(winpath "$K/.claude/tools/install.ps1")"; tgt="$(winpath "$P")"; nogit="$(winpath "$T/nogit")"
  mkdir -p "$T/nogit"
  env PATH="$T/fakebin:/c/windows/system32:/c/windows:/c/windows/System32/WindowsPowerShell/v1.0" \
      ProgramFiles="$nogit" ProgramW6432="$nogit" "ProgramFiles(x86)=$nogit" LOCALAPPDATA="$nogit" \
      powershell -NoProfile -ExecutionPolicy Bypass -File "$ps1" -Target "$tgt" > "$T/out" 2>&1; rc=$?
  is    "ps: exits non-zero"                          "$rc" 1
  has   "ps: says Git Bash was not found"             "$T/out" "Git Bash was not found"
  hasnt "ps: never ran verify through the impostor"   "$T/out" "verification is red"
else
  echo "powershell not on PATH; the install.ps1 cases did not run"
fi

echo
if [ "$fails" -eq 0 ]; then echo "  $total checks, 0 failed"; else echo "  $total checks, $fails FAILED"; fi
[ "$fails" -eq 0 ]
