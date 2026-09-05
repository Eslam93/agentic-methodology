<#
    Stop hook: blocks a turn that weakened, skipped, or deleted a test.

    Deliberately LIGHT. It runs at the end of every turn, and a gate you click through ten times a
    day is not a gate: if it is slow, the first thing anyone does is switch it off. So this does
    pure git work and nothing that compiles. The full build and test suite live behind
    .claude/tools/verify.sh --full.

    It guards ONE failure mode, the one that is both most likely and most expensive: an agent
    changing behaviour and then editing the test so it matches. A green run across a pile of edited
    tests means nothing until somebody has looked at what the edits were.

    It also prints a note, never a block, when the last assistant message carries a rationalization
    phrase such as "skip the tests for now" or "pre-existing bug". Regex heuristics can be wrong, so
    that stays a note for the human.

    Contract: exit 0 fine; exit 2 blocks the turn from ending and stderr is shown to Claude.
    It must honour stop_hook_active or it loops against itself. Claude Code overrides any Stop hook
    after eight consecutive blocks, so this is a gate, not a wall.

    Where it looks: the repository at cwd when cwd is a git checkout (shape A); otherwise every
    git checkout under WS_REPOS from the .workspace marker at cwd (shape B). If neither, exit 0.
    A hook that pointed at the wrong folders once found nothing and exited 0 on every turn while
    the status line said it was checking (2026-08-31). Say when there is nothing to check.
#>

$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
try { $payload = $raw | ConvertFrom-Json } catch { exit 0 }

# LOOP GUARD. Non-negotiable.
if ($payload.stop_hook_active -eq $true) { exit 0 }

$cwd = if ($payload.cwd) { $payload.cwd } else { (Get-Location).Path }

# ---- rationalization note (never blocks) ------------------------------------------------
$transcript = $payload.transcript_path
if ($transcript -and (Test-Path $transcript)) {
    try {
        $tail = (Get-Content $transcript -Tail 40 -ErrorAction Stop) -join "`n"
        $phrases = 'skip (the )?tests? for now|pre-existing (bug|issue|failure)|good enough for now|can be fixed later|temporarily disabl|out of scope for this|will fix in a follow-?up'
        if ($tail -match "(?i)($phrases)") {
            Write-Output "note from verify-on-finish: the last message carries a rationalization phrase ($($Matches[1])). Worth a second look before accepting."
        }
    } catch { }
}

# ---- where to look ------------------------------------------------------------------------
$repos = @()
if (Test-Path (Join-Path $cwd '.git')) {
    $repos += $cwd
} else {
    $marker = Join-Path $cwd '.workspace'
    if (Test-Path $marker) {
        $line = Select-String -Path $marker -Pattern '^WS_REPOS=(.+)$' | Select-Object -First 1
        if ($line) {
            $reposRoot = $line.Matches[0].Groups[1].Value.Trim()
            if (Test-Path $reposRoot) {
                $repos = Get-ChildItem -Path $reposRoot -Directory -ErrorAction SilentlyContinue |
                         Where-Object { Test-Path (Join-Path $_.FullName '.git') } |
                         ForEach-Object { $_.FullName }
            }
        }
    }
}
if (-not $repos -or $repos.Count -eq 0) { exit 0 }

$git = (Get-Command git -ErrorAction SilentlyContinue).Source
if (-not $git) { exit 0 }

# Call git without ever letting its stderr reach PowerShell's error stream. Redirecting native
# stderr under 'Stop' is what killed this hook silently once (2026-09-01). Suspending 'Stop' for
# the call is the only form that both suppresses the warning text and cannot terminate the caller.
function Invoke-Git {
    param([string]$Repo, [string[]]$GitArgs)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & $git -C $Repo @GitArgs 2>$null
        if ($LASTEXITCODE -ne 0) { return $null }
        return $out
    } catch { return $null } finally { $ErrorActionPreference = $prev }
}

function Test-IsTestFile {
    param([string]$Path)
    return ($Path -match '(?i)(\.test\.|\.spec\.|Tests?\.cs$|[\\/](tests?|__tests__)[\\/])')
}

# Cheap proxy for how much a test is asserting.
function Get-AssertionCount {
    param([string]$Text)
    if (-not $Text) { return 0 }
    $patterns = @('\bit\s*\(', '\btest\s*\(', '\bexpect\s*\(', '\[Fact\]', '\[Theory\]', '\bAssert\.', '\bShould\b', '\bassert\s')
    $n = 0
    foreach ($p in $patterns) { $n += ([regex]::Matches($Text, $p)).Count }
    return $n
}

$problems = @()
foreach ($repo in $repos) {
    $name = Split-Path $repo -Leaf
    $status = Invoke-Git $repo @('diff', '--name-status', 'HEAD')
    if (-not $status) { continue }
    foreach ($line in $status) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $parts = $line -split "`t", 2
        if ($parts.Count -lt 2) { continue }
        $code = $parts[0].Trim(); $file = $parts[1].Trim()
        if (-not (Test-IsTestFile $file)) { continue }
        if ($code -like 'D*') { $problems += "DELETED  $name/$file"; continue }
        if ($code -like 'M*') {
            $before = (Invoke-Git $repo @('show', "HEAD:$file")) -join "`n"
            $afterPath = Join-Path $repo $file
            $after = if (Test-Path $afterPath) { Get-Content $afterPath -Raw -ErrorAction SilentlyContinue } else { '' }
            $b = Get-AssertionCount $before
            $a = Get-AssertionCount $after
            if ($a -lt $b) { $problems += "WEAKENED $name/$file  (assertions $b -> $a)" }
            $skipsBefore = ([regex]::Matches($before, '(?i)\.skip\s*\(|\.only\s*\(|\[Skip|@skip|xit\s*\(|xdescribe\s*\(')).Count
            $skipsAfter  = ([regex]::Matches($after,  '(?i)\.skip\s*\(|\.only\s*\(|\[Skip|@skip|xit\s*\(|xdescribe\s*\(')).Count
            if ($skipsAfter -gt $skipsBefore) { $problems += "SKIPPED  $name/$file  (skip markers $skipsBefore -> $skipsAfter)" }
        }
    }
}

if ($problems.Count -eq 0) { exit 0 }

$msg = @()
$msg += 'STOP: a test was weakened, skipped, or deleted in this change.'
$msg += ''
$msg += $problems | ForEach-Object { "  $_" }
$msg += ''
$msg += 'Removing or editing a test to make a suite pass hides the behaviour the test existed'
$msg += 'to protect. Do one of these, then finish:'
$msg += '  - restore the assertions and fix the code instead; or'
$msg += '  - if the test genuinely encoded wrong behaviour, say so explicitly to the user,'
$msg += '    explain why the old assertion was wrong, and get their agreement.'
$msg += ''
$msg += 'Do not silence this by reverting the file and re-applying the same edit.'
[Console]::Error.WriteLine(($msg -join "`n"))
exit 2
