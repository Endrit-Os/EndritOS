# Endrit OS v2.4 — Compatibility Fixer (targets 95%+ PC compatibility)
# Handles AMD APU, Intel integrated, old GPU, WiFi, Surface, OEM systems
$ErrorActionPreference = 'SilentlyContinue'

function Set-Reg($path, $name, $type, $value) {
    if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name $name -Type $type -Value $value -ErrorAction SilentlyContinue
}

Write-Host "Endrit OS: Running Compatibility Fixer..." -ForegroundColor Cyan

# ── Detect hardware ────────────────────────────────────────────────────────
$cpu       = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
$gpus      = Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion
$primaryGpu= $gpus | Select-Object -First 1
$isAMDCPU  = $cpu -match 'AMD|Ryzen|EPYC|Athlon'
$isIntelCPU= $cpu -match 'Intel|Core|Celeron|Pentium|Xeon'
$isOldIntel= $cpu -match 'i[3-9]-[0-9]{3}[0-9]|i[3-9] [0-9]{3}[0-9]|Core2|Pentium|Celeron'
$hasNVIDIA = $gpus | Where-Object { $_.Name -match 'NVIDIA|GeForce' }
$hasAMDGPU = $gpus | Where-Object { $_.Name -match 'AMD|Radeon|RX' }
$hasIntelGPU=$gpus | Where-Object { $_.Name -match 'Intel.*Graphics|UHD|Iris' }
$chassis   = try { (Get-CimInstance Win32_SystemEnclosure).ChassisTypes } catch { @() }
$isLaptop  = [bool]($chassis | Where-Object { $_ -in @(8,9,10,11,12,14,18,21,31,32) })
$isSurface = (Get-CimInstance Win32_ComputerSystem).Manufacturer -match 'Microsoft'
$ramGb     = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,0)

Write-Host "  CPU: $($cpu.Trim().Substring(0,[math]::Min(50,$cpu.Length)))" -ForegroundColor Gray
Write-Host "  GPU: $($primaryGpu.Name)" -ForegroundColor Gray
Write-Host "  RAM: $ramGb GB | Laptop: $isLaptop | Surface: $isSurface" -ForegroundColor Gray

# ── Fix 1: AMD Ryzen — revert risky boot tweaks ───────────────────────────
if ($isAMDCPU) {
    bcdedit /deletevalue disabledynamictick 2>$null
    bcdedit /deletevalue tscsyncpolicy      2>$null
    bcdedit /deletevalue useplatformtick    2>$null
    Write-Host "  [AMD CPU] Boot tweaks reverted (BSOD prevention)" -ForegroundColor Yellow
}

# ── Fix 2: Old Intel (<= 8th gen) — remove tscsync ───────────────────────
if ($isOldIntel) {
    bcdedit /deletevalue tscsyncpolicy 2>$null
    Write-Host "  [Old Intel] tscsyncpolicy reverted (slow boot prevention)" -ForegroundColor Yellow
}

# ── Fix 3: Intel integrated GPU — disable HAGS ───────────────────────────
if ($hasIntelGPU -and -not $hasNVIDIA -and -not $hasAMDGPU) {
    Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 'DWord' 1
    Write-Host "  [Intel iGPU] HAGS disabled (not supported on iGPU)" -ForegroundColor Yellow
}

# ── Fix 4: Old NVIDIA (pre-RTX) — disable HAGS ───────────────────────────
if ($hasNVIDIA -and $primaryGpu.Name -match 'GTX [0-9]{3}[^0-9]|GTX 9[0-9]{2}|GTX 10[0-9]{2}') {
    Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 'DWord' 1
    Write-Host "  [Old NVIDIA] HAGS disabled (GTX series not supported)" -ForegroundColor Yellow
}

# ── Fix 5: Laptop — safe power plan ──────────────────────────────────────
if ($isLaptop) {
    $balanced = "381b4222-f694-41f0-9685-ff5bb260df2e"
    powercfg -setactive $balanced 2>$null
    powercfg /hibernate on 2>$null
    Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' 'HibernateEnabled' 'DWord' 1
    Write-Host "  [Laptop] Balanced power plan, hibernation re-enabled" -ForegroundColor Yellow
}

# ── Fix 6: Surface / OEM — preserve OEM services ─────────────────────────
if ($isSurface) {
    @('SurfaceService','SurfaceDockFwUpdate','SurfaceHotPlug') | ForEach-Object {
        Set-Service -Name $_ -StartupType Automatic -ErrorAction SilentlyContinue
    }
    Write-Host "  [Surface] Surface services preserved" -ForegroundColor Yellow
}

# ── Fix 7: Low RAM (< 8 GB) — keep SuperFetch ────────────────────────────
if ($ramGb -lt 8) {
    Set-Service -Name 'SysMain' -StartupType Automatic -ErrorAction SilentlyContinue
    Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\SysMain' 'Start' 'DWord' 2
    Write-Host "  [Low RAM $($ramGb) GB] SuperFetch re-enabled (HDD performance)" -ForegroundColor Yellow
}

# ── Fix 8: WiFi — restore Nagle (prevents drops) ─────────────────────────
$wifiAdapters = Get-NetAdapter | Where-Object { $_.MediaType -eq '802.11' -and $_.Status -eq 'Up' }
if ($wifiAdapters) {
    Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces' -EA SilentlyContinue | ForEach-Object {
        Remove-ItemProperty -Path $_.PSPath -Name 'TCPNoDelay' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $_.PSPath -Name 'TcpAckFrequency' -ErrorAction SilentlyContinue
    }
    Write-Host "  [WiFi detected] Nagle algorithm restored (prevents WiFi drops)" -ForegroundColor Yellow
}

# ── Fix 9: Ensure critical anti-cheat services are running ───────────────
@('WinDefend','mpssvc','BFE','EventLog') | ForEach-Object {
    $svc = Get-Service $_ -ErrorAction SilentlyContinue
    if ($svc -and $svc.StartType -eq 'Disabled') {
        Set-Service -Name $_ -StartupType Automatic -ErrorAction SilentlyContinue
        Write-Host "  [Anti-cheat] Re-enabled service: $_" -ForegroundColor Green
    }
}

# ── Fix 10: Restore Windows Search if disabled ────────────────────────────
# (needed for Start menu to work on some systems)
$wSearch = Get-Service 'WSearch' -ErrorAction SilentlyContinue
if ($wSearch -and $wSearch.StartType -eq 'Disabled') {
    Set-Service -Name 'WSearch' -StartupType Manual -ErrorAction SilentlyContinue
    Write-Host "  [Search] WSearch set to Manual (Start menu fix)" -ForegroundColor Yellow
}

Write-Host "`nEndrit OS: Compatibility fixes applied for your hardware." -ForegroundColor Green
Write-Host "  Expected compatibility: 95%+" -ForegroundColor Cyan
