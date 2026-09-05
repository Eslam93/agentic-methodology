<#
    Install the kit into a repository (shape A) or a workspace above several clones (shape B).

        powershell -File <kit>\.claude\tools\install.ps1 -Target <dir> [-Shape A|B] [-Repos <dir>]

    Same behaviour as install.sh: copies .claude/ without overwriting, writes settings.json with
    PowerShell hook commands (or settings.kit.json beside an existing one), creates working/, the
    knowledge-base skeleton, the ignore and attribute lines, then runs verify.sh through bash if
    bash is available (Git for Windows provides it).
#>
param(
    [Parameter(Mandatory = $true)][string]$Target,
    [ValidateSet('A', 'B')][string]$Shape = 'A',
    [string]$Repos = ''
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$kit = (Resolve-Path (Join-Path $here '..\..')).Path
if (-not (Test-Path (Join-Path $kit '.claude\rules'))) { throw "kit not found at $kit" }
if (-not (Test-Path $Target)) { throw "target does not exist: $Target" }
$Target = (Resolve-Path $Target).Path

$kept = @(); $copied = 0
foreach ($sub in 'rules', 'skills', 'hooks', 'tools') {
    $src = Join-Path $kit ".claude\$sub"
    if (-not (Test-Path $src)) { continue }
    Get-ChildItem -Path $src -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($kit.Length).TrimStart('\')
        $dest = Join-Path $Target $rel
        if (Test-Path $dest) { $script:kept += $rel; return }
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
        Copy-Item $_.FullName $dest
        $script:copied++
    }
}

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
    [IO.File]::WriteAllText((Join-Path $Target '.claude\settings.kit.json'), $settings.Replace("`r`n", "`n"), $utf8)
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
Ensure-Lines (Join-Path $Target '.gitignore') @('working/*', '!working/README.md', '.claude/settings.local.json', 'codex-relay.json')
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
    $index = @"
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
# Decisions

One entry per real fork, newest first. Fields: decision · options considered · why · decided by · reversible or not · revisit when · supersedes.
"@
    foreach ($pair in @(@('README.md', $readme), @('00-orientation\index.md', $index), @('99-pending.md', $pending), @('decisions.md', $decisions))) {
        [IO.File]::WriteAllText((Join-Path $kb $pair[0]), $pair[1].Replace("`r`n", "`n"), $utf8)
    }
}

if ($Shape -eq 'B') {
    if ($Repos -and (Test-Path $Repos)) {
        [IO.File]::WriteAllText((Join-Path $Target '.workspace'), "WS_REPOS=$((Resolve-Path $Repos).Path -replace '\\', '/')`n", $utf8)
    } elseif (-not (Test-Path (Join-Path $Target '.workspace'))) {
        Write-Output 'shape B: pass -Repos <dir> so .workspace records where the clones are, or write it by hand (WS_REPOS=...).'
    }
}

Write-Output "copied $copied files into $Target\.claude\"
if ($kept.Count -gt 0) { Write-Output ("left alone (already existed): " + ($kept -join ' ')) }
Write-Output ''
Write-Output "Next: open the assistant at $Target and say: read START-HERE.md and follow it."
Write-Output 'Rules and hooks load at session start, so start a new session after this install.'
Write-Output ''
$bash = (Get-Command bash -ErrorAction SilentlyContinue).Source
if ($bash) { & $bash (Join-Path $Target '.claude/tools/verify.sh') } else { Write-Output 'bash not found; run .claude/tools/verify.sh from Git Bash.' }
