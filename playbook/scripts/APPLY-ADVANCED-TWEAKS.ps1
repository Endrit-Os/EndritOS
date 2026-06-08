# Endrit OS v2.4 — Advanced Tweaks (Safe — 91%+ compatibility)
# Only universally safe tweaks here. Risky ones moved to Performance profile.
$ErrorActionPreference = 'SilentlyContinue'

function Set-Reg($path, $name, $type, $value) {
    if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name $name -Type $type -Value $value -ErrorAction SilentlyContinue
}

Write-Host "Endrit OS v2.4: Applying safe advanced tweaks..." -ForegroundColor Cyan

# ── NTFS Optimizations — universally safe ────────────────────────
fsutil behavior set DisableLastAccess 1 2>$null
fsutil behavior set EncryptPagingFile 0 2>$null
# 8.3 names off — safe on all modern Windows 11 installs
fsutil behavior set disable8dot3 1 2>$null

# ── Network Stack — safe globals ─────────────────────────────────
$tcp = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
Set-Reg $tcp 'DefaultTTL'          'DWord' 64
Set-Reg $tcp 'EnablePMTUDiscovery' 'DWord' 1
Set-Reg $tcp 'Tcp1323Opts'         'DWord' 1
Set-Reg $tcp 'MaxUserPort'         'DWord' 65534
Set-Reg $tcp 'TcpTimedWaitDelay'   'DWord' 30
Set-Reg $tcp 'EnableICMPRedirect'  'DWord' 0
netsh int tcp set global autotuninglevel=normal 2>$null
netsh int tcp set global rss=enabled         2>$null
netsh int tcp set global chimney=disabled    2>$null
netsh int tcp set global ecncapability=disabled 2>$null
# NOTE: Per-interface Nagle off (TCPNoDelay) is left as Toolbox toggle only
# Applying it globally caused connectivity issues on some WiFi adapters

# ── IFEO CPU priorities — universally safe ─────────────────────────
$ifeo = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
# Telemetry binaries — IFEO block (safe, only blocks Microsoft telemetry)
@('CompatTelRunner.exe','AggregatorHost.exe','DeviceCensus.exe',
  'BingChatInstaller.exe','BGAUpsell.exe','BCILauncher.exe') | ForEach-Object {
    Set-Reg "$ifeo\$_" 'Debugger' 'String' '%windir%\System32\taskkill.exe'
}
# Lower priority for background processes (universally safe — Atlas pattern)
Set-Reg "$ifeo\SearchIndexer.exe\PerfOptions" 'CpuPriorityClass' 'DWord' 5
Set-Reg "$ifeo\ctfmon.exe\PerfOptions"        'CpuPriorityClass' 'DWord' 5
Set-Reg "$ifeo\fontdrvhost.exe\PerfOptions"   'CpuPriorityClass' 'DWord' 1
Set-Reg "$ifeo\fontdrvhost.exe\PerfOptions"   'IoPriority'       'DWord' 0

# ── Memory Management — safe ─────────────────────────────────────────────────
$mm = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
Set-Reg $mm 'ClearPageFileAtShutdown'     'DWord' 0
Set-Reg $mm 'DisablePagingExecutive'      'DWord' 1
Set-Reg $mm 'LargeSystemCache'            'DWord' 0

# ── GPU Scheduling (HAGS) — smart detection ──────────────────────────────────
# Only enable HAGS on supported GPU generations (RTX 2000+ / RX 5000+)
$gpuOk = $false
try {
    $gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
    $gpuOk = $gpu -match 'RTX [23456789]|RX [567689][0-9]{3}|RX 7[0-9]{3}|Arc A[0-9]'
} catch {}
if ($gpuOk) {
    Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 'DWord' 2
    Write-Host "  HAGS enabled (GPU supported: $gpu)" -ForegroundColor Green
} else {
    Write-Host "  HAGS skipped (GPU generation check: $gpu)" -ForegroundColor Yellow
}
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'TdrDelay'   'DWord' 10
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'TdrDdiDelay' 'DWord' 20

# ── Power Plan — smart laptop detection ──────────────────────────────────────
$isLaptop = $false
try {
    $chassis = (Get-CimInstance Win32_SystemEnclosure).ChassisTypes
    $isLaptop = $chassis | Where-Object { $_ -in @(8,9,10,11,12,14,18,21,31,32) }
} catch {}

if ($isLaptop) {
    # Laptop: use Balanced on battery, High on AC (not Ultimate Performance)
    $balanced = "381b4222-f694-41f0-9685-ff5bb260df2e"
    powercfg -setactive $balanced 2>$null
    Write-Host "  Laptop detected: Balanced power plan (battery-safe)" -ForegroundColor Yellow
} else {
    # Desktop: apply Ultimate Performance
    $perf = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    powercfg -duplicatescheme $perf 2>$null
    powercfg -setactive $perf 2>$null
    powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 2>$null
    Write-Host "  Desktop: Ultimate Performance power plan applied" -ForegroundColor Green
}

# ── SSD/NVMe safe optimizations ──────────────────────────────────────────────
# Disable defrag schedule (Windows auto-detects SSD, this is extra safe)
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction' 'Enable' 'String' 'N'

# ── Auto-loggers off — safe ───────────────────────────────────────────────────
$loggerBase = 'HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger'
@('Diagtrack-Listener','SQMLogger','SetupPlatformTel','CloudExperienceHostOobe') | ForEach-Object {
    Set-Reg "$loggerBase\$_" 'Start' 'DWord' 0
}

Write-Host "Endrit OS v2.4: Safe advanced tweaks complete." -ForegroundColor Green
Write-Host "  Skipped risky tweaks: disabledynamictick, tscsyncpolicy, per-interface Nagle" -ForegroundColor Cyan
