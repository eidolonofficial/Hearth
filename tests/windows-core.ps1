$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
. (Join-Path $Root 'gui/HearthCore.ps1')
$temp = Join-Path ([IO.Path]::GetTempPath()) ('hearth-core-' + [guid]::NewGuid().ToString())
[void](New-Item -ItemType Directory -Path $temp)
$previous = $env:USERPROFILE
try {
    $env:USERPROFILE = $temp
    $first = Install-HearthSkills -Root $Root
    if (-not $first.ok) { throw ('Initial install failed: ' + $first.error) }
    if (-not (Test-Path (Join-Path $temp '.claude/skills/setup/SKILL.md'))) { throw 'Setup was not installed' }
    if (-not (Test-Path (Join-Path $temp '.claude/skills/eidolon/SKILL.md'))) { throw 'Eidolon was not installed' }
    $second = Install-HearthSkills -Root $Root
    if ($second.ok) { throw 'Existing skills were overwritten without replacement consent' }
    Write-Host 'PASS: Windows PowerShell copy core installed both skills and refused unapproved replacement.'
} finally {
    $env:USERPROFILE = $previous
    Remove-Item -LiteralPath $temp -Recurse -Force
}
