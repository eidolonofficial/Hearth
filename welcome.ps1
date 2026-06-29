try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
$ErrorActionPreference = 'Stop'

# Hearth: set Claude up right, no terminal required.
# This whole file is plain, visible text. There is no hidden code, no base64.
# You can read every line. Nothing runs unless you say yes.
# This is the text installer. The graphical window (gui\Hearth.ps1) is the front
# door; this is the reliable fallback, and it does exactly the same work.
# The real logo lives in assets\EidolonLogo.png. The full thanks list is in CREDITS.md.

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $root 'gui\HearthCore.ps1')

# Palette. Green is a win. Cyan is the voice. Yellow is a heading. Gray is an aside.
$cGreen = 'Green'; $cCyan = 'Cyan'; $cSoft = 'DarkGray'; $cWarm = 'Yellow'

function Line { param([string]$t, [string]$c = $cCyan) Write-Host $t -ForegroundColor $c }

function Show-Header {
    Write-Host ""
    Write-Host "        _   _   _____      _      ____    _____   _   _   " -ForegroundColor $cWarm
    Write-Host "       | | | | | ____|    / \    |  _ \  |_   _| | | | |  " -ForegroundColor $cWarm
    Write-Host "       | |_| | |  _|     / _ \   | |_) |   | |   | |_| |  " -ForegroundColor $cWarm
    Write-Host "       |  _  | | |___   / ___ \  |  _ <    | |   |  _  |  " -ForegroundColor $cWarm
    Write-Host "       |_| |_| |_____| /_/   \_\ |_| \_\   |_|   |_| |_|  " -ForegroundColor $cWarm
    Write-Host ""
    Write-Host "       Give Claude a memory and a backbone." -ForegroundColor $cCyan
    Write-Host "       No terminal. No jargon. You say yes to every step." -ForegroundColor $cSoft
    Write-Host ""
}

function Show-Skills-Intro {
    Write-Host ""
    Line "    Your two skills, and why there are two." $cWarm
    Write-Host ""
    Line "      Setup gets a work session off to a strong start. It asks a few short"
    Line "      questions so Claude works the way you like, then it remembers what worked,"
    Line "      checks its own work before it says 'done,' and learns how you like to work."
    Line "      Setup is about the session: this visit, this stretch of work."
    Write-Host ""
    Line "      Eidolon is about the project itself. Point it at a project folder and it"
    Line "      reads the whole thing, sets up what Claude needs to understand it, and then"
    Line "      carries any change from a plain idea all the way to finished: it plans,"
    Line "      builds one careful piece at a time, checks for safety and mistakes, and"
    Line "      only then puts it in place."
    Write-Host ""
    Line "      It looks out for you the whole way. Guards watch for the risky moves, a"
    Line "      safety review hunts for ways a change could go wrong, and nothing important"
    Line "      ships or gets deleted without a clear yes from you. You always have the"
    Line "      final say."
    Write-Host ""
    Line "      Why both? Picture your project as a workshop. Eidolon gets the workshop"
    Line "      ready, so Claude knows where everything is and works safely in it. Setup is"
    Line "      how you settle in for a good session once you are inside. They hand off to"
    Line "      each other, so they work as a pair."
    Write-Host ""
    Line "    The first time you work, Setup asks one thing:" $cWarm
    Write-Host ""
    Line '      "How familiar are you with coding and engineering?"'
    Line "         new to this            some familiarity" $cSoft
    Line "         comfortable, I code    expert" $cSoft
    Write-Host ""
    Line "      There is no wrong answer, and you can change it any time. It just lets"
    Line "      Claude meet you where you are."
    Write-Host ""
}

function Show-Card {
    param([hashtable]$tool)
    Write-Host ""
    Write-Host "    +----------------------------------------------------------------+" -ForegroundColor $cSoft
    Line "      $($tool.name)" $cWarm
    Write-Host ""
    Line "      What:  $($tool.what)"
    Line "      Why:   $($tool.why)"
    Line "      Who:   $($tool.who)"
    Line "      Where: $($tool.wherefrom)"
    Line "      When:  $($tool.when)"
    Line "      How:   $($tool.how)"
    Write-Host "    +----------------------------------------------------------------+" -ForegroundColor $cSoft
    Write-Host ""
}

function Ask-YNL {
    param([string]$question)
    while ($true) {
        Write-Host ""
        Line "    $question  Type yes, no, or later, then press Enter." $cWarm
        $answer = ''
        try { $answer = Read-Host "    your answer" } catch { $answer = '' }
        $a = ($answer + '').Trim().ToLower()
        if ($a -eq 'y' -or $a -eq 'yes')  { return 'yes' }
        if ($a -eq 'n' -or $a -eq 'no')   { return 'no' }
        if ($a -eq 'l' -or $a -eq 'later' -or $a -eq 'maybe later' -or $a -eq 'maybe') { return 'later' }
        Line "    I did not catch that. yes, no, or later. Nothing happens until you choose."
    }
}

