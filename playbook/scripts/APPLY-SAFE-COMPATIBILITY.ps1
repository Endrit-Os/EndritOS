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

Write-Host "`nEndrit OS: Safe Compatibility Mode applied." -ForegroundColor Green
Write-Host "Your system should now boot and run reliably on any hardware." -ForegroundColor Cyan
