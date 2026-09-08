# Text fallback: use the same explicit host picker as Start Agents.
$ErrorActionPreference = 'Stop'
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host 'Node.js 18 or newer is required. Nothing was installed. See README.md.'
    exit 1
}
& node (Join-Path $PSScriptRoot 'scripts/welcome.mjs')
exit $LASTEXITCODE
