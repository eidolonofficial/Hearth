# Hearth, novice door for Windows. Pure PowerShell 5.1. Copies the skills folder
# into your Claude Code skills folder and does nothing else.
# -Yes   replace skills that already exist without asking (your old copy is still saved)
# -Home  use this folder in place of your user folder (for tests)
param(
    [switch]$Yes,
    [Alias('Home')][string]$HomeDir
)
$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
if (-not $root) { $root = Split-Path -Parent $MyInvocation.MyCommand.Path }
$src = Join-Path $root 'skills'
if ($HomeDir) { $base = $HomeDir } else { $base = $env:USERPROFILE }
$dest = Join-Path $base '.claude\skills'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $dest ('.hearth-backups\' + $stamp)

function Say([string]$text) { Write-Host $text }

function Fail-Soft([string]$what, [string]$tryThis) {
    Say ''
    Say $what
    Say ('Try this: ' + $tryThis)
    Say 'Nothing is broken. You can run this again.'
}

# Copy one file. Text files are written as UTF-8 with no BOM and LF endings.
# Files that already match, and any binary file, are copied byte for byte.
function Copy-One([string]$from, [string]$to) {
    $dir = Split-Path -Parent $to
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $bytes = [System.IO.File]::ReadAllBytes($from)
    $isBinary = [Array]::IndexOf($bytes, [byte]0) -ge 0
    $hasCr = [Array]::IndexOf($bytes, [byte]13) -ge 0
    $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    if ($isBinary -or (-not $hasCr -and -not $hasBom)) {
        [System.IO.File]::WriteAllBytes($to, $bytes)
        return
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $text = [System.IO.File]::ReadAllText($from, $utf8NoBom)
    $text = $text.TrimStart([char]0xFEFF) -replace "`r`n", "`n" -replace "`r", "`n"
    [System.IO.File]::WriteAllText($to, $text, $utf8NoBom)
}

# Update notice. One request to GitHub for the latest Hearth release, three seconds at most, and
# silence when it fails. EIDOLON_UPDATE_CHECK=0 turns it off. HEARTH_RELEASE_API replaces the
# address (tests). Nothing changes unless you type yes.
function Get-Version([string]$text) {
    if ($text -match '(\d+)\.(\d+)\.(\d+)') { return @([int]$Matches[1], [int]$Matches[2], [int]$Matches[3]) }
    return $null
}
function Test-Newer($candidate, $current) {
    if (-not $candidate -or -not $current) { return $false }
    for ($i = 0; $i -lt 3; $i++) {
        if ($candidate[$i] -ne $current[$i]) { return ($candidate[$i] -gt $current[$i]) }
    }
    return $false
}
function Get-UpdatePage {
    if ($env:EIDOLON_UPDATE_CHECK -eq '0') { return $null }
    try {
        $mine = Get-Version ((Get-Content -LiteralPath (Join-Path $root 'package.json') -Raw | ConvertFrom-Json).version)
        $api = $env:HEARTH_RELEASE_API
        if (-not $api) { $api = 'https://api.github.com/repos/eidolonofficial/Hearth/releases/latest' }
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072
        $latest = Invoke-RestMethod -Uri $api -TimeoutSec 3 -UseBasicParsing -Headers @{ 'User-Agent' = 'hearth-update-check' }
        $theirs = Get-Version ([string]$latest.tag_name)
        if (-not (Test-Newer $theirs $mine)) { return $null }
        Say ('Hearth v' + ($theirs -join '.') + ' is available. This copy is v' + ($mine -join '.') + '.')
        Say ('Download: ' + $latest.html_url)
        if ($Yes.IsPresent) { Say ''; return $null }
        $answer = Read-Host 'Type yes to open the download page and stop here, or press Enter to continue with this copy'
        Say ''
        if ($answer.Trim().ToLower() -eq 'yes') { return [string]$latest.html_url }
    } catch { }
    return $null
}

Say 'Hearth copies two skills, Eidolon and Setup, into your Claude Code skills folder.'
Say ('It writes only inside ' + $dest + '. Nothing else is installed.')
Say 'If a skill is already there, I ask first and keep your old copy.'
Say ''

$page = Get-UpdatePage
if ($page) {
    Start-Process $page
    Say 'Run Start Here.cmd from the new download. Nothing was installed.'
    exit 0
}

if (-not (Test-Path -LiteralPath $src)) {
    Fail-Soft 'The skills folder is not next to this file.' 'keep the whole Hearth folder together and open Start Here.cmd from inside it.'
    exit 1
}
$skills = @(Get-ChildItem -LiteralPath $src -Directory)
if ($skills.Count -eq 0) {
    Fail-Soft 'The skills folder is empty.' 'download Hearth again and keep the whole folder.'
    exit 1
}
try {
    if (-not (Test-Path -LiteralPath $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }
} catch {
    Fail-Soft ('I could not open ' + $dest + '.') 'close other programs that may use that folder, then run this again.'
    exit 1
}

$installed = @()
$skipped = @()
$failures = 0
foreach ($skill in $skills) {
    $name = $skill.Name
    $target = Join-Path $dest $name
    if (Test-Path -LiteralPath $target) {
        $replace = $Yes.IsPresent
        if (-not $replace) {
            $answer = Read-Host ($name + ' is already installed. Type replace to swap it, or press Enter to skip')
            $replace = ($answer.Trim().ToLower() -eq 'replace')
        }
        if (-not $replace) {
            Say ('Skipped ' + $name + '. Your copy is unchanged.')
            $skipped += $name
            continue
        }
        try {
            if (-not (Test-Path -LiteralPath $backupRoot)) { New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null }
            Move-Item -LiteralPath $target -Destination (Join-Path $backupRoot $name)
            Say ('Saved your old ' + $name + ' to ' + (Join-Path $backupRoot $name))
        } catch {
            Fail-Soft ('I could not save your old ' + $name + ', so I left it alone.') 'close any program that has that folder open, then run this again.'
            $failures++
            continue
        }
    }
    $prefix = $skill.FullName.TrimEnd('\') + '\'
    $failedHere = 0
    foreach ($file in (Get-ChildItem -LiteralPath $skill.FullName -Recurse -File -Force)) {
        $relative = $file.FullName.Substring($src.TrimEnd('\').Length + 1)
        try {
            Copy-One $file.FullName (Join-Path $dest $relative)
            Say ('  copied ' + $relative.Replace('\', '/'))
        } catch {
            Say ('  did not copy ' + $relative.Replace('\', '/'))
            $failedHere++
        }
    }
    if ($failedHere -gt 0) {
        Fail-Soft ($failedHere.ToString() + ' file(s) of ' + $name + ' did not copy.') 'run this again. Files already copied are safe to copy over.'
        $failures++
    } else {
        $installed += $name
    }
}

Say ''
if ($installed.Count -gt 0) { Say ('Installed now: ' + ($installed -join ', ') + ' in ' + $dest) }
if ($skipped.Count -gt 0) { Say ('Skipped, still your own copy: ' + ($skipped -join ', ')) }
if ($failures -gt 0) { exit 1 }
Say 'To start: open Claude Code and type /eidolon or /setup.'
exit 0
