try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
$ErrorActionPreference = 'Stop'

# Hearth: a calm way to set up Claude.
# This whole file is plain, visible text. There is no hidden code, no base64.
# You can read every line. Nothing runs unless you say yes.
# The real logo lives in assets\EidolonLogo.png. The full thank-you list lives in CREDITS.md.

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

# Soft palette. We keep colors gentle. Green means a small win. Cyan is a calm voice.
$cGreen = 'Green'
$cCyan  = 'Cyan'
$cSoft  = 'DarkGray'
$cWarm  = 'Yellow'

# Can this console show soft Unicode shapes? Default yes when our UTF-8 output
# encoding took hold at the top of this file, and fall back to plain ASCII
# otherwise. Set HEARTH_ASCII=1 to force the plain look. Either way the layout
# is identical, so the experience stays the same.
$script:UseUnicode = $true
try { if ([Console]::OutputEncoding.CodePage -ne 65001) { $script:UseUnicode = $false } } catch { $script:UseUnicode = $false }
if ($env:HEARTH_ASCII -eq '1') { $script:UseUnicode = $false }

# The two glyph sets. Soft rounded shapes when we can, plain ASCII when we cannot.
if ($script:UseUnicode) {
    $g = @{ TL='╭'; TR='╮'; BL='╰'; BR='╯'; H='─'; V='│'; ML='├'; MR='┤'; Fill='█'; Empty='░'; Check='✓'; Bullet='•' }
} else {
    $g = @{ TL='+'; TR='+'; BL='+'; BR='+'; H='-'; V='|'; ML='+'; MR='+'; Fill='#'; Empty='.'; Check='[ok]'; Bullet='-' }
}

# The inside width of every framed box, so the cards and banners all line up.
$script:INW = 64

# A small pause helper, so words land gently instead of all at once.
function Pause-Soft {
    param([int]$Ms = 350)
    try { Start-Sleep -Milliseconds $Ms } catch {}
}

# ----------------------------------------------------------------------------
# Box drawing helpers. Every frame in Hearth is one closed, aligned rectangle.
# The rails are soft gray; the text between them carries its own gentle color.
# ----------------------------------------------------------------------------
function Draw-BoxTop    { Write-Host ("    " + $g.TL + ($g.H * $script:INW) + $g.TR) -ForegroundColor $cSoft }
function Draw-BoxBottom { Write-Host ("    " + $g.BL + ($g.H * $script:INW) + $g.BR) -ForegroundColor $cSoft }
function Draw-BoxDiv    { Write-Host ("    " + $g.ML + ($g.H * $script:INW) + $g.MR) -ForegroundColor $cSoft }
function Draw-Divider   { Write-Host ("    " + ($g.H * $script:INW)) -ForegroundColor $cSoft }

# One content line inside a box: gray rails, colored text padded to the width.
function Draw-BoxLine {
    param([string]$text, [string]$color = $cCyan)
    $inner = $script:INW - 2
    if ($text.Length -gt $inner) { $text = $text.Substring(0, $inner) }
    $text = $text.PadRight($inner)
    Write-Host ("    " + $g.V + " ") -ForegroundColor $cSoft -NoNewline
    Write-Host $text -ForegroundColor $color -NoNewline
    Write-Host (" " + $g.V) -ForegroundColor $cSoft
}

# A centered content line inside a box.
function Draw-BoxCenter {
    param([string]$text, [string]$color = $cCyan)
    $inner = $script:INW - 2
    if ($text.Length -gt $inner) { $text = $text.Substring(0, $inner) }
    $left = [int](($inner - $text.Length) / 2)
    Draw-BoxLine -text ((' ' * $left) + $text) -color $color
}

