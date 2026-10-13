# hooks/commit-quality-guard.ps1 — PowerShell mirror of the .mjs guard.
# Wire this instead of the .mjs on machines without Node (see hooks/README.md).
$raw = [Console]::In.ReadToEnd()
try { $j = $raw.Trim([char]0xFEFF).Trim() | ConvertFrom-Json } catch { exit 0 }
if ($null -eq $j -or $null -eq $j.tool_input) { exit 0 }
$cmd = [string]$j.tool_input.command
if ([string]::IsNullOrEmpty($cmd)) { exit 0 }

$bypass    = '\bgit\s+commit\b[^\n]*(--no-verify|--no-gpg-sign)'
$forcePush = '\bgit\s+push\b[^\n]*(--force(-with-lease)?\b|\s-f\b)'

if (($cmd -match $bypass) -or ($cmd -match $forcePush)) {
    [Console]::Error.WriteLine("COMMIT-QUALITY GUARD [BLOCKED]: gate bypass or force-push on a public repo. If the gate is wrong, change it in the open and say so. If history must move, do it through a new commit, not by rewriting.")
    exit 2
}
exit 0
