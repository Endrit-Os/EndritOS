# Endrit OS - Family / Safe profile
# Maximum compatibility for a stranger's PC, an older PC, family, school, office.
# Keeps ALL security + Windows Update + search. Only privacy/bloat cleanup + light speed.
$ErrorActionPreference = 'SilentlyContinue'
function Set-Reg($p,$n,$t,$v){ if(!(Test-Path $p)){New-Item -Path $p -Force|Out-Null}; Set-ItemProperty -Path $p -Name $n -Type $t -Value $v -Force -EA SilentlyContinue }

Write-Host "Endrit OS: Applying Family / Safe profile (max compatibility)..." -ForegroundColor Cyan

# Keep security fully on
Set-Service 'WinDefend' -StartupType Automatic -EA SilentlyContinue
Set-Service 'mpssvc'    -StartupType Automatic -EA SilentlyContinue
Set-Service 'BFE'       -StartupType Automatic -EA SilentlyContinue
Set-Service 'wuauserv'  -StartupType Manual    -EA SilentlyContinue
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAutoUpdate' 'DWord' 0  # keep updates
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'SmartScreenEnabled' 'String' 'Warn'

# Keep Search + SysMain running (compatibility)
Set-Service 'WSearch' -StartupType Automatic -EA SilentlyContinue
Set-Service 'SysMain' -StartupType Automatic -EA SilentlyContinue

# Light privacy: telemetry + advertising off (safe for everyone)
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 'DWord' 0
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoAutorun' 'DWord' 1
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 'DWord' 0
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SilentInstalledAppsEnabled' 'DWord' 0

# Light usability: faster menus, no risky tweaks
Set-Reg 'HKCU:\Control Panel\Desktop' 'MenuShowDelay' 'String' '200'

# NO aggressive tweaks: no boot tweaks, no core-park disable, no MSI mode, no Nagle off,
# no svchost merge, mitigations stay ON. Power plan = Balanced.
powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null
# Ensure Nagle/ack are default (no per-interface latency hacks)
Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' -EA SilentlyContinue | ForEach-Object {
    Remove-ItemProperty -Path $_.PSPath -Name 'TcpAckFrequency' -EA SilentlyContinue
    Remove-ItemProperty -Path $_.PSPath -Name 'TCPNoDelay' -EA SilentlyContinue
}

# Keep hibernation (laptops/families like fast resume)
powercfg /hibernate on 2>$null

Write-Host "Endrit OS: Family / Safe profile applied. Security, updates, search all ON." -ForegroundColor Green
Write-Host "  Target: ~99% compatibility - safe for any PC, any user." -ForegroundColor Cyan