# One labeled row of a card (What, Why, ...), word-wrapped to fit the rails.
# Continuation lines are indented under the value so the column stays clean.
function Draw-CardRow {
    param([string]$label, [string]$value)
    $inner  = $script:INW - 2
    $indent = ' ' * $label.Length
    $avail  = $inner - $label.Length
    $words  = $value -split ' '
    $line   = ''
    $first  = $true
    foreach ($w in $words) {
        if ($line -eq '') {
            $line = $w
        } elseif (($line.Length + 1 + $w.Length) -le $avail) {
            $line = "$line $w"
        } else {
            if ($first) { Draw-BoxLine -text ($label + $line) -color $cCyan; $first = $false }
            else        { Draw-BoxLine -text ($indent + $line) -color $cCyan }
            $line = $w
        }
    }
    if ($first) { Draw-BoxLine -text ($label + $line) -color $cCyan }
    else        { Draw-BoxLine -text ($indent + $line) -color $cCyan }
}

# ----------------------------------------------------------------------------
# Show-Header: a warm wordmark and a soft bordered box.
# ----------------------------------------------------------------------------
function Show-Header {
    Write-Host ""
    Write-Host "        _   _   _____      _      ____    _____   _   _   " -ForegroundColor $cWarm
    Write-Host "       | | | | | ____|    / \    |  _ \  |_   _| | | | |  " -ForegroundColor $cWarm
    Write-Host "       | |_| | |  _|     / _ \   | |_) |   | |   | |_| |  " -ForegroundColor $cWarm
    Write-Host "       |  _  | | |___   / ___ \  |  _ <    | |   |  _  |  " -ForegroundColor $cWarm
    Write-Host "       |_| |_| |_____| /_/   \_\ |_| \_\   |_|   |_| |_|  " -ForegroundColor $cWarm
    Write-Host ""
    Draw-BoxTop
    Draw-BoxLine   -text "" -color $cCyan
    Draw-BoxCenter -text "a calm way to set up Claude" -color $cCyan
    Draw-BoxCenter -text $g.Bullet -color $cSoft
    Draw-BoxBottom
    Write-Host ""
    # A cozy hearth: fire in the fireplace, a cat dozing on the rug.
    Write-Host '              (   )     (   )     (   )' -ForegroundColor $cWarm
    Write-Host '               ) (   )   ) (   )   ) (' -ForegroundColor $cWarm
    Write-Host '              (   )  (  (   )  )  (   )' -ForegroundColor $cWarm
    Write-Host '          .--------------------------------------.' -ForegroundColor $cWarm
    Write-Host '          |   )(    )(    )(    )(    )(    )(     |' -ForegroundColor $cWarm
    Write-Host '          |  (  )  (  )  (  )  (  )  (  )  (  )    |' -ForegroundColor $cWarm
    Write-Host '          |   \|/    \|/    \|/    \|/    \|/      |' -ForegroundColor $cWarm
    Write-Host '          |  __|______|______|______|______|___   |' -ForegroundColor $cWarm
    Write-Host '          | /=====/=====/=====/=====/=====/====/   |' -ForegroundColor $cWarm
    Write-Host '          |______________________________________|' -ForegroundColor $cWarm
    Write-Host '        __|______________________________________|__' -ForegroundColor $cSoft
    Write-Host '       [__________________________________________]' -ForegroundColor $cSoft
    Write-Host ""
    Write-Host '                     /\_/\' -ForegroundColor $cCyan
    Write-Host '                    ( -.- )    ~ purr ~' -ForegroundColor $cCyan
    Write-Host '                 ___m(")_(")m___' -ForegroundColor $cCyan
    Write-Host '         .-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-.' -ForegroundColor $cSoft
    Write-Host '        (_________________________________________)' -ForegroundColor $cSoft
    Write-Host ""
}

