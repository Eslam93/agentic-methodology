<#
    Install or update the kit in a repository (shape A) or a workspace above several clones (shape B).

        powershell -File <kit>\.claude\tools\install.ps1 -Target <dir> [-Shape A|B] [-Repos <dir>]
        powershell -File <kit>\.claude\tools\install.ps1 -Target <dir> -Update
        powershell -File <kit>\.claude\tools\install.ps1 -Target <dir> -Update -Check

    Same behaviour as install.sh: copies .claude/ without overwriting, writes settings.json with
    PowerShell hook commands (or settings.kit.json beside an existing one), creates working/, the
    knowledge-base skeleton, the ignore and attribute lines, then runs verify.sh through Git Bash
    if it can find one (Git for Windows provides it; the WSL bash.exe is never used).

    THE UPDATE MODEL, identical to install.sh and sharing its manifest format. The kit is copied
    into the adopter's repository on purpose, so the rules and hooks that govern a project are
    readable in it, reviewed in its pull requests, pinned with its history, and changeable locally.
    .claude/install-manifest.txt records the sha256 of each managed file as delivered, and an update
    replaces only files whose current hash still matches that record. Anything the adopter changed
    is preserved and reported. Nothing is merged, no conflict markers, no backups, no LLM.
    Modification is decided by content, never by a timestamp, and absence of manifest data is never
    permission to overwrite.