function Run-Install-Skills {
    Write-Host ""
    Line "    First, a gift that is already yours." $cWarm
    Line "    These two skills were made for you, so they go in right away."
    Write-Host ""
    $result = Install-HearthSkills -Root $root -OnFile {
        param($rel, $i, $total)
        Write-Host ("`r    Copying {0,3} of {1,-3}  {2,-44}" -f $i, $total, $rel) -NoNewline -ForegroundColor $cGreen
    }
    Write-Host ""
    if ($result.ok) {
        Write-Host ""
        Line "    Done. Setup and Eidolon are in place ($($result.copied) files)." $cGreen
        Line "    That is your first win, and it took only a few seconds."
    } elseif ($result.error -eq 'skills-folder-missing' -or $result.error -eq 'skills-folder-empty') {
        Line "    The skills folder is not here beside me. Make sure the whole Hearth folder"
        Line "    stayed together, then run this again. You have not broken anything."
    } else {
        Line "    I could not open your skills home just now. Run this again in a moment."
        Line "    You have not broken anything."
    }
    Write-Host ""
}

function Show-Runtime-Stop {
    param([hashtable]$status)
    Write-Host ""
    Line "    $($status.title)"
    Line "    $($status.note)"
    Write-Host ""
    Line "    Here is the one official command. Copy it and run it yourself:" $cWarm
    Write-Host ""
    Line "        $($status.command)" $cGreen
    Write-Host ""
    if ($status.also) { Line "    ($($status.also))" $cSoft }
    Line "    Once it is in, run Hearth again and pick this tool. You have not broken anything."
}

function Run-Offer-Tool {
    param([hashtable]$tool)
    Show-Card $tool
    $choice = Ask-YNL "Want this set up?"
    if ($choice -eq 'no')    { Write-Host ""; Line "    That is fine. We will leave it and move on."; return }
    if ($choice -eq 'later') { Write-Host ""; Line "    Good call. It will be here whenever you are ready. Run Hearth again any time."; return }

    if ($tool.runtime -ne '') {
        $status = Get-HearthRuntimeStatus $tool.runtime
        if (-not $status.ready) { Show-Runtime-Stop $status; return }
    }

    Write-Host ""
    Line "    Setting it up now. This does real work and can take a minute." $cWarm
    $result = Install-HearthTool -Tool $tool -OnStep {
        param($step)
        Line "    Running: $step" $cSoft
    }
    Write-Host ""
    if ($result.ok) {
        Line "    [ok]  $($tool.name) is set up and ready." $cGreen
        Line "    Nicely done. Another piece in place."
    } else {
        Line "    $($tool.name) did not finish this time. Run Hearth again and choose it once more."
        Line "    Sometimes a tool needs a second pass. You have not broken anything."
    }
    Write-Host ""
}

# ============================================================================
# The flow.
# ============================================================================

try { Clear-Host } catch {}
Show-Header

Line "    Hello, and welcome. You are in the right place."
Write-Host ""
Line "    Here is the shape of what happens next, so nothing is a surprise:"
Write-Host ""
Line "      You are safe here. Nothing happens without your yes."
Line "      Close this window any time you like."
Line "      This cannot harm your computer."
Line "      Every step says what just happened and what comes next."
Write-Host ""
Line "    We start with a quick win, then I introduce two optional helpers."
Line "    For each one you can say yes, no, or later. You are in control the whole time."

Show-Skills-Intro

Write-Host ""
try { $null = Read-Host "    Press Enter when you are ready" } catch {}

Run-Install-Skills

foreach ($tool in (Get-HearthTools -Root $root)) { Run-Offer-Tool $tool }

# Send-off.
Write-Host ""
Write-Host "    +----------------------------------------------------+" -ForegroundColor $cSoft
Write-Host "    |                  You did it.                       |" -ForegroundColor $cGreen
Write-Host "    +----------------------------------------------------+" -ForegroundColor $cSoft
Write-Host ""
Line "    Here is what you now have:" $cWarm
Write-Host ""
Line "      Setup and Eidolon, your two skills, ready in Claude."
Line "      Any helpers you said yes to, installed from their own makers."
Write-Host ""
Line "    How to use them:" $cWarm
Write-Host ""
Line "      Open Claude Code and type a single slash, the / key."
Line "      Your skills appear in the list. Pick one and follow along."
Write-Host ""
Line "    If you ever feel unsure:" $cWarm
Write-Host ""
Line "      READ ME FIRST.txt has the printable version of all of this."
Line "      CREDITS.md names everyone whose work made Hearth possible."
Write-Host ""
Line "    With thanks." $cWarm
Write-Host ""
Line "      Addy Osmani, first of all. He built the agent-skills harness this whole"
Line "      pattern grows from. The idea starts with his work."
Line "      And the makers of the tools Hearth points to, each from their own hands."
Line "      The full gallery, with everyone named and linked, is in CREDITS.md."
Write-Host ""
Line "    Thank you for being here. You did well." $cGreen
Write-Host ""
try { $null = Read-Host "    Press Enter to close" } catch {}
