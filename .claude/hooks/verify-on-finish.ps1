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

    Where it looks: every git checkout under WS_REPOS when cwd carries a .workspace marker (shape
    B; the marker wins, because a workspace root is itself a checkout); otherwise the repository at
    cwd when cwd is a git checkout (shape A). If neither, exit 0. A hook that pointed at the wrong
    folders once found nothing and exited 0 on every turn while the status line said it was
    checking (2026-08-31). Say when there is nothing to check.

    What it compares against: the baseline of the task THIS session is carrying. baseline.sh seal
    writes baseline_commit.<checkout> into the front matter of working/<task>/brief.md at the
    owner's yes and binds it to the session in working/active-tasks/<session id>. This hook reads
    the pointer for the session id the host gives it, so two sessions sharing one checkout each
    measure their own task, and no brief is chosen by recency.
      - a weakening that was committed stays visible: a diff against HEAD alone shows nothing once
        the weakened test is committed (measured 2026-09-05);
      - renames are detected (-M), so a staged git mv plus a removed assertion is compared old path
        to new path;
      - a test added during the task has no version at the baseline, so it is compared against
        HEAD, as it was before the baseline existed.
    Fallback, never a block, and never a guess at which task is active: no session id, no pointer, a
    pointer that does not resolve, a brief with no seal, or a seal that does not name this checkout,
    and the comparison is against HEAD as it was before this mechanism. A sealed commit rewritten by
    a rebase, amend, or squash is compared from its merge-base with HEAD; one that does not exist
    here falls back to HEAD. The last four print a note; a session with no id and a session with no
    pointer are the ordinary case and stay quiet. A note goes to stdout, which Claude Code keeps in
    its debug log for a Stop hook that exits 0: it is for a person reading the log, not for the
    assistant. The hook never writes a pointer and never seals anything.
#>

$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
try { $payload = $raw | ConvertFrom-Json } catch { exit 0 }

# LOOP GUARD. Non-negotiable.
if ($payload.stop_hook_active -eq $true) { exit 0 }

