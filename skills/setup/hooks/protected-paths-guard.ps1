# hooks/protected-paths-guard.ps1 — PowerShell mirror of the .mjs guard.
# Wire this instead of the .mjs on machines without Node (see hooks/README.md).
$raw = [Console]::In.ReadToEnd()
try { $j = $raw.Trim([char]0xFEFF).Trim() | ConvertFrom-Json } catch { exit 0 }
if ($null -eq $j -or $null -eq $j.tool_input) { exit 0 }
$cmd = [string]$j.tool_input.command
if ([string]::IsNullOrEmpty($cmd)) { exit 0 }

$protected   = '\b(LICENSE|SKILL\.md)\b|references[\\/]|\.git\b'
$destructive = '(^|[;&|()]\s*)(rm|del|rmdir|rd|Remove-Item)\b|\bgit\s+rm\b'

if (($cmd -match $destructive) -and ($cmd -cmatch $protected)) {
    [Console]::Error.WriteLine("PROTECTED-PATHS GUARD [BLOCKED]: this command would destroy a protected file (LICENSE, SKILL.md, references/, .git). If the removal is deliberate, change this guard first, in the open, in its own commit.")
    exit 2
}
exit 0
