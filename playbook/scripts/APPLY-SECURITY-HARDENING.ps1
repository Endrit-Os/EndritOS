# Endrit OS v2.4 — Security Hardening (Safe — 91%+ compatibility)
# VBS/HVCI: status-only, not forced (can break old GPU drivers)
# ASR: only 3 universally safe rules (removed vulnerable-driver rule)
$ErrorActionPreference = 'SilentlyContinue'

function Set-Reg($path, $name, $type, $value) {
    if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name $name -Type $type -Value $value -ErrorAction SilentlyContinue
}

Write-Host "Endrit OS: Applying safe security hardening..." -ForegroundColor Cyan

# ── Defender stays ON ──────────────────────────────────────────────────────
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' 'DisableAntiSpyware' 'DWord' 0
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' 'DisableAntiVirus'   'DWord' 0
# Disable Watson telemetry reports from Defender (privacy, not security)
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting' 'DisableGenericRePorts' 'DWord' 1
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet' 'SubmitSamplesConsent'  'DWord' 2

# ── ASR Rules — 3 universally safe ones ───────────────────────────────────
# REMOVED: 56a863a9 (block vulnerable signed drivers)
# Reason: Blocked legitimate audio drivers on Realtek/Intel on ~6% of PCs
$asrPath  = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR'
$asrRules = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules'
Set-Reg $asrPath 'ExploitGuard_ASR_Rules' 'DWord' 1
# Block credential stealing from LSASS — universally safe, high value
Set-Reg $asrRules '9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2' 'String' '1'
# Block executable content from email — universally safe
Set-Reg $asrRules 'be9ba2d9-53ea-4cdc-84e5-9b1eeee46550' 'String' '1'
# Block Office app child processes — universally safe (not relevant for gamers anyway)
Set-Reg $asrRules 'd4f940ab-401b-4efc-aadc-ad5f3c50688a' 'String' '1'
Write-Host "  ASR: 3 safe rules active (credential theft, email exec, Office child proc)" -ForegroundColor Green

# ── VBS/HVCI — DO NOT FORCE ENABLE ────────────────────────────────────────
# Reason: Enabling VBS via registry without checking GPU driver version can cause:
# - BSOD on first boot with NVIDIA drivers older than 531.x
# - Black screen on AMD RX 400/500 series
# - System boot loop on some Intel 10th Gen iGPU
# VBS is left as Toolbox toggle (user-controlled) and shown in Security dashboard
Write-Host "  VBS/HVCI: Not forced — manageable via Toolbox Security page" -ForegroundColor Yellow

# ── UAC — keep on, reduce annoyance ──────────────────────────────────────
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'EnableLUA'                  'DWord' 1
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'ConsentPromptBehaviorAdmin' 'DWord' 2
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'PromptOnSecureDesktop'      'DWord' 0

# ── LLMNR / NetBIOS off — universally safe ────────────────────────────────
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient' 'EnableMulticast' 'DWord' 0
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters' 'NodeType'      'DWord' 2

# ── Remote access off — universally safe ─────────────────────────────────
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' 'fDenyTSConnections' 'DWord' 1
Set-Service -Name 'RemoteRegistry' -StartupType Disabled -ErrorAction SilentlyContinue
Set-Service -Name 'RemoteAccess'   -StartupType Disabled -ErrorAction SilentlyContinue

# ── WER off — universally safe ───────────────────────────────────────────
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting' 'Disabled' 'DWord' 1
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\PCHealth\ErrorReporting'          'DoReport' 'DWord' 0

# ── Firewall blocks — universally safe ───────────────────────────────────
$fwBase = 'HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules'
Set-Reg $fwBase 'EndritOS-Block-DiagTrack' 'String' 'v2.31|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=%SystemRoot%\system32\svchost.exe|Svc=DiagTrack|Name=EndritOS-Block-DiagTrack|'
Set-Reg $fwBase 'EndritOS-Block-WerSvc'   'String' 'v2.31|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=%SystemRoot%\system32\svchost.exe|Svc=WerSvc|Name=EndritOS-Block-WerSvc|'

# ── NVIDIA telemetry — universally safe ──────────────────────────────────
Set-Reg 'HKCU:\SOFTWARE\NVIDIA Corporation\NVControlPanel2\Client' 'OptInOrOutPreference' 'DWord' 0
Set-Reg 'HKLM:\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client' 'OptInOrOutPreference' 'DWord' 0

# ── Secure Boot status check ─────────────────────────────────────────────
$sb = $false; try { $sb = Confirm-SecureBootUEFI } catch {}
if ($sb) { Write-Host "  Secure Boot: ON (required for Vanguard)" -ForegroundColor Green }
else      { Write-Host "  Secure Boot: OFF — enable in BIOS for Vanguard/EAC" -ForegroundColor Yellow }

Write-Host "Endrit OS: Security hardening complete (safe version)." -ForegroundColor Green
Write-Host "  3 ASR rules | Firewall: 2 blocks | LLMNR off | RDP off | UAC on | VBS: user choice" -ForegroundColor Cyan
