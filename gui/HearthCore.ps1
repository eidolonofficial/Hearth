# Hearth: the shared install core.
#
# Pure logic, no on-screen voice. The graphical window (gui\Hearth.ps1) and the
# text installer (welcome.ps1) both call these, so the real work lives in exactly
# one place. Every line is plain, visible text. There is no hidden code, no base64.
# Nothing here installs anything without a yes from the caller.

function Get-HearthRoot {
    # The Hearth folder is the parent of this gui\ folder.
    return (Split-Path -Parent $PSScriptRoot)
}

function Test-HearthCommand {
    param([string]$Name)
    try { return [bool](Get-Command $Name -ErrorAction SilentlyContinue) } catch { return $false }
}

function Get-HearthTools {
    # The two optional tools, as data. Cards are the five W's and How shown before
    # any yes. Windows installs graphify with pip; both use the makers' official
    # packages, fetched from their own sources, only on consent.
    param([string]$Root)
    return @(
        @{
            name      = 'graphify'
            what      = 'It turns a folder of work into a clear map you can explore.'
            why       = 'As your project grows, this helps you and Claude see how the pieces connect.'
            who       = 'Made by Safi Shamsi. github.com/safishamsi/graphify (MIT license).'
            wherefrom = 'Its official package, named graphifyy, the one the maker publishes.'
            when      = 'Reach for it when you want a birds-eye view of a project folder.'
            how       = 'Say yes and Hearth runs: pip install graphifyy, then graphify install, in this folder.'
            runtime   = 'python'
            verify    = 'graphify'
            workdir   = $Root
            steps     = @('pip install graphifyy', 'graphify install .')
        },
        @{
            name      = 'mempalace'
            what      = 'It gives Claude a searchable memory, so it can recall what you worked on before.'
            why       = 'Instead of repeating yourself each session, Claude looks things up and stays on the same page.'
            who       = 'Lead author igorls; Claude plugin by milla-jovovich. github.com/MemPalace/mempalace (MIT license).'
            wherefrom = 'Its official package, installed with uv (the helper from Astral).'
            when      = 'Reach for it when you want Claude to remember context across days and projects.'
            how       = 'Say yes and Hearth runs: uv tool install mempalace, mempalace init, then registers its memory with Claude.'
            runtime   = 'uv'
            verify    = 'mempalace'
            workdir   = $null
            steps     = @('uv tool install mempalace', 'mempalace init', 'claude mcp add mempalace -- mempalace-mcp')
        }
    )
}

function Get-HearthRuntimeStatus {
    # Check and instruct only. Never installs system tooling. Returns ready, or the
    # one official command for the caller to show so the person stays in charge.
    param([string]$Which)  # 'uv' or 'python'
    if ($Which -eq 'uv') {
        if (Test-HearthCommand 'uv') { return @{ ready = $true } }
        return @{
            ready   = $false
            title   = 'This tool needs uv, a small helper by a team named Astral.'
            note    = 'uv is a fast installer for Python tools, and it brings Python along. It is not on your computer yet, and Hearth will not install it for you without asking.'
            command = 'winget install --id=astral-sh.uv -e'
            also    = 'There is also a one-line installer at https://astral.sh/uv.'
        }
    }
    if ($Which -eq 'python') {
        if ((Test-HearthCommand 'python') -or (Test-HearthCommand 'py') -or (Test-HearthCommand 'uv')) { return @{ ready = $true } }
        return @{
            ready   = $false
            title   = 'This tool needs Python, the language it is written in.'
            note    = 'It is not on your computer yet, and Hearth will not install it for you without asking.'
            command = 'winget install --id=Python.Python.3.13 -e'
            also    = 'uv, the helper from the other tool, also brings Python with it.'
        }
    }
    return @{ ready = $false }
}

function Install-HearthSkills {
    # Copy every file under skills\ into ~/.claude/skills, keeping the folder shape.
    # Written UTF-8 without a BOM, LF line endings, to match the originals exactly.
    # OnFile, if given, is called as: & $OnFile $relativePath $index $total
    param(
        [string]$Root,
        [scriptblock]$OnFile = $null
    )
    $src  = Join-Path $Root 'skills'
    $dest = Join-Path $env:USERPROFILE '.claude\skills'
    if (-not (Test-Path $src))  { return @{ ok = $false; copied = 0; total = 0; error = 'skills-folder-missing' } }
    try {
        if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }
    } catch {
        return @{ ok = $false; copied = 0; total = 0; error = 'skills-home-unavailable' }
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $files = @()
    try { $files = Get-ChildItem -Path $src -Recurse -File } catch { $files = @() }
    $total = $files.Count
    if ($total -eq 0) { return @{ ok = $false; copied = 0; total = 0; error = 'skills-folder-empty' } }
    $copied = 0; $i = 0
    foreach ($file in $files) {
        $i++
        try {
            $relative  = $file.FullName.Substring($src.Length).TrimStart('\','/')
            $target    = Join-Path $dest $relative
            $targetDir = Split-Path -Parent $target
            if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
            $text = [System.IO.File]::ReadAllText($file.FullName)
            $text = $text -replace "`r`n","`n"
            $text = $text -replace "`r","`n"
            [System.IO.File]::WriteAllText($target, $text, $utf8NoBom)
            $copied++
            if ($OnFile) { & $OnFile $relative $i $total }
        } catch {
            # Skip a single bad file and keep going. The summary reports the count.
        }
    }
    return @{ ok = ($copied -gt 0); copied = $copied; total = $total; error = $null }
}

function Install-HearthTool {
    # Run a tool's official steps in order. OnStep, if given, is called as:
    # & $OnStep $stepText  (so the UI can say which command is running).
    # Returns ok=$true only if every step succeeded AND the verify command is found.
    param(
        [hashtable]$Tool,
        [scriptblock]$OnStep = $null
    )
    $allGood = $true
    foreach ($step in $Tool.steps) {
        if ($OnStep) { & $OnStep $step }
        $code = 0
        try {
            Push-Location
            if ($Tool.workdir) { Set-Location $Tool.workdir }
            Invoke-Expression $step | Out-Null
            $code = $LASTEXITCODE; if ($null -eq $code) { $code = 0 }
        } catch {
            $code = 1
        } finally {
            Pop-Location
        }
        if ($code -ne 0) { $allGood = $false; break }
    }
    $landed = if ($Tool.verify) { Test-HearthCommand $Tool.verify } else { $allGood }
    return @{ ok = ($allGood -and $landed) }
}
