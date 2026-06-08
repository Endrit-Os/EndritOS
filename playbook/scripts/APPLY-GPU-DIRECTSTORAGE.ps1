# Endrit OS - GPU + DirectStorage fine-tuning (safe, anti-cheat friendly)
$ErrorActionPreference = 'SilentlyContinue'
function Set-Reg($p,$n,$t,$v){ if(!(Test-Path $p)){New-Item -Path $p -Force|Out-Null}; Set-ItemProperty -Path $p -Name $n -Type $t -Value $v -Force -EA SilentlyContinue }

Write-Host "Endrit OS: GPU + DirectStorage tuning..." -ForegroundColor Cyan

# Detect GPU
$gpu = ''
try { $gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name } catch {}

# HAGS only on supported GPUs (RTX 2000+/RX 5000+/Arc)
if ($gpu -match 'RTX [23456789]|RX [56789][0-9]{3}|RX 7[0-9]{3}|Arc A') {
    Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 'DWord' 2
    Write-Host "  HAGS: enabled ($gpu)" -ForegroundColor Green
} else {
    Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 'DWord' 1
    Write-Host "  HAGS: left off (GPU: $gpu)" -ForegroundColor Yellow
}

# DirectStorage: enable BypassIO + storage cache for NVMe (helps modern games)
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' 'FsEnableBypassIO' 'DWord' 1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\StorageSettings' 'EnableBypassIO' 'DWord' 1

# Prefer maximum performance for the GPU, disable power saving on dGPU
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'TdrDelay' 'DWord' 10
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'PlatformSupportMiracast' 'DWord' 0

# Global high-performance GPU preference for desktop apps
Set-Reg 'HKCU:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences' 'DirectXUserGlobalSettings' 'String' 'SwapEffectUpgradeEnable=1;'

# MPO fix for NVIDIA flicker/stutter (safe)
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm' 'OverlayTestMode' 'DWord' 5

# NVIDIA telemetry off
Set-Reg 'HKLM:\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client' 'OptInOrOutPreference' 'DWord' 0

Write-Host "Endrit OS: GPU + DirectStorage tuning done." -ForegroundColor Green
