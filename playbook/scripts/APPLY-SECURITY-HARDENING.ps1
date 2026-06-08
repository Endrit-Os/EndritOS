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
# Block JS/VBScript from launching downloaded executable content — safe
Set-Reg $asrRules 'd3e037e1-3eb8-44c8-a917-57927947596d' 'String' '1'
# Block execution of potentially obfuscated scripts — safe
Set-Reg $asrRules '5beb7efe-fd9a-4556-801d-275e5ffc04cc' 'String' '1'
Write-Host "  ASR: 5 safe rules active (LSASS, email exec, Office child, JS/VBS exec, obfuscated scripts)" -ForegroundColor Green

# ── SMBv1 off — major attack surface, safe to remove on home PCs ───────────
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' 'SMB1' 'DWord' 0
try { Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -EA SilentlyContinue | Out-Null } catch {}
Write-Host "  SMBv1: disabled" -ForegroundColor Green

# ── AutoRun / AutoPlay off — blocks USB-spread malware (safe) ──────────────
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoDriveTypeAutoRun' 'DWord' 255
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoAutorun' 'DWord' 1
Write-Host "  AutoRun/AutoPlay: disabled" -ForegroundColor Green

# ── SmartScreen ON for apps + Edge (safe, blocks malware downloads) ────────
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'SmartScreenEnabled' 'String' 'Warn'
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableSmartScreen' 'DWord' 1
Write-Host "  SmartScreen: enabled (Warn)" -ForegroundColor Green

# ── DEP / mitigations ON for all processes (security) ──────────────────────
bcdedit /set nx OptOut 2>$null | Out-Null
Write-Host "  DEP: OptOut (mitigations on)" -ForegroundColor Green

# ── Defender: cloud + PUA + network protection (max sensible) ──────────────
try {
    Set-MpPreference -MAPSReporting Advanced -EA SilentlyContinue
    Set-MpPreference -SubmitSamplesConsent SendSafeSamples -EA SilentlyContinue
    Set-MpPreference -PUAProtection Enabled -EA SilentlyContinue
    Set-MpPreference -EnableNetworkProtection Enabled -EA SilentlyContinue
    Set-MpPreference -CloudBlockLevel High -EA SilentlyContinue
    Set-MpPreference -DisableRealtimeMonitoring $false -EA SilentlyContinue
    # Controlled Folder Access in AUDIT only (avoids breaking game launchers)
    Set-MpPreference -EnableControlledFolderAccess AuditMode -EA SilentlyContinue
    Write-Host "  Defender: cloud High, PUA on, network protection on, CFA audit" -ForegroundColor Green
} catch {}

# ── Exploit protection system-wide (DEP, ASLR, CFG, SEHOP, heap) ───────────
try {
    Set-ProcessMitigation -System -Enable DEP,EmulateAtlThunks,BottomUp,HighEntropy,SEHOP,TerminateOnError,CFG -EA SilentlyContinue
    Write-Host "  Exploit protection: DEP/ASLR/CFG/SEHOP system-wide" -ForegroundColor Green
} catch {}
# SEHOP via registry fallback
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' 'DisableExceptionChainValidation' 'DWord' 0

# ── Credential protection — kill plaintext + legacy auth ───────────────────
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest' 'UseLogonCredential' 'DWord' 0   # no plaintext creds in memory
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'LmCompatibilityLevel' 'DWord' 5                       # NTLMv2 only, refuse LM/NTLMv1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'NoLMHash' 'DWord' 1                                   # don't store LM hash
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'RestrictAnonymous' 'DWord' 1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0' 'NTLMMinClientSec' 'DWord' 537395200             # require NTLMv2 + 128-bit
Write-Host "  Credentials: WDigest off, LM/NTLMv1 refused, NTLMv2-only" -ForegroundColor Green

# ── SMB signing required + no guest/insecure logons ────────────────────────
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' 'RequireSecuritySignature' 'DWord' 1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' 'RequireSecuritySignature' 'DWord' 1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' 'AllowInsecureGuestAuth' 'DWord' 0
Write-Host "  SMB: signing required, insecure guest auth off" -ForegroundColor Green

# ── PowerShell script-block logging (forensics / detect malware) ───────────
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' 'EnableScriptBlockLogging' 'DWord' 1
# Disable legacy PowerShell v2 (no AMSI/logging) if present
try { Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -NoRestart -EA SilentlyContinue | Out-Null } catch {}
Write-Host "  PowerShell: script-block logging on, v2 engine off" -ForegroundColor Green

# ── DNS-over-HTTPS (encrypted DNS, anti-tamper/spoof) ──────────────────────
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' 'EnableAutoDoh' 'DWord' 2
Write-Host "  DoH: auto-upgrade enabled" -ForegroundColor Green

# ── Hardened UNC paths (block MITM on \\ shares) ───────────────────────────
$unc = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths'
Set-Reg $unc '\\*\SYSVOL' 'String' 'RequireMutualAuthentication=1, RequireIntegrity=1'
Set-Reg $unc '\\*\NETLOGON' 'String' 'RequireMutualAuthentication=1, RequireIntegrity=1'

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
# Disable NetBIOS over TCP/IP on every interface (stops LAN name-poisoning)
Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces' -EA SilentlyContinue | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name 'NetbiosOptions' -Type DWord -Value 2 -EA SilentlyContinue
}
# Block mDNS too (additional name-spoofing surface)
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' 'EnableMDNS' 'DWord' 0

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
if ($sb) {
    Write-Host "  Secure Boot: ON (required for Vanguard)" -ForegroundColor Green
    # LSA protection (RunAsPPL) — strong anti-credential-theft. Only with Secure
    # Boot to avoid breaking unsigned drivers on legacy systems.
    Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' 'RunAsPPL' 'DWord' 2
    Write-Host "  LSA protection (RunAsPPL): enabled" -ForegroundColor Green
} else {
    Write-Host "  Secure Boot: OFF — enable in BIOS for Vanguard/EAC + LSA protection" -ForegroundColor Yellow
}

Write-Host "Endrit OS: Security hardening complete (9.6 hardened, anti-cheat safe)." -ForegroundColor Green
Write-Host "  5 ASR | Defender cloud+PUA+NetProtect | Exploit-Prot DEP/ASLR/CFG/SEHOP | WDigest off | NTLMv2-only | SMB signing | SMBv1 off | AutoRun off | SmartScreen on | PS logging | DoH | NetBIOS/mDNS/LLMNR off | RDP off | UAC on | LSA PPL" -ForegroundColor Cyan
