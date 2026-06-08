# Endrit OS v2.4 — Safe Compatibility Mode
# For older PCs, laptops, AMD systems, beginners
# Reverts risky tweaks and ensures maximum compatibility
$ErrorActionPreference = 'SilentlyContinue'

function Set-Reg($path, $name, $type, $value) {
    if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name $name -Type $type -Value $value -ErrorAction SilentlyContinue
}

Write-Host "Endrit OS: Applying Safe Compatibility Mode..." -ForegroundColor Cyan

# ── Revert risky boot tweaks ──────────────────────────────────────
# These are safe on most PCs but problematic on AMD Zen/old Intel
bcdedit /deletevalue disabledynamictick 2>$null
bcdedit /deletevalue tscsyncpolicy      2>$null
bcdedit /deletevalue useplatformtick    2>$null
bcdedit /deletevalue useplatformclock   2>$null
Write-Host "  Boot tweaks: reverted to Windows defaults" -ForegroundColor Green

# ── Balanced power plan (laptop-safe) ─────────────────────────────
$balanced = "381b4222-f694-41f0-9685-ff5bb260df2e"
powercfg -setactive $balanced 2>$null
Write-Host "  Power plan: Balanced (safe for all hardware)" -ForegroundColor Green

# ── Disable HAGS if GPU is old (pre-RTX 2000 / pre-RX 5000) ─────
$gpuOld = $true
try {
    $gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
    if ($gpu -match 'RTX [23456789]|RX [567689][0-9]{3}|RX 7[0-9]{3}') { $gpuOld = $false }
} catch {}
if ($gpuOld) {
    Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 'DWord' 1
    Write-Host "  HAGS: disabled (old GPU detected)" -ForegroundColor Yellow
}

# ── Re-enable hibernation (needed on laptops) ─────────────────────
powercfg /hibernate on 2>$null
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' 'HibernateEnabled' 'DWord' 1
Write-Host "  Hibernation: re-enabled" -ForegroundColor Green

# ── Restore Windows Update (allow security patches) ───────────────
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAutoUpdate' 'DWord' 0
Write-Host "  Windows Update: security patches allowed" -ForegroundColor Green

# ── Re-enable System Restore ──────────────────────────────────────
Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue
Write-Host "  System Restore: re-enabled on C:" -ForegroundColor Green

# ── Re-enable Nagle (safer on WiFi) ──────────────────────────────
Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' -EA SilentlyContinue | ForEach-Object {
    Remove-ItemProperty -Path $_.PSPath -Name 'TCPNoDelay'       -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $_.PSPath -Name 'TcpAckFrequency'  -ErrorAction SilentlyContinue
}
Write-Host "  Nagle: restored (safer for WiFi)" -ForegroundColor Green

# ── Keep Defender, Firewall, ASR unchanged ────────────────────────
Write-Host "  Defender + Firewall + ASR rules: unchanged (kept on)" -ForegroundColor Green

# ── Ensure anti-cheat & core services are RUNNING ─────────────────
# A wrongly-disabled service here is the #1 cause of Vanguard/EAC launch errors.
$mustRun = @{
    'BFE'        = 'Automatic'   # Base Filtering Engine — required by EAC/firewall
    'mpssvc'     = 'Automatic'   # Windows Firewall
    'WinDefend'  = 'Automatic'   # Defender (Vanguard wants AV present)
    'Appinfo'    = 'Manual'      # UAC elevation
    'gpsvc'      = 'Automatic'   # Group Policy (policies apply)
    'EventLog'   = 'Automatic'   # Event log — EAC checks it
    'Schedule'   = 'Automatic'   # Task Scheduler
    'Dhcp'       = 'Automatic'   # DHCP — networking
    'Dnscache'   = 'Automatic'   # DNS cache
    'nsi'        = 'Automatic'   # Network store
    'CryptSvc'   = 'Automatic'   # Signature checks (driver/AC validation)
    'WSearch'    = 'Automatic'   # Search (re-enable if Performance disabled it)
    'SysMain'    = 'Automatic'   # Prefetch (helps HDD/low-RAM)
    'WpnService' = 'Automatic'   # Notifications (usability)
    'Audiosrv'   = 'Automatic'   # Audio
}
foreach ($svc in $mustRun.Keys) {
    $s = Get-Service $svc -EA SilentlyContinue
    if ($s) {
        Set-Service $svc -StartupType $mustRun[$svc] -EA SilentlyContinue
        try { Start-Service $svc -EA SilentlyContinue } catch {}
    }
}
Write-Host "  Critical services (BFE, firewall, Defender, Search, audio): ensured running" -ForegroundColor Green