$cwd = if ($payload.cwd) { $payload.cwd } else { (Get-Location).Path }
$session = [string]$payload.session_id

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
} elseif (Test-Path (Join-Path $cwd '.git')) {
    $repos += $cwd
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
# Same, for commands whose answer is the exit code (cat-file -e, merge-base --is-ancestor).
function Test-Git {
    param([string]$Repo, [string[]]$GitArgs)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try { & $git -C $Repo @GitArgs 2>$null | Out-Null; return ($LASTEXITCODE -eq 0) }
    catch { return $false } finally { $ErrorActionPreference = $prev }
}

# ---- the brief this session is carrying, if any ----------------------------------------------
$briefFile = $null; $briefName = ''; $fm = @()
if ($session -cmatch '^[A-Za-z0-9][A-Za-z0-9_-]{7,63}$') {
    $ptr = Join-Path (Join-Path (Join-Path $cwd 'working') 'active-tasks') $session
    if (Test-Path $ptr -PathType Leaf) {
        $rel = (Get-Content $ptr -ErrorAction SilentlyContinue | Where-Object { $_.Trim() -ne '' } | Select-Object -First 1)
        if ($rel) { $rel = $rel.Trim() }
        # one task folder, one brief: never a relay path, never an absolute path, never a traversal
        if ($rel -cmatch '^working/[A-Za-z0-9][A-Za-z0-9._-]*/brief\.md$' -and (Test-Path (Join-Path $cwd $rel) -PathType Leaf)) {
            $briefFile = Join-Path $cwd $rel; $briefName = $rel
        } else {
            Write-Output "note from verify-on-finish: the active-task pointer for this session does not resolve to a task brief; comparing against HEAD."
        }
    }
}
if ($briefFile) {
    $lines = @(Get-Content $briefFile -ErrorAction SilentlyContinue)
    if ($lines.Count -gt 0 -and $lines[0].Trim() -eq '---') {
        for ($i = 1; $i -lt $lines.Count; $i++) {
            if ($lines[$i].Trim() -eq '---') { break }
            $fm += $lines[$i]
        }
    }
    if (-not ($fm | Where-Object { $_ -cmatch '^baseline_commit(\.[^:]*)?:' })) {
        Write-Output "note from verify-on-finish: $briefName carries no baseline; comparing against HEAD."
        $briefFile = $null; $fm = @()
    }
}

function Get-Short {
    param([string]$Value)
    if ($Value.Length -ge 7) { return $Value.Substring(0, 7) }
    return $Value
}

function Test-IsTestFile {
    param([string]$Path)
    return ($Path -match '(?i)(\.test\.|\.spec\.|Tests?\.cs$|(^|[\\/])(tests?|__tests__)[\\/])')
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
function Get-SkipCount {
    param([string]$Text)
    if (-not $Text) { return 0 }
    return ([regex]::Matches($Text, '(?i)\.skip\s*\(|\.only\s*\(|\[Skip|@skip|xit\s*\(|xdescribe\s*\(')).Count
}

$problems = @()
foreach ($repo in $repos) {
    $name = Split-Path $repo -Leaf
    $base = 'HEAD'; $since = 'HEAD'
    if ($briefFile) {
        # the value is the last field, so a checkout folder with a space in its name still parses,
        # and StartsWith means a name with a regex character is not a pattern
        $key = "baseline_commit.$name" + ': '
        $hit = $fm | Where-Object { $_.StartsWith($key, [System.StringComparison]::Ordinal) } | Select-Object -First 1
        $sha = if ($hit) { ($hit.Trim() -split '\s+')[-1] } else { $null }
        if (-not $sha) {
            Write-Output "note from verify-on-finish: $briefName has no baseline for $name; comparing against HEAD."
        } elseif (Test-Git $repo @('merge-base', '--is-ancestor', $sha, 'HEAD')) {
            $base = $sha; $since = "the task baseline $(Get-Short $sha) ($briefName)"
        } else {
            $mb = Invoke-Git $repo @('merge-base', $sha, 'HEAD')
            $mb = if ($mb) { (@($mb) -join '').Trim() } else { '' }
            if ($mb) {
                $base = $mb; $since = "the merge-base $(Get-Short $mb) of the rewritten task baseline $(Get-Short $sha) ($briefName)"
                Write-Output "note from verify-on-finish: the task baseline $(Get-Short $sha) in $briefName is not an ancestor of HEAD in $name (rewritten by a rebase, amend, or squash); comparing from its merge-base $(Get-Short $mb)."
            } else {
                Write-Output "note from verify-on-finish: the task baseline $(Get-Short $sha) in $briefName does not exist in $name; comparing against HEAD instead."
            }
        }
    }
    $status = Invoke-Git $repo @('diff', '--name-status', '-M', $base)
    if (-not $status) { continue }
    foreach ($line in $status) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $parts = $line -split "`t", 3
        if ($parts.Count -lt 2) { continue }
        $code = $parts[0].Trim(); $file = $parts[1].Trim()
        $file2 = if ($parts.Count -ge 3) { $parts[2].Trim() } else { $file }
        $label = $null; $old = $file; $new = $file; $cmpBase = $base; $cmpSince = $since
        if ($code -like 'D*') {
            if (-not (Test-IsTestFile $file)) { continue }
            $problems += "DELETED  $name/$file since $since"; continue
        } elseif ($code -like 'M*') {
            if (-not (Test-IsTestFile $file)) { continue }
            $label = "$name/$file"
        } elseif ($code -like 'R*') {
            if (-not ((Test-IsTestFile $file) -or (Test-IsTestFile $file2))) { continue }
            $label = "$name/$file -> $file2 (renamed)"; $new = $file2
        } elseif ($code -like 'A*') {
            # added during the task: its only earlier version is the one committed since the baseline
            if (-not (Test-IsTestFile $file)) { continue }
            if (-not (Test-Git $repo @('cat-file', '-e', "HEAD:$file"))) { continue }
            $label = "$name/$file (added during the task)"; $cmpBase = 'HEAD'; $cmpSince = 'HEAD'
        } else { continue }
        $before = (Invoke-Git $repo @('show', "${cmpBase}:$old")) -join "`n"
        $afterPath = Join-Path $repo $new
        $after = if (Test-Path $afterPath) { Get-Content $afterPath -Raw -ErrorAction SilentlyContinue } else { '' }
        $b = Get-AssertionCount $before
        $a = Get-AssertionCount $after
        if ($a -lt $b) { $problems += "WEAKENED $label  (assertions $b -> $a) since $cmpSince" }
        $skipsBefore = Get-SkipCount $before
        $skipsAfter  = Get-SkipCount $after
        if ($skipsAfter -gt $skipsBefore) { $problems += "SKIPPED  $label  (skip markers $skipsBefore -> $skipsAfter) since $cmpSince" }
    }
}

if ($problems.Count -eq 0) { exit 0 }

$msg = @()
$msg += 'STOP: a test was weakened, skipped, or deleted.'
$msg += ''
$msg += $problems | ForEach-Object { "  $_" }
$msg += ''
$msg += 'Removing or editing a test to make a suite pass hides the behaviour the test existed'
$msg += 'to protect. Do one of these, then finish:'
$msg += '  - restore the assertions and fix the code instead; or'
$msg += '  - if the test genuinely encoded wrong behaviour, say so explicitly to the user,'
$msg += '    explain why the old assertion was wrong, and get their agreement.'
$msg += ''
$msg += 'Do not silence this by reverting the file and re-applying the same edit. A change made'
$msg += 'since the task baseline stays visible, committed or not, for as long as this session'
$msg += 'carries this task.'
[Console]::Error.WriteLine(($msg -join "`n"))
exit 2
