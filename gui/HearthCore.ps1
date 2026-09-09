# Hearth: shared installation mechanics. Optional services still require caller consent.
function Get-HearthRoot { return (Split-Path -Parent $PSScriptRoot) }
function Test-HearthCommand {
    param([string]$Name)
    try { return [bool](Get-Command $Name -ErrorAction SilentlyContinue) } catch { return $false }
}
function Get-HearthTools {
    # Legacy Claude-only optional offers. The new host picker installs skills only.
    param([string]$Root)
    return @(
        @{
            name = 'graphify'
            what = 'It turns a folder of work into a clear map you can explore.'
            why = 'As your project grows, this helps you and Claude see how the pieces connect.'
            who = 'graphify contributors; consult the current upstream credits and license.'
            wherefrom = 'The graphifyy Python package. Verify its current official instructions before use.'
            when = 'A birds-eye view of a project folder.'
            how = 'Say yes and Hearth runs: pip install graphifyy, then graphify install, in this folder.'
            runtime = 'python'
            verify = 'graphify'
            workdir = $Root
            steps = @('python -m pip install graphifyy', 'graphify install .')
        },
        @{
            name = 'mempalace'
            what = 'It gives Claude a searchable memory across sessions.'
            why = 'Instead of repeating yourself each session, Claude looks things up.'
            who = 'MemPalace contributors; consult the current upstream credits and license.'
            wherefrom = 'Its official package, installed with uv. Verify its current instructions before use.'
            when = 'Remembering context across days and projects.'
            how = 'Say yes and Hearth runs: uv tool install mempalace, mempalace init, then registers its memory with Claude.'
            runtime = 'uv'
            verify = 'mempalace'
            workdir = $null
            steps = @('uv tool install mempalace', 'mempalace init', 'claude mcp add mempalace -- mempalace-mcp')
        }
    )
}
function Get-HearthRuntimeStatus {
    param([string]$Which)
    if ($Which -eq 'uv') {
        if (Test-HearthCommand 'uv') { return @{ ready = $true } }
        return @{ ready = $false; title = 'This tool requires uv.'; note = 'Review the official installation instructions. Hearth will not install the runtime automatically.'; command = 'winget install --id=astral-sh.uv -e'; also = 'https://astral.sh/uv' }
    }
    if ($Which -eq 'python') {
        # Do not report uv or py as a working python -m pip invocation.
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
    param([string]$Root, [scriptblock]$OnFile = $null)
    if (-not (Test-HearthCommand 'node')) {
        return @{ ok = $false; copied = 0; total = 0; error = 'Node.js 22 or newer is required. Nothing was installed.' }
    }
    try {
        $output = & node (Join-Path $Root 'scripts/install.mjs') --host claude --yes 2>&1
        if ($LASTEXITCODE -ne 0) { return @{ ok = $false; copied = 0; total = 0; error = ($output | Out-String).Trim() } }
        $result = ($output | Out-String) | ConvertFrom-Json
        if (-not $result.ok) { throw 'Installer did not verify the complete bundle.' }
        if ($OnFile) { & $OnFile 'Verified complete bundle' $result.copied $result.copied }
        return @{ ok = $true; copied = $result.copied; total = $result.copied; error = $null }
    } catch { return @{ ok = $false; copied = 0; total = 0; error = $_.Exception.Message } }
}
function Install-HearthTool {
    param([hashtable]$Tool, [scriptblock]$OnStep = $null)
    $allGood = $true
    foreach ($step in $Tool.steps) {
        if ($OnStep) { & $OnStep $step }
        $code = 0
        try {
            Push-Location
            if ($Tool.workdir) { Set-Location -LiteralPath $Tool.workdir -ErrorAction Stop }
            Invoke-Expression $step | Out-Null
            $code = $LASTEXITCODE; if ($null -eq $code) { $code = 0 }
        } catch { $code = 1 } finally { Pop-Location }
        if ($code -ne 0) { $allGood = $false; break }
    }
    $landed = if ($Tool.verify) { Test-HearthCommand $Tool.verify } else { $allGood }
    return @{ ok = ($allGood -and $landed) }
}
