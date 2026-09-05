<#
    SessionStart hook, matcher "compact": after a compaction, put the disposable state back in
    front of the assistant so the build continues from the agreed brief rather than from a summary.

    Prints, to stdout (which SessionStart adds to the context): working/status.md, then the newest
    working/*/brief.md. Capped so it cannot flood the context. Exit 0 always; this hook only informs.
#>

$ErrorActionPreference = 'SilentlyContinue'

$raw = [Console]::In.ReadToEnd()
try { $payload = $raw | ConvertFrom-Json } catch { $payload = $null }
$cwd = if ($payload -and $payload.cwd) { $payload.cwd } else { (Get-Location).Path }
$working = Join-Path $cwd 'working'
if (-not (Test-Path $working)) { exit 0 }

$out = @()
$status = Join-Path $working 'status.md'
if (Test-Path $status) {
    $out += 'After compaction. Re-read before continuing. working/status.md:'
    $out += (Get-Content $status -TotalCount 60)
}

$brief = Get-ChildItem -Path $working -Filter 'brief.md' -Recurse -File |
         Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($brief) {
    $rel = $brief.FullName.Substring($cwd.Length).TrimStart('\', '/')
    $out += ''
    $out += "The task brief in flight, $rel (agreed with the owner; do not re-plan it):"
    $out += (Get-Content $brief.FullName -TotalCount 80)
}

if ($out.Count -gt 0) { Write-Output ($out -join "`n") }
exit 0