# ----------------------------------------------------------------------------
# Show-Skills-Intro: what the two skills are, why there are two, and a gentle
# preview of the one question Setup will ask the first time you work.
# ----------------------------------------------------------------------------
function Show-Skills-Intro {
    Write-Host ""
    Write-Host "    Your two skills, and why there are two." -ForegroundColor $cWarm
    Write-Host ""
    Write-Host "      Setup is the calm start of a work session. When you sit down to a" -ForegroundColor $cCyan
    Write-Host "      piece of work, it asks a few short questions so Claude works the way" -ForegroundColor $cCyan
    Write-Host "      you like, it quietly remembers what helped and what did not, and it" -ForegroundColor $cCyan
    Write-Host "      double-checks its own work before calling anything done. Setup is" -ForegroundColor $cCyan
    Write-Host "      about the session: this visit, this stretch of work." -ForegroundColor $cCyan
    Write-Host ""
    Write-Host "      Eidolon is about the project itself. It reads a whole project folder" -ForegroundColor $cCyan
    Write-Host "      and sets up what Claude needs to understand it, and when you want to" -ForegroundColor $cCyan
    Write-Host "      build or change something, it carries that work from a plain idea all" -ForegroundColor $cCyan
    Write-Host "      the way to finished: it plans the work, builds it a careful piece at a" -ForegroundColor $cCyan
    Write-Host "      time, checks it over for safety and mistakes, and only then puts it in place." -ForegroundColor $cCyan
    Write-Host "" -ForegroundColor $cCyan
    Write-Host "      And it looks out for you the whole way. Built-in helpers watch for the" -ForegroundColor $cCyan
    Write-Host "      risky moves, a safety check looks for ways a change could go wrong, and" -ForegroundColor $cCyan
    Write-Host "      nothing important is deleted or shipped without a clear yes from you." -ForegroundColor $cCyan
    Write-Host "      You always have the final say." -ForegroundColor $cCyan
    Write-Host ""
    Write-Host "      Why both? Picture your project as a workshop. Eidolon gets the workshop" -ForegroundColor $cCyan
    Write-Host "      ready, so Claude knows where everything is and works safely in it." -ForegroundColor $cCyan
    Write-Host "      Setup is how you settle in for a good session once you are inside. One" -ForegroundColor $cCyan
    Write-Host "      makes the place ready, the other makes the visit go well, and they can" -ForegroundColor $cCyan
    Write-Host "      hand off to each other so they run as a pair." -ForegroundColor $cCyan
    Pause-Soft
    Write-Host ""
    Write-Host "    One gentle thing Setup will ask, the first time you work:" -ForegroundColor $cWarm
    Write-Host ""
    Write-Host '      "People come to this at all different levels, and there is no wrong answer.' -ForegroundColor $cCyan
    Write-Host '       How familiar are you with coding and engineering?"' -ForegroundColor $cCyan
    Write-Host "         new to this            some familiarity" -ForegroundColor $cSoft
    Write-Host "         comfortable, I code    expert" -ForegroundColor $cSoft
    Write-Host ""
    Write-Host "      There is no wrong answer, and you can change it any time. It just lets" -ForegroundColor $cCyan
    Write-Host "      Claude meet you where you are: plainly if that helps, or quickly if you" -ForegroundColor $cCyan
    Write-Host "      would rather move fast." -ForegroundColor $cCyan
    Write-Host ""
    Pause-Soft
}

# ----------------------------------------------------------------------------
# Show-Card: the five W's and How card for an outside tool.
# ----------------------------------------------------------------------------
function Show-Card {
    param(
        [string]$name,
        [string]$what,
        [string]$why,
        [string]$who,
        [string]$wherefrom,
        [string]$when,
        [string]$how
    )
    Write-Host ""
    Draw-BoxTop
    Draw-BoxLine -text $name -color $cWarm
    Draw-BoxDiv
    Draw-CardRow -label "What:  " -value $what
    Draw-CardRow -label "Why:   " -value $why
    Draw-CardRow -label "Who:   " -value $who
    Draw-CardRow -label "Where: " -value $wherefrom
    Draw-CardRow -label "When:  " -value $when
    Draw-CardRow -label "How:   " -value $how
    Draw-BoxBottom
    Write-Host ""
}

