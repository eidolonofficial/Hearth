# Hearth: shared installation mechanics. Optional services still require caller consent.
function Get-HearthRoot { return (Split-Path -Parent $PSScriptRoot) }
function Test-HearthCommand {
    param([string]$Name)
    try { return [bool](Get-Command $Name -ErrorAction SilentlyContinue) } catch { return $false }
}
function Get-HearthTools {
    param([string]$Root)
    return @(
        @{ name='graphify'; what='Optional project maps'; why='Separate dependency and data-access approval is required.'; who='Graphifyy contributors'; wherefrom='Reviewed upstream package'; when='Only after a reviewed installation plan'; how='Automatic installation is held until a hash-pinned dependency plan is approved.'; runtime=''; verify='graphify'; workdir=$Root; steps=@(); blocked=$true },
        @{ name='mempalace'; what='Optional persistent memory'; why='The audited dependency graph contains unresolved ChromaDB advisories.'; who='MemPalace contributors'; wherefrom='Reviewed upstream package'; when='Only after the security hold is resolved'; how='New automatic installation is held. Existing installations will not be changed.'; runtime=''; verify='mempalace'; workdir=$null; steps=@(); blocked=$true }
    )
}
function Get-HearthRuntimeStatus {
    param([string]$Which)
    if ($Which -eq 'uv') {
        if (Test-HearthCommand 'uv') { return @{ ready = $true } }
        return @{ ready = $false; title = 'This tool requires uv.'; note = 'Review the official installation instructions. Hearth will not install the runtime automatically.'; command = 'winget install --id=astral-sh.uv -e'; also = 'https://astral.sh/uv' }
    }
    if ($Which -eq 'python') {
        if (Test-HearthCommand 'python') {
            try { & python -m pip --version *> $null; if ($LASTEXITCODE -eq 0) { return @{ ready = $true } } } catch {}
        }
        return @{ ready = $false; title = 'This tool requires Python with pip.'; note = 'Review the official installation instructions. Nothing was installed.'; command = 'winget install --id=Python.Python.3.13 -e'; also = 'https://www.python.org/downloads/' }
    }
    return @{ ready = $false }
}
function Install-HearthSkills {
    # Both legacy Claude interfaces use the verified transaction shared with Codex.
    # Replacements are refused here; Start Agents obtains separate replacement consent.
    param([string]$Root, [scriptblock]$OnFile = $null, [scriptblock]$ConfirmPlan = $null)
    if (-not (Test-HearthCommand 'node')) {
        return @{ ok = $false; copied = 0; total = 0; error = 'Node.js 22 or newer is required. Nothing was installed.' }
    }
    try {
        $preview = & node (Join-Path $Root 'scripts/install.mjs') --host claude 2>&1
        if ($LASTEXITCODE -ne 0) { throw (($preview | Out-String).Trim()) }
        $plan = ($preview | Out-String) | ConvertFrom-Json
        if (-not $plan.dryRun -or $plan.planDigest -notmatch '^[0-9a-f]{64}$') { throw 'No valid reviewed installation plan.' }
        if ($ConfirmPlan) { $approved = (& $ConfirmPlan $plan) -eq $true }
        else {
            Add-Type -AssemblyName PresentationFramework
            $message = "Install only the following reviewed paths?`n`n" + ($plan.paths -join "`n") + "`n`nPlan: " + $plan.planDigest
            $approved = [System.Windows.MessageBox]::Show($message, 'Review Hearth installation', 'YesNo', 'Question') -eq 'Yes'
        }
        if (-not $approved) { throw 'Installation was not approved. Nothing was replaced.' }
        $output = & node (Join-Path $Root 'scripts/install.mjs') --host claude --expect-plan $plan.planDigest --yes 2>&1
        if ($LASTEXITCODE -ne 0) { return @{ ok = $false; copied = 0; total = 0; error = ($output | Out-String).Trim() } }
        $result = ($output | Out-String) | ConvertFrom-Json
        if (-not $result.ok) { throw 'Installer did not verify the complete bundle.' }
        if ($OnFile) { & $OnFile 'Verified complete bundle' $result.copied $result.copied }
        return @{ ok = $true; copied = $result.copied; total = $result.copied; error = $null }
    } catch { return @{ ok = $false; copied = 0; total = 0; error = $_.Exception.Message } }
}
function Install-HearthTool {
    param([hashtable]$Tool, [scriptblock]$OnStep = $null)
    # Fail before running any supplied steps. This does not change installed services.
    return @{ ok=$false; error='Optional-service automatic installation is held pending a reviewed, hash-pinned dependency and data-access plan.' }
}
