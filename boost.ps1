# =========================================================
# RANK1 INSTALLER v3.0 - EXTREME PC BOOST (PURE POWERSHELL)
# =========================================================

# Check Admin Rights automatically
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

[Console]::Clear()
$Host.UI.RawUI.WindowTitle = "RANK1 INSTALLER v3.0 - EXTREME PC BOOST (ADMIN)"
[Console]::CursorVisible = $false

$HeaderColor = "Red"
$SubHeaderColor = "DarkGray"
$NormalColor = "White"
$SelectColor = "DarkRed"
$SelectBG = "White"

$options = @("INSTALL BOOST V3", "UNINSTALL BOOST", "EXIT")
$selectedIndex = 0

function Action-Install {
    [Console]::Clear()
    Write-Host "==========================================" -ForegroundColor $HeaderColor
    Write-Host "        INSTALLING EXTREME BOOST...       " -ForegroundColor $HeaderColor
    Write-Host "==========================================" -ForegroundColor $HeaderColor
    Write-Host ""
    
    Write-Host " [10%] Applying High Performance & CPU Priority..." -ForegroundColor Cyan
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force
    Start-Sleep -Milliseconds 300

    Write-Host " [20%] Optimizing MMCSS & Network Throttling..." -ForegroundColor Cyan
    $SysProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    Set-ItemProperty -Path $SysProfile -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force
    Set-ItemProperty -Path $SysProfile -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
    Start-Sleep -Milliseconds 300

    Write-Host " [30%] Lowering Network Latency (Disable Nagle's)..." -ForegroundColor Cyan
    $Interfaces = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' -ErrorAction SilentlyContinue
    foreach ($Interface in$Interfaces) {
        Set-ItemProperty -Path $Interface.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $Interface.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force
    }
    Start-Sleep -Milliseconds 300

    Write-Host " [40%] Optimizing Mouse Input (Raw Input)..." -ForegroundColor Cyan
    $MousePath = "HKCU:\Control Panel\Mouse"
    Set-ItemProperty -Path $MousePath -Name "MouseSpeed" -Value "0" -Force
    Set-ItemProperty -Path $MousePath -Name "MouseThreshold1" -Value "0" -Force
    Set-ItemProperty -Path $MousePath -Name "MouseThreshold2" -Value "0" -Force
    Start-Sleep -Milliseconds 300

    Write-Host " [50%] Disabling Telemetry & Game DVR overhead..." -ForegroundColor Cyan
    $GameDVR = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    if (!(Test-Path $GameDVR)) { New-Item -Path$GameDVR -Force | Out-Null }
    Set-ItemProperty -Path $GameDVR -Name "AllowGameDVR" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force
    $Telemetry = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (!(Test-Path $Telemetry)) { New-Item -Path$Telemetry -Force | Out-Null }
    Set-ItemProperty -Path $Telemetry -Name "AllowTelemetry" -Value 0 -Type DWord -Force
    Start-Sleep -Milliseconds 300

    Write-Host " [60%] Enabling Game Mode & Stopping Background Apps..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1 -Type DWord -Force
    $BgApps = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (!(Test-Path $BgApps)) { New-Item -Path$BgApps -Force | Out-Null }
    Set-ItemProperty -Path $BgApps -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force
    Start-Sleep -Milliseconds 300

    Write-Host " [70%] Detecting & Optimizing GPU..." -ForegroundColor Cyan
    $GPUs = Get-CimInstance Win32_VideoController \vert{} Select-Object -ExpandProperty Name$GraphicsDrivers = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    if (!(Test-Path $GraphicsDrivers)) { New-Item -Path$GraphicsDrivers -Force | Out-Null }
    Set-ItemProperty -Path $GraphicsDrivers -Name "HwSchMode" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue

    foreach ($GPU in$GPUs) {
        Write-Host "       -> Found: $GPU" -ForegroundColor DarkGray
        if ($GPU -match "NVIDIA") {
            Stop-Service -Name "NvTelemetryContainer" -Force -ErrorAction SilentlyContinue
            Set-Service -Name "NvTelemetryContainer" -StartupType Disabled -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:LOCALAPPDATA\NVIDIA\ComputeCache\*" -Recurse -Force -ErrorAction SilentlyContinue
        } elseif ($GPU -match "AMD" -or $GPU -match "Radeon") {
            Stop-Service -Name "AMDCrashDefenderService" -Force -ErrorAction SilentlyContinue
            Set-Service -Name "AMDCrashDefenderService" -StartupType Disabled -ErrorAction SilentlyContinue
            Stop-Service -Name "AMD External Events Utility" -Force -ErrorAction SilentlyContinue
            Set-Service -Name "AMD External Events Utility" -StartupType Disabled -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:LOCALAPPDATA\AMD\DxCache\*" -Recurse -Force -ErrorAction SilentlyContinue
        } elseif ($GPU -match "Intel") {
            Stop-Service -Name "Intel(R) System Usage Report Service" -Force -ErrorAction SilentlyContinue
            Set-Service -Name "Intel(R) System Usage Report Service" -StartupType Disabled -ErrorAction SilentlyContinue
        }
    }
    Remove-Item -Path "$env:LOCALAPPDATA\D3DSCache\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500

    Write-Host " [80%] Optimizing System Services (SysMain)..." -ForegroundColor Cyan
    Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 300

    Write-Host " [90%] Tweaking Kernel Timers (Reducing Input Lag)..." -ForegroundColor Cyan
    bcdedit /set disabledynamictick yes | Out-Null
    bcdedit /deletevalue useplatformclock 2>$null | Out-Null
    Start-Sleep -Milliseconds 300

    Write-Host " [100%] Freeing Disk Space, Clearing Temp & Flushing DNS..." -ForegroundColor Cyan
    powercfg -h off | Out-Null
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:WINDIR\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:WINDIR\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
    ipconfig /flushdns | Out-Null
    Start-Sleep -Milliseconds 400

    Write-Host ""
    Write-Host " [!] EXTREME PC BOOST V3 INSTALL COMPLETE" -ForegroundColor Green
    Write-Host " (Please restart your PC for some tweaks to fully apply)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to return to menu..." -ForegroundColor DarkGray
    $null =$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Action-Uninstall {
    [Console]::Clear()
    Write-Host "==========================================" -ForegroundColor $HeaderColor
    Write-Host "            UNINSTALLING BOOST...         " -ForegroundColor $HeaderColor
    Write-Host "==========================================" -ForegroundColor $HeaderColor
    Write-Host ""
    
    Write-Host " Removing configuration and reverting to Windows Defaults..." -ForegroundColor Yellow
    
    Write-Host " -> Reverting Power Plan & CPU Priority" -ForegroundColor DarkGray
    powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 2 -Type DWord -Force

    Write-Host " -> Reverting Network & System Responsiveness" -ForegroundColor DarkGray
    $SysProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    Set-ItemProperty -Path $SysProfile -Name "NetworkThrottlingIndex" -Value 10 -Type DWord -Force
    Set-ItemProperty -Path $SysProfile -Name "SystemResponsiveness" -Value 20 -Type DWord -Force

    Write-Host " -> Reverting Network Latency Settings" -ForegroundColor DarkGray
    $Interfaces = Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' -ErrorAction SilentlyContinue
    foreach ($Interface in$Interfaces) {
        Remove-ItemProperty -Path $Interface.PSPath -Name "TcpAckFrequency" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $Interface.PSPath -Name "TCPNoDelay" -ErrorAction SilentlyContinue
    }

    Write-Host " -> Restoring Mouse Acceleration Default" -ForegroundColor DarkGray
    $MousePath = "HKCU:\Control Panel\Mouse"
    Set-ItemProperty -Path $MousePath -Name "MouseSpeed" -Value "1" -Force
    Set-ItemProperty -Path $MousePath -Name "MouseThreshold1" -Value "6" -Force
    Set-ItemProperty -Path $MousePath -Name "MouseThreshold2" -Value "10" -Force

    Write-Host " -> Restoring Game DVR & Telemetry settings" -ForegroundColor DarkGray
    $GameDVR = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    Set-ItemProperty -Path $GameDVR -Name "AllowGameDVR" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 1 -Type DWord -Force
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue

    Write-Host " -> Restoring Background Apps & Game Mode Defaults" -ForegroundColor DarkGray
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -ErrorAction SilentlyContinue

    Write-Host " -> Reverting GPU Optimizations (HAGS & Services)" -ForegroundColor DarkGray
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-Service -Name "NvTelemetryContainer" -StartupType Automatic -ErrorAction SilentlyContinue
    Set-Service -Name "AMDCrashDefenderService" -StartupType Automatic -ErrorAction SilentlyContinue
    Set-Service -Name "AMD External Events Utility" -StartupType Automatic -ErrorAction SilentlyContinue
    Set-Service -Name "Intel(R) System Usage Report Service" -StartupType Automatic -ErrorAction SilentlyContinue

    Write-Host " -> Reverting System Services (SysMain)" -ForegroundColor DarkGray
    Set-Service -Name "SysMain" -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Service -Name "SysMain" -ErrorAction SilentlyContinue

    Write-Host " -> Reverting Kernel Timers & Hibernation" -ForegroundColor DarkGray
    bcdedit /deletevalue disabledynamictick 2>$null | Out-Null
    powercfg -h on | Out-Null

    Start-Sleep -Seconds 2

    Write-Host ""
    Write-Host " [!] UNINSTALL COMPLETE" -ForegroundColor Green
    Write-Host " (Please restart your PC for all default settings to restore)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to return to menu..." -ForegroundColor DarkGray
    $null =$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Draw-Header {
    [Console]::Clear()
    Write-Host @"
  ____     _    _   _ _  _______ 
 |  _ \   / \  | \ | | |/ /___  |
 | |_) | / _ \ |  \| | ' /   / / 
 |  _ < / ___ \| |\  | . \  / /  
 |_| \_/_/   \_\_| \_|_|\_\/_/   
"@ -ForegroundColor $HeaderColor

    Write-Host "       EXTREME INSTALLER v3.0" -ForegroundColor $SubHeaderColor
    Write-Host "----------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

function Draw-Menu {
    Draw-Header
    for ($i = 0; $i -lt $options.Count; $i++) {
        if ($i -eq$selectedIndex) {
            Write-Host "  > [ $($options[$i]) ]  " -ForegroundColor $SelectColor -BackgroundColor$SelectBG
        } else {
            Write-Host "    $($options[$i])    " -ForegroundColor $NormalColor
        }
    }
    Write-Host ""
    Write-Host "----------------------------------" -ForegroundColor DarkGray
    Write-Host "Use UP/DOWN arrows to select, ENTER to confirm" -ForegroundColor DarkGray
}

$running =$true
while ($running) {
    Draw-Menu
    $key =$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    switch ($key.VirtualKeyCode) {         38 {$selectedIndex--
            if ($selectedIndex -lt 0) {$selectedIndex = $options.Count - 1 }         }         40 {$selectedIndex++
            if ($selectedIndex -ge $options.Count) {$selectedIndex = 0 }
        }
        13 { 
            switch ($selectedIndex) {
                0 { Action-Install }
                1 { Action-Uninstall }
                2 { 
                    $running =$false 
                    [Console]::Clear()
                    Write-Host "Exiting program..." -ForegroundColor Yellow
                    [Console]::CursorVisible = $true
                    Start-Sleep -Milliseconds 500
                }
            }
        }
    }
}