# ----------------------------------------------------------------------------
# Ask-YNL: asks a question, returns 'yes', 'no', or 'later'.
# Accepts y, n, l and the full words, in any case. Re-asks gently if unclear.
# ----------------------------------------------------------------------------
function Ask-YNL {
    param([string]$question)
    while ($true) {
        Write-Host ""
        Write-Host "    $question" -ForegroundColor $cWarm
        Write-Host "    Type yes, no, or later, then press Enter." -ForegroundColor $cSoft
        $answer = ''
        try { $answer = Read-Host "    your answer" } catch { $answer = '' }
        $a = ($answer + '').Trim().ToLower()
        if ($a -eq 'y' -or $a -eq 'yes') { return 'yes' }
        if ($a -eq 'n' -or $a -eq 'no')  { return 'no' }
        if ($a -eq 'l' -or $a -eq 'later' -or $a -eq 'maybe later' -or $a -eq 'maybe') { return 'later' }
        Write-Host ""
        Write-Host "    No worries. I did not quite catch that, so let us try once more." -ForegroundColor $cCyan
        Write-Host "    You can type yes, no, or later. Nothing happens until you choose." -ForegroundColor $cCyan
    }
}

# ----------------------------------------------------------------------------
# Start-Breathing helpers.
# A calm box breathing square that fills on a four count while real work runs.
# It only animates while actual work is happening.
# ----------------------------------------------------------------------------
# Draws one line of the breathing square: a small four-cell box that fills and
# empties on the count, so the wait feels like a calm breath rather than a stall.
function Show-BreathLine {
    param([string]$phase, [int]$count, [int]$n)
    $bar = ''
    for ($i = 1; $i -le 4; $i++) {
        if ($i -le $n) { $bar += $g.Fill } else { $bar += $g.Empty }
    }
    Write-Host ("`r    {0,-12} {1,2}   [{2}] " -f $phase, $count, $bar) -NoNewline -ForegroundColor $cCyan
}

function Invoke-WithBreathing {
    # Runs a script block of real install work as a background job, and breathes
    # while it runs. Returns the job's exit code (0 means the command was happy).
    # If background jobs are not available, it breathes a few calm lines, then
    # runs the work right here instead.
    param(
        [scriptblock]$work,
        [string]$workingDir = $null
    )

    $job = $null
    try {
        if ($null -ne $workingDir -and $workingDir -ne '') {
            $job = Start-Job -ScriptBlock {
                param($wd, $inner)
                Set-Location $wd
                & ([scriptblock]::Create($inner))
                $global:LASTEXITCODE
            } -ArgumentList $workingDir, $work.ToString()
        } else {
            $job = Start-Job -ScriptBlock {
                param($inner)
                & ([scriptblock]::Create($inner))
                $global:LASTEXITCODE
            } -ArgumentList $work.ToString()
        }
    } catch {
        $job = $null
    }

    if ($null -eq $job) {
        # Gentle fallback: a few calm breaths, then run the work right here.
        Write-Host "    Let us take a few slow breaths together while this runs." -ForegroundColor $cCyan
        foreach ($p in @('Breathe in', 'Hold', 'Breathe out', 'Hold')) {
            Write-Host "    $p ..." -ForegroundColor $cCyan
            Pause-Soft 600
        }
        Write-Host ""
        $code = 0
        try {
            & $work
            $code = $LASTEXITCODE
            if ($null -eq $code) { $code = 0 }
        } catch {
            $code = 1
        }
        return $code
    }

    # The four phases of box breathing. Each lasts four gentle counts.
    $phases = @(
        @{ name = 'Breathe in'; fill = $true },
        @{ name = 'Hold';       fill = $false; full = $true },
        @{ name = 'Breathe out'; fill = $false; empty = $true },
        @{ name = 'Hold';       fill = $false; full = $false }
    )

    Write-Host "    Box breathing while this finishes. Follow the count if you like." -ForegroundColor $cSoft
    Write-Host ""

    $blocks = 4
    while ($job.State -eq 'Running') {
        foreach ($phase in $phases) {
            if ($job.State -ne 'Running') { break }
            for ($i = 1; $i -le $blocks; $i++) {
                if ($phase.fill) {
                    $n = $i
                } elseif ($phase.full) {
                    $n = $blocks
                } elseif ($phase.empty) {
                    $n = $blocks - $i
                } else {
                    $n = 0
                }
                Show-BreathLine -phase $phase.name -count $i -n $n
                Pause-Soft 700
                if ($job.State -ne 'Running') { break }
            }
        }
    }
    Write-Host ""

    # Collect the result. The exit code we returned from the block is the second signal.
    $code = 1
    try {
        $out = Receive-Job -Job $job -ErrorAction SilentlyContinue
        if ($out) {
            $last = @($out)[-1]
            if ($last -is [int]) { $code = $last } else { $code = 0 }
        } else {
            $code = 0
        }
    } catch {
        $code = 1
    } finally {
        try { Remove-Job -Job $job -Force -ErrorAction SilentlyContinue } catch {}
    }
    return $code
}

