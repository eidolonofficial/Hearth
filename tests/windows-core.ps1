$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
. (Join-Path $Root 'gui/HearthCore.ps1')
$temp = Join-Path ([IO.Path]::GetTempPath()) ('hearth-core-' + [guid]::NewGuid().ToString())
[void](New-Item -ItemType Directory -Path $temp)
$previous = $env:USERPROFILE
try {
    $env:USERPROFILE = $temp
    $declined = Install-HearthSkills -Root $Root -ConfirmPlan { param($plan) $false }
    if ($declined.ok -or (Test-Path (Join-Path $temp '.claude/skills/eidolon'))) { throw 'Declined installation changed a skill target' }
    $first = Install-HearthSkills -Root $Root -ConfirmPlan { param($plan) $plan.dryRun -and $plan.planDigest.Length -eq 64 }
    if (-not $first.ok) { throw ('Initial install failed: ' + $first.error) }
    foreach ($name in @('setup','eidolon')) {
        if (-not (Test-Path (Join-Path $temp ('.claude/skills/' + $name + '/SKILL.md')))) { throw ('Missing skill: ' + $name) }
    }
    $path = Join-Path $temp '.claude/skills/eidolon/SKILL.md'
    $before = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    $second = Install-HearthSkills -Root $Root -ConfirmPlan { param($plan) $plan.dryRun -and $plan.planDigest.Length -eq 64 }
    if ($second.ok) { throw 'Existing skills were overwritten without replacement consent' }
    if ($second.error -notmatch '--replace') { throw ('Unexpected replacement failure: ' + $second.error) }
    if ((Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $before) { throw 'Refused replacement changed existing bytes' }
    foreach ($tool in @(Get-HearthTools -Root $Root)) {
        if (-not $tool.blocked -or $tool.steps.Count -ne 0) { throw 'Optional tool is not held before execution' }
        $result = Install-HearthTool -Tool $tool
        if ($result.ok) { throw 'Optional-service hold was bypassed' }
    }
    Write-Host ('PASS: PowerShell ' + $PSVersionTable.PSVersion + ' verified decline, exact installation, replacement preservation and optional-service holds.')
} finally {
    $env:USERPROFILE = $previous
    Remove-Item -LiteralPath $temp -Recurse -Force
}
exit 0