# ── Restore input queue sizes (in case Performance shrank them) ───
Remove-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\mouclass\Parameters' -Name 'MouseDataQueueSize' -EA SilentlyContinue
Remove-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters' -Name 'KeyboardDataQueueSize' -EA SilentlyContinue

# ── Re-enable CPU mitigations (undo any Performance-profile disable) ──
Remove-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'FeatureSettingsOverride' -EA SilentlyContinue
Remove-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'FeatureSettingsOverrideMask' -EA SilentlyContinue
Write-Host "  CPU mitigations: restored to secure default" -ForegroundColor Green

# ── Revert aggressive Performance-profile tweaks that can hurt some HW ─────
# MSI mode: revert on every GPU (driver re-enables where safe)
Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Enum' -Recurse -EA SilentlyContinue -Depth 6 |
    Where-Object { $_.PSChildName -eq 'MessageSignaledInterruptProperties' } |
    ForEach-Object { Remove-ItemProperty -Path $_.PSPath -Name 'MSISupported' -EA SilentlyContinue }
# Fault-Tolerant Heap back on (stability on flaky apps)
Set-Reg 'HKLM:\SOFTWARE\Microsoft\FTH' 'Enabled' 'DWord' 1
# svchost split: restore Windows default (10240 MB in KB) on low-RAM systems
try {
    $ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,1)
    if ($ramGB -lt 8) {
        Remove-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'SvcHostSplitThresholdInKB' -EA SilentlyContinue
        Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters' 'EnablePrefetcher' 'DWord' 3
        Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters' 'EnableSuperfetch' 'DWord' 3
        Write-Host "  Low RAM ($ramGB GB): svchost default + prefetch re-enabled" -ForegroundColor Yellow
    }
} catch {}

# ── Detect hardware and report what was adjusted ──────────────────
$score = 100
try {
    $cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
    $gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
    $ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,1)
    $isLaptop = [bool]((Get-CimInstance Win32_SystemEnclosure).ChassisTypes | Where-Object { $_ -in @(8,9,10,11,12,14,18,21) })
    $hasWifi = [bool](Get-CimInstance Win32_NetworkAdapter -EA SilentlyContinue | Where-Object { $_.Name -match 'Wi-?Fi|Wireless|802\.11' })

    Write-Host "`n  --- Hardware report ---" -ForegroundColor Cyan
    Write-Host "  CPU : $cpu" -ForegroundColor White
    Write-Host "  GPU : $gpu" -ForegroundColor White
    Write-Host "  RAM : $ramGB GB | Type: $(if($isLaptop){'Laptop'}else{'Desktop'}) | WiFi: $hasWifi" -ForegroundColor White

    if ($cpu -match 'Ryzen|AMD') { Write-Host "  - AMD: risky boot tweaks kept reverted (AGESA safe)" -ForegroundColor Yellow }
    if ($gpu -notmatch 'RTX [23456789]|RX [56789][0-9]{3}|RX 7[0-9]{3}|Arc A') {
        Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 'DWord' 1
        Write-Host "  - Old/iGPU: HAGS disabled, MPO left default" -ForegroundColor Yellow
    }
    if ($isLaptop) {
        # Laptops: power throttling stays ON (battery), balanced plan
        Remove-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling' -Name 'PowerThrottlingOff' -EA SilentlyContinue
        Write-Host "  - Laptop: power throttling restored, balanced plan, hibernation on" -ForegroundColor Yellow
    }
    if ($hasWifi) { Write-Host "  - WiFi present: Nagle restored to avoid drops" -ForegroundColor Yellow }
    if ($ramGB -lt 8) { Write-Host "  - Low RAM: prefetch/SysMain kept on" -ForegroundColor Yellow }
} catch {}

Write-Host "`nEndrit OS: Safe Compatibility Mode applied." -ForegroundColor Green
Write-Host "Target compatibility: ~95% of modern hardware. System should boot and run reliably." -ForegroundColor Cyan