#>
param(
    [Parameter(Mandatory = $true)][string]$Target,
    [ValidateSet('A', 'B')][string]$Shape = 'A',
    [string]$Repos = '',
    [switch]$Update,
    [switch]$Check
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$kit = (Resolve-Path (Join-Path $here '..\..')).Path
if (-not (Test-Path (Join-Path $kit '.claude\rules'))) { throw "kit not found at $kit" }
if (-not (Test-Path $Target)) { throw "target does not exist: $Target" }
$Target = (Resolve-Path $Target).Path

# --- managed files, the manifest, and the one classification table ---------------------------
# Managed means "shipped by this kit", and the list comes from the kit, never from scanning the
# target: an adopter's own skill, hook, rule, or tool must never be taken for upstream content.
$ManifestRel = '.claude/install-manifest.txt'
$ManifestPath = Join-Path $Target '.claude\install-manifest.txt'
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

function Get-ManagedFiles {
    $out = @()
    foreach ($sub in 'rules', 'skills', 'hooks', 'tools') {
        $src = Join-Path $kit ".claude\$sub"
        if (-not (Test-Path $src)) { continue }
        Get-ChildItem -Path $src -Recurse -File | ForEach-Object {
            $out += ($_.FullName.Substring($kit.Length).TrimStart('\') -replace '\\', '/')
        }
    }
    $arr = [string[]]$out
    [Array]::Sort($arr, [System.StringComparer]::Ordinal)
    return $arr
}
# The bytes on disk, not the text: nothing here reads a file as text and writes it back, so the
# same file always hashes the same way and a newline never moves under the installer.
function Get-FileSha256([string]$Path) {
    if (-not (Test-Path $Path -PathType Leaf)) { return $null }
    return (Get-FileHash -Path $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}
function Get-KitVersion {
    $git = (Get-Command git -ErrorAction SilentlyContinue).Source
    if ($git) {
        $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
        try {
            $v = & $git -C $kit describe --tags --always 2>$null
            if ($LASTEXITCODE -eq 0 -and $v) { return (@($v) -join '').Trim() }
        } catch { } finally { $ErrorActionPreference = $prev }
    }
    return 'unknown'
}

$oldHash = @{}; $wasUnmanaged = @{}
if (Test-Path $ManifestPath) {
    foreach ($line in (Get-Content $ManifestPath)) {
        if ($line -cmatch '^managed ([0-9a-f]+) (.+)$')  { $oldHash[$Matches[2]] = $Matches[1] }
        elseif ($line -cmatch '^unmanaged (.+)$')        { $wasUnmanaged[$Matches[1]] = $true }
    }
}

$rAdded=@(); $rUpdated=@(); $rUnchanged=@(); $rModified=@(); $rUnverified=@()
$rRemovedLocal=@(); $rUpstreamGone=@(); $rFailed=@(); $rOutdated=@(); $copied = 0
$manifestBody = @()

# Write, then prove the bytes landed. A destination that is a directory, a full disk, or a
# read-only file must never end with the manifest recording a version that is not there.
function Install-ManagedFile([string]$Src, [string]$Dest, [string]$Want) {
    if (Test-Path $Dest -PathType Container) { return $false }
    try {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Dest) | Out-Null
        Copy-Item $Src $Dest -Force
    } catch { return $false }
    return ((Get-FileSha256 $Dest) -eq $Want)
}

# $Apply is false for -Check, which writes nothing. $Replace is true only for -Update: a plain
# install never replaces an existing file, which is the promise in this script's header.
function Sync-Managed([bool]$Apply, [bool]$Replace) {
    $newFiles = Get-ManagedFiles
    $newSet = @{}; foreach ($f in $newFiles) { $newSet[$f] = $true }
    foreach ($rel in $newFiles) {
        $srcPath  = Join-Path $kit ($rel -replace '/', '\')
        $destPath = Join-Path $Target ($rel -replace '/', '\')
        $up = Get-FileSha256 $srcPath
        if (-not $up) { $script:rFailed += $rel; continue }
        $old = if ($oldHash.ContainsKey($rel)) { $oldHash[$rel] } else { $null }
        $loc = Get-FileSha256 $destPath

        if (-not $old) {
            if ($wasUnmanaged.ContainsKey($rel) -and $loc) {
                # Recorded once as the adopter's own. A later release whose bytes happen to match
                # does not make the path ours: only their removing the file changes that.
                $script:rUnverified += $rel; $script:manifestBody += "unmanaged $rel"
            } elseif (-not $loc) {
                if ($Apply) {
                    if (-not (Install-ManagedFile $srcPath $destPath $up)) { $script:rFailed += $rel; continue }
                    $script:copied++
                }
                $script:rAdded += $rel; $script:manifestBody += "managed $up $rel"
            } elseif ($loc -eq $up) {
                # byte-identical to what this release ships, so adopting it loses nothing
                $script:rUnchanged += $rel; $script:manifestBody += "managed $up $rel"
            } else {
                # A path that exists and was never recorded: an adopter's own file, or an older
                # upstream version from an install predating the manifest. Those cannot be told
                # apart, so it is never overwritten and never recorded as an upstream basis.
                $script:rUnverified += $rel; $script:manifestBody += "unmanaged $rel"
            }
            continue
        }

        if (-not $loc) {
            # deleted here on purpose; restoring it would put back a control the adopter removed
            $script:rRemovedLocal += $rel; $script:manifestBody += "managed $old $rel"
        } elseif ($loc -eq $old) {
            if ($up -eq $old) {
                $script:rUnchanged += $rel; $script:manifestBody += "managed $up $rel"
            } elseif (-not $Replace) {
                # still ours and still untouched, but replacing it is what -Update is for. Record
                # what is actually on disk, which is the old version.
                $script:rOutdated += $rel; $script:manifestBody += "managed $old $rel"
            } else {
                if ($Apply) {
                    if (-not (Install-ManagedFile $srcPath $destPath $up)) {
                        $script:rFailed += $rel; $script:manifestBody += "managed $old $rel"; continue
                    }
                    $script:copied++
                }
                $script:rUpdated += $rel; $script:manifestBody += "managed $up $rel"
            }
        } elseif ($loc -eq $up) {
            # diverged once and now byte-identical to this release: it has converged, so it rejoins
            # the managed set rather than being reported as modified for the rest of its life.
            $script:rUnchanged += $rel; $script:manifestBody += "managed $up $rel"
        } else {
            # changed since install. Keep the LAST UPSTREAM hash, never the local one: the manifest
            # records what to compare against, not whatever happens to be there.
            $script:rModified += $rel; $script:manifestBody += "managed $old $rel"
        }
    }
    # managed once, gone from this release: reported, never deleted
    # Sorted, because a hashtable's key order is not defined and the report should read the same
    # way twice for the same tree.
    foreach ($rel in ($oldHash.Keys | Sort-Object)) {
        if ($newSet.ContainsKey($rel)) { continue }
        $script:rUpstreamGone += $rel
        $script:manifestBody += ("managed " + $oldHash[$rel] + " " + $rel)
    }
    foreach ($rel in ($wasUnmanaged.Keys | Sort-Object)) {
        if ($newSet.ContainsKey($rel)) { continue }
        $script:manifestBody += "unmanaged $rel"
    }
}

function Write-Manifest {
    $head = @(
        '# methodology installation manifest. Written by install.ps1.',
        '# Installer metadata, not project content: it records the upstream version of each managed',
        '# file so a later update can tell a file you have not touched from one you changed. An',
        '# update replaces only the first kind. Do not edit by hand; delete it only to start over,',
        '# which makes every managed file unverifiable again.',
        ("version " + (Get-KitVersion)),
        ("installed " + (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))
    )
    $body = [string[]]$manifestBody
    [Array]::Sort($body, [System.StringComparer]::Ordinal)
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ManifestPath) | Out-Null
    $text = (($head + $body) -join "`n") + "`n"
    [IO.File]::WriteAllText("$ManifestPath.tmp", $text, $utf8NoBom)
    Move-Item "$ManifestPath.tmp" $ManifestPath -Force
}

function Report([string]$Label, $List) {
    if (-not $List -or $List.Count -eq 0) { return }
    Write-Output $Label
    foreach ($f in $List) { Write-Output "  $f" }
}

if ($Update -or $Check) {
    # -Check comes down this path with or without -Update, because the one thing it must never do
    # is write. Read on its own it used to fall through to a full install, which is the opposite of
    # a preview and the easiest typo to make.
    if ($Update -and -not (Test-Path (Join-Path $Target '.claude'))) { throw "no .claude\ in $Target; run the installer without -Update first" }
    if ($Update -and -not (Test-Path $ManifestPath)) {
        Write-Output "no $ManifestRel here: this installation predates it. Files identical to this release are adopted; anything that differs is left alone and listed, because nothing records what it started as."
    }
    Sync-Managed (-not $Check) ([bool]$Update)
    if ($Check) {
        Write-Output "check only, nothing was written. Version on offer: $(Get-KitVersion)"
        if (-not $Update) { Write-Output 'This is what a first install would copy; add -Update to preview an update instead.' }
    }
    else { Write-Manifest }
    Write-Output ''
    Report 'Updated:'                                 $rUpdated
    Report 'Added:'                                   $rAdded
    Report 'Locally modified, preserved:'             $rModified
    Report 'Present but never recorded, left alone:'  $rUnverified
    Report 'Deleted here, not restored:'              $rRemovedLocal
    Report 'Upstream removed, left in place:'         $rUpstreamGone
    Report 'Older than this release, not replaced:'   $rOutdated
    Report 'FAILED:'                                  $rFailed
    Write-Output ''
    if ($rFailed.Count -gt 0) {
        Write-Output 'the update did not complete: the files under FAILED were not written, and the manifest still records their previous version'
        exit 1
    }
    $nMod = $rModified.Count + $rUnverified.Count
    if ($Check) {
        Write-Output "nothing was written. $nMod file(s) would be preserved for you to reconcile."
    } else {
        Write-Output "update complete. $nMod file(s) were preserved for you to reconcile; nothing was merged or overwritten."
        Write-Output 'Rules and hooks load at session start, so start a new session after this update.'
    }
    exit 0
}

Sync-Managed $true $false
$kept = @($rUnchanged + $rUnverified + $rOutdated)

function Hook([string]$name) { return "powershell -NoProfile -ExecutionPolicy Bypass -File \`"`${CLAUDE_PROJECT_DIR}/.claude/hooks/$name.ps1\`"" }
$settings = @"
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Edit|Write", "hooks": [ { "type": "command", "command": "$(Hook 'guard-secrets')", "timeout": 15 } ] },
      { "matcher": "Bash|PowerShell", "hooks": [ { "type": "command", "command": "$(Hook 'guard-commands')", "timeout": 10 } ] }
    ],
    "Stop": [
      { "hooks": [ { "type": "command", "command": "$(Hook 'verify-on-finish')", "timeout": 30, "statusMessage": "Checking no test was weakened" } ] }
    ],
    "SessionStart": [
      { "matcher": "compact", "hooks": [ { "type": "command", "command": "$(Hook 'resume-brief')", "timeout": 10 } ] }
    ]
  }
}
"@
$utf8 = New-Object System.Text.UTF8Encoding $false
$settingsPath = Join-Path $Target '.claude\settings.json'
if (Test-Path $settingsPath) {
    [IO.File]::WriteAllText((Join-Path $Target '.claude\settings.kit.json'), $settings.Replace("`r`n", "`n").TrimEnd("`n") + "`n", $utf8)
    Write-Output "settings.json already exists; the kit's hooks are in .claude\settings.kit.json. Merge the hooks block by hand and delete that file."
} else {
    [IO.File]::WriteAllText($settingsPath, $settings.Replace("`r`n", "`n"), $utf8)
}

New-Item -ItemType Directory -Force -Path (Join-Path $Target 'working') | Out-Null
if (-not (Test-Path (Join-Path $Target 'working\README.md'))) { Copy-Item (Join-Path $kit 'working\README.md') (Join-Path $Target 'working\README.md') }

function Ensure-Lines([string]$file, [string[]]$lines) {
    if (-not (Test-Path $file)) { [IO.File]::WriteAllText($file, '', $utf8) }
    $existing = Get-Content $file -ErrorAction SilentlyContinue
    foreach ($l in $lines) { if ($existing -notcontains $l) { [IO.File]::AppendAllText($file, "$l`n", $utf8) } }
}
Ensure-Lines (Join-Path $Target '.gitignore') @('working/*', '!working/README.md', '.claude/settings.local.json', 'codex-relay.json', '.claude/worktrees/')
Ensure-Lines (Join-Path $Target '.gitattributes') @('* text=auto eol=lf', '*.md text eol=lf', '*.sh text eol=lf', '*.ps1 text eol=lf', '*.json text eol=lf')

if ($Shape -eq 'A') { $kb = Join-Path $Target 'docs\knowledge-base'; $where = 'inside the repository, under docs/knowledge-base/ (shape A)' }
else { $kb = Join-Path $Target 'knowledge-base'; $where = 'at the workspace root, above the clones (shape B)' }
if (-not (Test-Path $kb)) {
    foreach ($d in '00-orientation', '_investigations', '_readings') { New-Item -ItemType Directory -Force -Path (Join-Path $kb $d) | Out-Null }
    $readme = @"
# Knowledge base

**Two warnings, before anything else.**

1. **Nothing here has been raised with the team.** Every finding was recorded from reading and measuring. Treat it as input to a conversation, not a verdict.
2. **Everything here is point-in-time.** Every substantial page carries a header saying when the facts were gathered, how they were verified, and what was not checked.

**The absence of a subject here is not evidence about it.** Silence is a gap, not a clean bill of health.

## Where it lives, and why

This knowledge base is committed $where. Record here the reason this shape was chosen, so the next person does not assume it was an accident.

## The rules for writing here

The path-scoped rule ``.claude/rules/knowledge-base.md`` loads whenever a file here is touched. Never a secret value. Describe the system, not the people. Keep negative results. Never assert a changeable condition in the present tense: write the measurement, dated, with its source.
"@
    $today = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')
    $index = @"
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

# Index

## Start with one of these

| If you are | Read |
|---|---|
| new to the project | ``start-here.md`` (to be written from the first measurements) |
| about to change something | ``../99-pending.md`` |

## Every page, and what it settles

| Page | What it settles |
|---|---|
| ``README.md`` | the two warnings and where this base lives |

## What is empty, and deliberately

Everything not listed above. Each section is added when its first measured page exists.
"@
    $pending = @"
# Pending

Everything found and not acted on. One line each, same turn, grouped by who can act. ``P0`` blocks the current goal · ``P1`` matters soon · ``P2`` worth doing · ``?`` needs a decision. This is the index of what is open, not the evidence.

## 1 · Only the project team can answer these

## 2 · Needs a decision

## 3 · We can do this ourselves

## 4 · Worth doing when someone is in that code anyway
"@
    $decisions = @"
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

# Decisions

One entry per real fork, newest first. Fields: decision · options considered · why · decided by · reversible or not · revisit when · supersedes.
"@
    foreach ($pair in @(@('README.md', $readme), @('00-orientation\index.md', $index), @('99-pending.md', $pending), @('decisions.md', $decisions))) {
        [IO.File]::WriteAllText((Join-Path $kb $pair[0]), $pair[1].Replace("`r`n", "`n").TrimEnd("`n") + "`n", $utf8)
    }
}

if ($Shape -eq 'B') {
    if ($Repos -and (Test-Path $Repos)) {
        [IO.File]::WriteAllText((Join-Path $Target '.workspace'), "WS_REPOS=$((Resolve-Path $Repos).Path -replace '\\', '/')`n", $utf8)
    } elseif (-not (Test-Path (Join-Path $Target '.workspace'))) {
        Write-Output 'shape B: pass -Repos <dir> so .workspace records where the clones are, or write it by hand (WS_REPOS=...).'
    }
}

Write-Manifest
Write-Output "copied $copied files into $Target\.claude\"
if ($kept.Count -gt 0) { Write-Output ("left alone (already existed): " + ($kept -join ' ')) }
Write-Output ("recorded " + ($manifestBody | Where-Object { $_ -like 'managed *' }).Count + " managed files in $ManifestRel (" + (Get-KitVersion) + ")")
if ($rRemovedLocal.Count -gt 0) {
    Write-Output 'these managed files are recorded but not present here; they were not restored:'
    foreach ($f in $rRemovedLocal) { Write-Output "  $f" }
}
if ($rFailed.Count -gt 0) {
    Write-Output 'these managed files could NOT be written, and the manifest does not claim them:'
    foreach ($f in $rFailed) { Write-Output "  $f" }
}
if ($rOutdated.Count -gt 0) {
    Write-Output 'these managed files are older than this release and were NOT replaced, because a plain install never overwrites:'
    foreach ($f in $rOutdated) { Write-Output "  $f" }
    Write-Output 'run it again with -Update to take them.'
}
Write-Output "To take a later release: install.ps1 -Target $Target -Update   (add -Check to preview)"
Write-Output ''
Write-Output "Next: open the assistant at $Target and say: read START-HERE.md and follow it."
Write-Output 'Rules and hooks load at session start, so start a new session after this install.'
Write-Output ''
# The installer's own success is not the same as a usable harness. A copied tree whose hooks are
# not wired, or whose verification is red, is "files are here, now reconcile", not "installed".
#
# Git Bash specifically, never the first bash on PATH. On Windows, System32\bash.exe and the
# WindowsApps alias are the WSL launcher, which comes before Git on PATH wherever WSL is installed.
# It runs Linux, reads D:\x as D:x, and answers "No such file or directory", so a healthy install
# was reported red (measured 2026-09-13). A candidate counts only if `uname -s` says MINGW, MSYS,
# or CYGWIN, which WSL never does: it answers Linux. Elsewhere (pwsh on Linux or macOS) the bash on
# PATH is the native one.
# PSEdition is empty before 5.1 and $IsWindows exists only from 6, so ask the runtime instead.
$onWindows = [Environment]::OSVersion.Platform -eq 'Win32NT'
function Find-GitBash {
    if (-not $onWindows) {
        return (Get-Command bash -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1).Source
    }
    # Every native call here may write to stderr; under 'Stop' that would be terminating.
    $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try {
        # Start from git itself. <Git>\cmd\git.exe and <Git>\mingw64\bin\git.exe sit under the root
        # that holds bin\bash.exe; git --exec-path also reaches it through a Scoop shim.
        $starts = @()
        foreach ($git in @(Get-Command git -CommandType Application -All -ErrorAction SilentlyContinue)) {
            $starts += (Split-Path -Parent $git.Source)
            try {
                $exec = & $git.Source --exec-path 2>$null
                if ($LASTEXITCODE -eq 0 -and $exec) { $starts += ((@($exec) -join '').Trim() -replace '/', '\') }
            } catch { }
        }
        $candidates = New-Object System.Collections.Generic.List[string]
        foreach ($dir in $starts) {
            for ($i = 0; $i -lt 4 -and $dir; $i++) {
                $candidates.Add((Join-Path $dir 'bin\bash.exe'))
                $dir = Split-Path -Parent $dir
            }
        }
        foreach ($root in @($env:ProgramFiles, $env:ProgramW6432, ${env:ProgramFiles(x86)})) {
            if ($root) { $candidates.Add((Join-Path $root 'Git\bin\bash.exe')) }
        }
        if ($env:LOCALAPPDATA) { $candidates.Add((Join-Path $env:LOCALAPPDATA 'Programs\Git\bin\bash.exe')) }
        foreach ($b in @(Get-Command bash -CommandType Application -All -ErrorAction SilentlyContinue)) {
            if ($b.Source -notmatch '\\(System32|WindowsApps)\\') { $candidates.Add($b.Source) }
        }
        foreach ($c in ($candidates | Select-Object -Unique)) {
            if (-not (Test-Path -LiteralPath $c -PathType Leaf)) { continue }
            # One candidate that cannot start must not end the search for the next one.
            try { $u = & $c -c 'uname -s' 2>$null } catch { continue }
            if ($LASTEXITCODE -eq 0 -and ((@($u) -join '') -match '^(MINGW|MSYS|CYGWIN)')) { return $c }
        }
    } finally { $ErrorActionPreference = $prev }
    return $null
}
$bash = Find-GitBash
$vrc = $null
# Forward slashes on Windows: an MSYS bash reads D:/x/y as a path, and a backslash is a shell escape.
$verifyPath = Join-Path $Target '.claude/tools/verify.sh'
if ($onWindows) { $verifyPath = $verifyPath -replace '\\', '/' }
if ($bash) { & $bash $verifyPath; $vrc = $LASTEXITCODE }
Write-Output ''
if ($rFailed.Count -gt 0) {
    Write-Output 'NOT INSTALLED: some managed files could not be written, listed above. The manifest does'
    Write-Output 'not claim them, so running this again retries them.'
    exit 1
}
if ($null -eq $vrc) {
    Write-Output 'FILES COPIED, NOT YET VERIFIED: Git Bash was not found, so verify.sh could not run. A WSL'
    Write-Output 'bash does not count: it runs Linux and cannot read this Windows path. The methodology'
    Write-Output 'tools are Bash scripts, so Git Bash is required to use this harness at all.'
    Write-Output 'Install Git for Windows, then run .claude/tools/verify.sh from Git Bash.'
    exit 1
}
if ($vrc -ne 0) {
    Write-Output 'FILES COPIED, NOT YET VERIFIED: verification is red above. Nothing here merges settings'
    Write-Output 'or edits your files, so the reconciliation is yours: fix what it names, then re-run'
    Write-Output 'verify.sh until it is green. Until then this harness is not known to work.'
    exit 1
}
Write-Output 'INSTALLED AND VERIFIED.'
exit 0
