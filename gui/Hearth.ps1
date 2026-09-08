try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

# Hearth: the graphical installer (Windows).
#
# This is the front door that "Start Here" opens: a real window, no terminal
# typing. If the window cannot run on this machine, it hands off to the text
# installer (welcome.ps1), which does exactly the same work. Plain, visible text,
# no hidden code. Nothing installs without your yes.

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$root = Split-Path -Parent $here

function Invoke-TextFallback {
    # Open the text installer in a normal console window and leave.
    try {
        Start-Process -FilePath 'powershell.exe' `
            -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File', (Join-Path $root 'welcome.ps1')) | Out-Null
    } catch {}
}

# Hide the console window this script launched from (belt and suspenders; the .cmd
# also launches us with -WindowStyle Hidden).
try {
    Add-Type -Name HearthWin -Namespace Hearth -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("kernel32.dll")] public static extern System.IntPtr GetConsoleWindow();
[System.Runtime.InteropServices.DllImport("user32.dll")] public static extern bool ShowWindow(System.IntPtr hWnd, int nCmdShow);
'@ -ErrorAction SilentlyContinue
    $h = [Hearth.HearthWin]::GetConsoleWindow()
    if ($h -ne [System.IntPtr]::Zero) { [void][Hearth.HearthWin]::ShowWindow($h, 0) } # 0 = SW_HIDE
} catch {}

# Load WPF. If this throws, the machine cannot show the window: fall back to text.
try {
    Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
    . (Join-Path $here 'HearthCore.ps1')
    [xml]$xaml = Get-Content -Raw -Path (Join-Path $here 'MainWindow.xaml')
    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $win = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    Invoke-TextFallback
    return
}

# Grab the named elements.
$el = @{}
foreach ($n in @('LogoImage','ScreenWelcome','ScreenSkills','ScreenInstall','ScreenCard','ScreenDone',
                 'SkillsStatus','SkillsProgress','CardName','CardLead','CardWhat','CardWhy','CardWho','CardHow',
                 'CardNotice','DoneList','BtnText','BtnNo','BtnLater','BtnYes','BtnNext','BtnClose')) {
    $el[$n] = $win.FindName($n)
}

# Logo: load from assets, no file lock, fall back silently to the wordmark if absent.
try {
    $logoPath = Join-Path $root 'assets\EidolonLogo.png'
    if (Test-Path $logoPath) {
        $bmp = New-Object System.Windows.Media.Imaging.BitmapImage
        $bmp.BeginInit()
        $bmp.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bmp.UriSource = New-Object System.Uri($logoPath)
        $bmp.EndInit()
        $el.LogoImage.Source = $bmp
    }
} catch {}

# --- flow state ---
$script:tools     = @(Get-HearthTools -Root $root)
$script:toolIndex = 0
$script:installed = @()   # names that went in (Setup/Eidolon always; plus any tool a yes landed)

function Set-Footer {
    param([string[]]$show)
    foreach ($b in @('BtnText','BtnNo','BtnLater','BtnYes','BtnNext','BtnClose')) {
        $el[$b].Visibility = if ($show -contains $b) { 'Visible' } else { 'Collapsed' }
    }
}

function Hide-Screens {
    foreach ($s in @('ScreenWelcome','ScreenSkills','ScreenInstall','ScreenCard','ScreenDone')) {
        $el[$s].Visibility = 'Collapsed'
    }
}

function Render-Now {
    try { $win.Dispatcher.Invoke([action]{}, [System.Windows.Threading.DispatcherPriority]::Render) } catch {}
}

function Show-Welcome {
    Hide-Screens; $el.ScreenWelcome.Visibility = 'Visible'
    $el.BtnNext.Content = 'Begin'
    Set-Footer @('BtnText','BtnNext')
}

function Show-Skills {
    Hide-Screens; $el.ScreenSkills.Visibility = 'Visible'
    $el.BtnNext.Content = 'Set up my skills'
    Set-Footer @('BtnNext')
}

function Run-Install-Skills {
    Hide-Screens; $el.ScreenInstall.Visibility = 'Visible'
    Set-Footer @()   # no buttons during the copy
    $el.SkillsStatus.Text = 'Copying your skills into place...'
    Render-Now
    $result = Install-HearthSkills -Root $root -OnFile {
        param($rel, $i, $total)
        $el.SkillsProgress.Value = [math]::Round(($i / [math]::Max($total,1)) * 100)
        $el.SkillsStatus.Text = "Copying $i of $total"
        Render-Now
    }
    if ($result.ok) {
        $el.SkillsProgress.Value = 100
        $el.SkillsStatus.Text = "Done. Setup and Eidolon are in place ($($result.copied) files)."
        $script:installed = @('Setup', 'Eidolon')
    } else {
        $el.SkillsStatus.Text = "Installation stopped: $($result.error). Use Start Agents for an explicitly backed-up replacement."
    }
    $el.BtnNext.Content = 'Next'
    Set-Footer @('BtnNext')
}

function Show-Card {
    Hide-Screens; $el.ScreenCard.Visibility = 'Visible'
    $t = $script:tools[$script:toolIndex]
    $el.CardName.Text   = $t.name
    $el.CardLead.Text   = 'Optional. Skip it now or forever; nothing is added behind your back.'
    $el.CardWhat.Text   = "What:  $($t.what)"
    $el.CardWhy.Text    = "Why:   $($t.why)`nWhen:  $($t.when)"
    $el.CardWho.Text    = "Who:   $($t.who)`nWhere: $($t.wherefrom)"
    $el.CardHow.Text    = "How:   $($t.how)"
    $el.CardNotice.Visibility = 'Collapsed'
    $el.BtnYes.Content = 'Yes, set it up'
    Set-Footer @('BtnNo','BtnLater','BtnYes')
}

function Advance-Tool {
    $script:toolIndex++
    if ($script:toolIndex -ge $script:tools.Count) { Show-Done } else { Show-Card }
}

function Try-Install-Current-Tool {
    $t = $script:tools[$script:toolIndex]
    if ($t.runtime -ne '') {
        $status = Get-HearthRuntimeStatus $t.runtime
        if (-not $status.ready) {
            $el.CardNotice.Text = "$($status.title)`n$($status.note)`n`nRun this one official command yourself, then come back and pick this tool again:`n    $($status.command)"
            $el.CardNotice.Visibility = 'Visible'
            $el.BtnYes.Content = 'Skip for now'
            Set-Footer @('BtnYes')   # Yes now acts as "move on"
            $script:skipOnly = $true
            return
        }
    }
    # Runtime ready: run the install on a background runspace so the window stays alive.
    $el.CardNotice.Text = "Setting up $($t.name) now. This does real work and can take a minute..."
    $el.CardNotice.Visibility = 'Visible'
    Set-Footer @()
    Render-Now
    Start-ToolInstallAsync $t {
        param($res)
        if ($res.ok) {
            $script:installed += $t.name
            $el.CardNotice.Text = "$($t.name) is set up and ready."
        } else {
            $el.CardNotice.Text = "$($t.name) did not finish this time. You can run Hearth again and choose it once more. You have not broken anything."
        }
        $el.BtnNext.Content = 'Next'
        Set-Footer @('BtnNext')
    }
}

function Start-ToolInstallAsync {
    param([hashtable]$tool, [scriptblock]$onDone)
    $rs = [runspacefactory]::CreateRunspace(); $rs.ApartmentState = 'STA'; $rs.Open()
    $ps = [powershell]::Create(); $ps.Runspace = $rs
    $corePath = Join-Path $here 'HearthCore.ps1'
    [void]$ps.AddScript({ param($c,$t) . $c; Install-HearthTool -Tool $t }).AddArgument($corePath).AddArgument($tool)
    $script:asyncHandle = $ps.BeginInvoke()
    $script:asyncPs = $ps; $script:asyncRs = $rs; $script:asyncDone = $onDone
    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds(250)
    $timer.Add_Tick({
        if ($script:asyncHandle.IsCompleted) {
            $this.Stop()
            $res = @{ ok = $false }
            try { $res = @($script:asyncPs.EndInvoke($script:asyncHandle))[0] } catch {}
            try { $script:asyncPs.Dispose(); $script:asyncRs.Dispose() } catch {}
            & $script:asyncDone $res
        }
    })
    $timer.Start()
}

function Show-Done {
    Hide-Screens; $el.ScreenDone.Visibility = 'Visible'
    $el.DoneList.Children.Clear()
    foreach ($name in $script:installed) {
        $tb = New-Object System.Windows.Controls.TextBlock
        $tb.Text = "  [done]  $name"
        $tb.FontSize = 15; $tb.Margin = '0,0,0,4'
        $tb.Foreground = $win.FindResource('WinGreen')
        [void]$el.DoneList.Children.Add($tb)
    }
    Set-Footer @('BtnClose')
}

# --- wire the buttons ---
$el.BtnText.Add_Click({ Invoke-TextFallback; $win.Close() })
$el.BtnClose.Add_Click({ $win.Close() })

$el.BtnNext.Add_Click({
    if ($el.ScreenWelcome.Visibility -eq 'Visible')      { Show-Skills }
    elseif ($el.ScreenSkills.Visibility -eq 'Visible')   { Run-Install-Skills }
    elseif ($el.ScreenInstall.Visibility -eq 'Visible')  { Show-Card }
    elseif ($el.ScreenCard.Visibility -eq 'Visible')     { Advance-Tool }   # after a finished tool install
})

$el.BtnNo.Add_Click({ Advance-Tool })
$el.BtnLater.Add_Click({ Advance-Tool })
$el.BtnYes.Add_Click({
    if ($script:skipOnly) { $script:skipOnly = $false; Advance-Tool; return }
    Try-Install-Current-Tool
})

# Start on the welcome screen and run.
Show-Welcome
[void]$win.ShowDialog()
