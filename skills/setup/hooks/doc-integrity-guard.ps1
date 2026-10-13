# hooks/doc-integrity-guard.ps1 — PowerShell mirror of the .mjs guard.
# Wire this instead of the .mjs on machines without Node (see hooks/README.md).
$raw = [Console]::In.ReadToEnd()
try { $j = $raw.Trim([char]0xFEFF).Trim() | ConvertFrom-Json } catch { exit 0 }
if ($null -eq $j -or $null -eq $j.tool_input) { exit 0 }
$ti = $j.tool_input
$path = [string]$ti.file_path
if ($path -notmatch 'docs[\\/](fixes|insights)[\\/].+\.md$') { exit 0 }

function Get-LineCount([string]$s) { ($s -split "`n").Count }

$shrink = $false
$content = $ti.PSObject.Properties['content']
$oldStr  = $ti.PSObject.Properties['old_string']
$newStr  = $ti.PSObject.Properties['new_string']
if ($null -ne $content -and (Test-Path $path)) {
    try {
        $existing = Get-Content -Raw $path
        $shrink = (Get-LineCount $content.Value) -lt (Get-LineCount $existing)
    } catch { }
} elseif ($null -ne $oldStr -and $null -ne $newStr) {
    $shrink = (Get-LineCount $newStr.Value) -lt (Get-LineCount $oldStr.Value)
}

if ($shrink) {
    [Console]::Error.WriteLine("DOC-INTEGRITY GUARD [BLOCKED]: docs/fixes and docs/insights are append-only. Fix a wrong entry by appending a correction, or retire the whole file via git in its own commit. Never shrink history in place.")
    exit 2
}
exit 0
