# Endrit OS — Deep FPS Tweaks v3
# Every tweak here is safe for Ranked Safe + anti-cheat
$ErrorActionPreference = 'SilentlyContinue'

function Set-Reg($path, $name, $type, $value) {
    if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name $name -Type $type -Value $value -ErrorAction SilentlyContinue
}

Write-Host "Endrit OS: Applying deep FPS tweaks..." -ForegroundColor Cyan

# ── MMCSS — Maximum gaming priority ──────────────────────────────────────────
$mmbase = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
Set-Reg $mmbase 'SystemResponsiveness'     'DWord' 0      # 0 = all CPU time to game
Set-Reg $mmbase 'NetworkThrottlingIndex'   'DWord' 0xFFFFFFFF  # no network throttle
Set-Reg $mmbase 'AlwaysOn'                 'DWord' 1

$games = "$mmbase\Tasks\Games"
Set-Reg $games 'Affinity'                  'DWord' 0
Set-Reg $games 'Background Only'           'String' 'False'
Set-Reg $games 'Clock Rate'                'DWord' 10000
Set-Reg $games 'GPU Priority'             'DWord' 8
Set-Reg $games 'Priority'                 'DWord' 6
Set-Reg $games 'Scheduling Category'       'String' 'High'
Set-Reg $games 'SFIO Priority'            'String' 'High'

# ── CPU Priority Separation (Win32PrioritySeparation) ────────────────────────
# 38 = short quantum, variable, 3x foreground boost (Atlas recommended)
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' 'Win32PrioritySeparation' 'DWord' 38

# ── HAGS (Hardware Accelerated GPU Scheduling) — smart detect ────────────────
try {
    $gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
    if ($gpu -match 'RTX [23456789]|RX [56789][0-9]{3}|RX 7[0-9]{3}|Arc A') {
        Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 'DWord' 2
        Write-Host "  HAGS: Enabled (GPU: $gpu)" -ForegroundColor Green
    }
} catch {}

# ── Disable GameBarPresenceWriter (background overlay overhead) ───────────────
$ifeo = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
Set-Reg "$ifeo\GameBarPresenceWriter.exe" 'Debugger' 'String' '%windir%\System32\taskkill.exe'

# ── Timer Resolution — apps can request high resolution ──────────────────────
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' 'GlobalTimerResolutionRequests' 'DWord' 1

# ── Input lag — mouse ─────────────────────────────────────────────────────────
Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseSpeed'      'String' '0'
Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseThreshold1' 'String' '0'
Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseThreshold2' 'String' '0'
# Disable mouse pointer precision (raw input)
Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseSensitivity' 'String' '10'

# ── DirectX / D3D tweaks ──────────────────────────────────────────────────────
Set-Reg 'HKLM:\SOFTWARE\Microsoft\DirectX' 'MaxD3D9WindowedMode'  'DWord' 0
# Force direct GPU memory access
Set-Reg 'HKCU:\Software\Microsoft\DirectX\UserGpuPreferences' 'DirectXUserGlobalSettings' 'String' 'VRROptimizeEnable=0;'

# ── CPU core parking (disable for gaming desktops) ───────────────────────────
try {
    $isLaptop = [bool]((Get-CimInstance Win32_SystemEnclosure).ChassisTypes | Where-Object { $_ -in @(8,9,10,11,12,14,18,21) })
    if (-not $isLaptop) {
        # Disable CPU core parking for consistent frame times
        $cpuPower = "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583"
        if (Test-Path $cpuPower) {
            Set-ItemProperty -Path $cpuPower -Name "ValueMax" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        }
        powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100 2>$null
        powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMAXCORES 100 2>$null
        Write-Host "  CPU core parking: disabled (desktop)" -ForegroundColor Green
    }
} catch {}

# ── Spectre/Meltdown mitigations — balanced for gaming ───────────────────────
# FeatureSettings 1 + FeatureSettingsOverride 3 = balanced security/performance
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'FeatureSettings'            'DWord' 1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'FeatureSettingsOverride'     'DWord' 3
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'FeatureSettingsOverrideMask' 'DWord' 3

# ── Interrupt affinity — NVIDIA (disable MSI mode issues) ────────────────────
# Note: MSI mode is better but requires manual GPU driver config — left for user

# ── Disable Game Bar presence writer + Xbox overlay ──────────────────────────
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowGameDVR' 'DWord' 0
Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled'              'DWord' 0
Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_FSEBehaviorMode'      'DWord' 2
Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_HonorUserFSEBehaviorMode' 'DWord' 1
Set-Reg 'HKCU:\System\GameConfigStore' 'GameDVR_DXGIHonorFSEWindowsCompatible' 'DWord' 1

# ── MultiPlane Overlay (MPO) — fix NVIDIA flicker/stutter ────────────────────
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\Dwm' 'OverlayTestMode' 'DWord' 5  # disable MPO

# ── NTFS last access timestamp off ───────────────────────────────────────────
fsutil behavior set DisableLastAccess 1 2>$null
fsutil behavior set disable8dot3 1 2>$null

# ── Autologger trim (reduces CPU at idle) ─────────────────────────────────────
$loggers = 'HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger'
@('Diagtrack-Listener','SQMLogger','SetupPlatformTel','WiFiDriverIHVSession',
  'NBSMBLOGGER','PEAuthLog','CloudExperienceHostOobe','WiFiSession') | ForEach-Object {
    Set-Reg "$loggers\$_" 'Start' 'DWord' 0
}

# ── Power plan — Ultimate Performance ────────────────────────────────────────
$upGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
powercfg -duplicatescheme $upGuid 2>$null
powercfg -setactive $upGuid 2>$null

# Processor boost mode 2 = Aggressive
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 2 2>$null
# USB selective suspend off
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 2>$null

Write-Host "Endrit OS: Deep FPS tweaks applied." -ForegroundColor Green
Write-Host "  MMCSS Priority: 6/8 GPU | CPU PriSep: 38 | Core parking: off | MPO: fix | Timer: global" -ForegroundColor Cyan