# ----------------------------------------------------------------------------
# Test-Have: returns true if a command exists on this machine.
# ----------------------------------------------------------------------------
function Test-Have {
    param([string]$cmd)
    try {
        $null = Get-Command $cmd -ErrorAction SilentlyContinue
        return [bool]($null -ne (Get-Command $cmd -ErrorAction SilentlyContinue))
    } catch {
        return $false
    }
}

# ----------------------------------------------------------------------------
# Install-Skills: copy every file under skills\ into ~/.claude/skills.
# Written UTF-8 without a BOM, with LF line endings, to match the originals.
# This is the instant win. No questions asked.
# ----------------------------------------------------------------------------
function Install-Skills {
    Write-Host ""
    Write-Host "    First, a gift that is already yours." -ForegroundColor $cWarm
    Write-Host "    These two skills were made for you, so they go in right away." -ForegroundColor $cCyan
    Write-Host ""

    $src = Join-Path $root 'skills'
    $dest = Join-Path $env:USERPROFILE '.claude\skills'

    if (-not (Test-Path $src)) {
        Write-Host "    The skills folder is not here beside me yet." -ForegroundColor $cCyan
        Write-Host "    Here is the one thing to try: make sure the whole Hearth folder stayed together." -ForegroundColor $cCyan
        Write-Host "    You have not broken anything. We can keep going." -ForegroundColor $cCyan
        return
    }

    try {
        if (-not (Test-Path $dest)) {
            New-Item -ItemType Directory -Path $dest -Force | Out-Null
        }
    } catch {
        Write-Host "    I could not open your skills home just now." -ForegroundColor $cCyan
        Write-Host "    Here is the one thing to try: run this again in a moment. You have not broken anything." -ForegroundColor $cCyan
        return
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $files = @()
    try {
        $files = Get-ChildItem -Path $src -Recurse -File
    } catch {
        $files = @()
    }

    if ($files.Count -eq 0) {
        Write-Host "    The skills folder is here, but it looks empty for now." -ForegroundColor $cCyan
        Write-Host "    You have not broken anything. We can keep going." -ForegroundColor $cCyan
        return
    }

    foreach ($file in $files) {
        try {
            # Keep the same folder shape inside ~/.claude/skills.
            $relative = $file.FullName.Substring($src.Length).TrimStart('\', '/')
            $target = Join-Path $dest $relative
            $targetDir = Split-Path -Parent $target
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            # Read the text, switch line endings to LF, write with no BOM.
            $text = [System.IO.File]::ReadAllText($file.FullName)
            $text = $text -replace "`r`n", "`n"
            $text = $text -replace "`r", "`n"
            [System.IO.File]::WriteAllText($target, $text, $utf8NoBom)
            Write-Host ("    {0}  {1}" -f $g.Check, $relative) -ForegroundColor $cGreen
            Pause-Soft 120
        } catch {
            Write-Host ("    One file did not copy: {0}" -f $file.Name) -ForegroundColor $cCyan
            Write-Host "    Here is the one thing to try: run this again. You have not broken anything." -ForegroundColor $cCyan
        }
    }

    Write-Host ""
    Write-Host "    Done. Setup and Eidolon are in place." -ForegroundColor $cGreen
    Write-Host "    That is your first win, and it took only a few seconds." -ForegroundColor $cCyan
    Write-Host ""
}

# ----------------------------------------------------------------------------
# Ensure-Runtime: check and instruct only. Never installs system tooling itself.
# Returns 'ready' if the runtime is here, or 'stopped' if it is missing
# (after gently showing the one official command to install it).
# ----------------------------------------------------------------------------
function Ensure-Runtime {
    param([string]$which)  # 'uv' or 'python'

    if ($which -eq 'uv') {
        if (Test-Have 'uv') {
            Write-Host "    Good. uv is already here, so we are ready." -ForegroundColor $cGreen
            return 'ready'
        }
        Write-Host ""
        Write-Host "    This tool leans on a small helper called uv, by a team named Astral." -ForegroundColor $cCyan
        Write-Host "    uv is a fast, friendly installer for Python tools. It also brings Python along." -ForegroundColor $cCyan
        Write-Host "    It is not on your computer yet, and I will not install it for you without asking." -ForegroundColor $cCyan
        Write-Host ""
        Write-Host "    Here is the one official command to add it. You can copy and run it yourself:" -ForegroundColor $cWarm
        Write-Host ""
        Write-Host "        winget install --id=astral-sh.uv -e" -ForegroundColor $cGreen
        Write-Host ""
        # Alternative, mentioned plainly as a comment, but winget is preferred.
        # There is also a one-line installer described at https://astral.sh/uv
        Write-Host "    (There is also a one-line installer at https://astral.sh/uv, but winget is the calm choice.)" -ForegroundColor $cSoft
        Write-Host "    When uv is in, you can run Hearth again and pick this tool. You have not broken anything." -ForegroundColor $cCyan
        return 'stopped'
    }

    if ($which -eq 'python') {
        if ((Test-Have 'python') -or (Test-Have 'py')) {
            Write-Host "    Good. Python is already here, so we are ready." -ForegroundColor $cGreen
            return 'ready'
        }
        # uv supplies Python, so if uv is present we are also fine.
        if (Test-Have 'uv') {
            Write-Host "    Good. uv is here, and uv supplies Python, so we are ready." -ForegroundColor $cGreen
            return 'ready'
        }
        Write-Host ""
        Write-Host "    This tool needs Python, the language it is written in." -ForegroundColor $cCyan
        Write-Host "    It is not on your computer yet, and I will not install it for you without asking." -ForegroundColor $cCyan
        Write-Host ""
        Write-Host "    Here is the one official command to add it. You can copy and run it yourself:" -ForegroundColor $cWarm
        Write-Host ""
        Write-Host "        winget install --id=Python.Python.3.13 -e" -ForegroundColor $cGreen
        Write-Host ""
        Write-Host "    (uv, the helper from the other tool, also brings Python with it, if you prefer that route.)" -ForegroundColor $cSoft
        Write-Host "    When Python is in, you can run Hearth again and pick this tool. You have not broken anything." -ForegroundColor $cCyan
        return 'stopped'
    }

    return 'stopped'
}

# ----------------------------------------------------------------------------
# Offer-Tool: show the card, ask yes/no/later, and on yes ensure the runtime
# and run the official install with box breathing during the wait.
# $steps is a list of script blocks, the real install commands, run in order.
# $verifyCmd is the second signal we check afterward to be sure it landed.
# ----------------------------------------------------------------------------
function Offer-Tool {
    param(
        [hashtable]$card,
        [string]$runtime,        # 'uv', 'python', or '' for none
        [scriptblock[]]$steps,
        [string]$verifyCmd,
        [string]$workingDir = $null
    )

    Show-Card -name $card.name -what $card.what -why $card.why -who $card.who `
              -wherefrom $card.wherefrom -when $card.when -how $card.how

    $choice = Ask-YNL "Want this set up?"

    if ($choice -eq 'no') {
        Write-Host ""
        Write-Host "    That is perfectly fine. We will leave it for now and move on." -ForegroundColor $cCyan
        return
    }
    if ($choice -eq 'later') {
        Write-Host ""
        Write-Host "    Good choice to wait. It will be here whenever you are ready." -ForegroundColor $cCyan
        Write-Host "    You can run Hearth again any time and pick it then." -ForegroundColor $cCyan
        return
    }

    # choice is yes.
    if ($runtime -ne '') {
        $state = Ensure-Runtime $runtime
        if ($state -ne 'ready') {
            # The runtime is missing. We have shown the command and we stop here gently.
            return
        }
    }

    Write-Host ""
    Write-Host "    Wonderful. Let us set it up. This part does real work, so breathe with me." -ForegroundColor $cWarm
    Write-Host ""

    $allGood = $true
    foreach ($step in $steps) {
        $code = Invoke-WithBreathing -work $step -workingDir $workingDir
        if ($null -eq $code) { $code = 0 }
        if ($code -ne 0) { $allGood = $false; break }
    }

    # Second signal: confirm the tool is really here, not just a happy exit code.
    $landed = $false
    if ($verifyCmd -ne '') {
        $landed = Test-Have $verifyCmd
    } else {
        $landed = $allGood
    }

    Write-Host ""
    if ($allGood -and $landed) {
        Write-Host ("    {0}  {1} is set up and ready." -f $g.Check, $card.name) -ForegroundColor $cGreen
        Write-Host "    Nicely done. That is another piece in place." -ForegroundColor $cCyan
    } else {
        Write-Host ("    {0} did not finish going in this time." -f $card.name) -ForegroundColor $cCyan
        Write-Host "    Here is the one thing to try: run Hearth again and choose it once more." -ForegroundColor $cCyan
        Write-Host "    Sometimes a tool just needs a second pass. You have not broken anything." -ForegroundColor $cCyan
    }
    Write-Host ""
}

# ============================================================================
# The flow.
# ============================================================================

try { Clear-Host } catch {}

# 1. Header and a warm greeting.
Show-Header

Write-Host "    Hello, and welcome. Take a breath. You are in the right place." -ForegroundColor $cCyan
Pause-Soft
Write-Host ""
Write-Host "    Here is the shape of what happens next, so nothing is a surprise:" -ForegroundColor $cCyan
Write-Host ""
Write-Host "      $($g.Bullet) You are safe here. Nothing happens without your yes." -ForegroundColor $cCyan
Write-Host "      $($g.Bullet) You can close this window any time you like." -ForegroundColor $cCyan
Write-Host "      $($g.Bullet) This cannot harm your computer." -ForegroundColor $cCyan
Write-Host "      $($g.Bullet) Every step tells you what just happened and what comes next." -ForegroundColor $cCyan
Pause-Soft
Write-Host ""
Write-Host "    We start with a small gift, then I introduce a couple of helpers." -ForegroundColor $cCyan
Write-Host "    For each helper you can say yes, no, or later. You are in control the whole time." -ForegroundColor $cCyan

Show-Skills-Intro

Write-Host ""
try { $null = Read-Host "    Press Enter when you are ready" } catch {}

Draw-Divider

# 2. Instant win: install Setup and Eidolon.
Install-Skills

# 3. graphify, offered one at a time.
$graphifyCard = @{
    name      = 'graphify'
    what      = 'It turns a folder of work into a clear map you can explore.'
    why       = 'When your project grows, this helps you and Claude see how the pieces connect.'
    who       = 'Made by Safi Shamsi. His work is at https://github.com/safishamsi/graphify (MIT license).'
    wherefrom = 'Installed from its official package, named graphifyy, the same one the maker publishes.'
    when      = 'Reach for it when you want a birds eye view of a project folder.'
    how       = 'If you say yes: I run pip install graphifyy, then graphify install, in this Hearth folder.'
}
# graphify needs Python and pip. The exact install steps come straight from the task.
$graphifySteps = @(
    { pip install graphifyy },
    { graphify install . }
)
Offer-Tool -card $graphifyCard -runtime 'python' -steps $graphifySteps -verifyCmd 'graphify' -workingDir $root

# 4. mempalace, offered one at a time.
$mempalaceCard = @{
    name      = 'mempalace'
    what      = 'It gives Claude a searchable memory, so it can recall what you worked on before.'
    why       = 'Instead of repeating yourself each session, Claude can look things up and stay on the same page.'
    who       = 'Lead author igorls, with the Claude plugin published by milla-jovovich. https://github.com/MemPalace/mempalace (MIT license).'
    wherefrom = 'Installed from its official package using uv, the helper from Astral.'
    when      = 'Reach for it when you want Claude to remember context across days and projects.'
    how       = 'If you say yes: I run uv tool install mempalace, then mempalace init, then register its memory with Claude cleanly.'
}
# mempalace needs uv. The exact steps, including the clean MCP registration, come from the task.
# We register the memory server through the supported command, never by hand-editing config.
$mempalaceSteps = @(
    { uv tool install mempalace },
    { mempalace init },
    { claude mcp add mempalace -- mempalace-mcp }
)
Offer-Tool -card $mempalaceCard -runtime 'uv' -steps $mempalaceSteps -verifyCmd 'mempalace' -workingDir $null

# 5. Warm send-off.
Draw-Divider
Write-Host ""
Draw-BoxTop
Draw-BoxCenter -text "You did it." -color $cGreen
Draw-BoxBottom
Write-Host ""
Write-Host "    Here is what you now have:" -ForegroundColor $cWarm
Write-Host ""
Write-Host "      $($g.Bullet) Setup and Eidolon, your two skills, ready in Claude." -ForegroundColor $cCyan
Write-Host "      $($g.Bullet) Any helpers you said yes to, installed from their own makers." -ForegroundColor $cCyan
Write-Host ""
Write-Host "    How to use your new skills:" -ForegroundColor $cWarm
Write-Host ""
Write-Host "      Open Claude Code, and type a single slash, the / key." -ForegroundColor $cCyan
Write-Host "      A list of your skills appears. Pick one and follow along." -ForegroundColor $cCyan
Write-Host ""
Write-Host "    If you ever feel unsure, help is close by:" -ForegroundColor $cWarm
Write-Host ""
Write-Host "      READ ME FIRST.txt has the calm, printable version of all of this." -ForegroundColor $cCyan
Write-Host "      CREDITS.md names everyone whose work made Hearth possible." -ForegroundColor $cCyan
Write-Host ""

# 6. A short on-screen thank-you. Addy Osmani first.
Write-Host "    With thanks." -ForegroundColor $cWarm
Write-Host ""
Write-Host "      Addy Osmani, first and foremost. He built the agent-skills harness" -ForegroundColor $cCyan
Write-Host "      that this whole pattern grows from. The idea starts with his work." -ForegroundColor $cCyan
Write-Host ""
Write-Host "      And the makers of the tools Hearth points to, each from their own hands." -ForegroundColor $cCyan
Write-Host "      The full gallery, with everyone named and linked, is in CREDITS.md." -ForegroundColor $cCyan
Write-Host ""
Write-Host "    Thank you for being here. Be gentle with yourself. You did well." -ForegroundColor $cGreen
Write-Host ""
try { $null = Read-Host "    Press Enter to close" } catch {}
