# hooks/hedge-guard.ps1 — PowerShell mirror of the .mjs guard. ADVISORY only.
# Wire this instead of the .mjs on machines without Node (see hooks/README.md).
$raw = [Console]::In.ReadToEnd()
try { $j = $raw.Trim([char]0xFEFF).Trim() | ConvertFrom-Json } catch { exit 0 }
if ($null -eq $j -or $null -eq $j.tool_input) { exit 0 }
$ti = $j.tool_input
$path = [string]$ti.file_path
if ($path -notmatch '(SKILL\.md|README\.md|references[\\/].+\.md|docs[\\/].+\.md)$') { exit 0 }
if ($path -match 'hooks[\\/]|skill-audit|working-with-claude') { exit 0 }

$body = ''
$content = $ti.PSObject.Properties['content']
$newStr  = $ti.PSObject.Properties['new_string']
if ($null -ne $content) { $body = [string]$content.Value }
elseif ($null -ne $newStr) { $body = [string]$newStr.Value }

$hedge = '\b(probably|should work|should be fine|i think|i believe|most likely|in theory|presumably|seems to work|appears to work)\b'
if ($body -notmatch $hedge) { exit 0 }

$note = "HEDGE GUARD: a hedged phrase is going into published prose. This repo's rule (references/verify.md): a hedge is the tell that a claim has not been checked - either check it and drop the hedge, or label the claim unsure and hand it to the person. If the line ENUMERATES watch words as catalog entries rather than making a claim, carry on."
$out = @{ systemMessage = $note; hookSpecificOutput = @{ hookEventName = 'PreToolUse'; additionalContext = $note } } | ConvertTo-Json -Compress
[Console]::Out.Write($out)
exit 0
