# Endrit OS - security status dashboard -> JSON (for Toolbox Security page)
param([switch]$Json)
$ErrorActionPreference = 'SilentlyContinue'

function State($b){ if($b){'on'}else{'off'} }

# Defender + tamper
$mp = $null; try { $mp = Get-MpComputerStatus -EA SilentlyContinue } catch {}
$defender = if ($mp) { State $mp.AntivirusEnabled } else { 'unknown' }
$rtp      = if ($mp) { State $mp.RealTimeProtectionEnabled } else { 'unknown' }
$tamper   = if ($mp) { State $mp.IsTamperProtected } else { 'unknown' }

# Firewall
$fw = 'unknown'
try { $fw = State ((Get-NetFirewallProfile -EA SilentlyContinue | Where-Object Enabled -eq $true).Count -gt 0) } catch {}

# Secure Boot
$sb = 'unknown'; try { $sb = State (Confirm-SecureBootUEFI) } catch {}

# VBS / HVCI
$vbs = 'unknown'
try { $g = Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard -EA SilentlyContinue; if($g){ $vbs = if($g.VirtualizationBasedSecurityStatus -eq 2){'on'}else{'off'} } } catch {}

# ASR rule count
$asrCount = 0
try { $asr = (Get-MpPreference).AttackSurfaceReductionRules_Ids; if($asr){ $asrCount = $asr.Count } } catch {}

# SmartScreen
$ss = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name SmartScreenEnabled -EA SilentlyContinue).SmartScreenEnabled
if (-not $ss) { $ss = 'unknown' }

# RDP
$rdp = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections -EA SilentlyContinue).fDenyTSConnections
$rdpState = if ($rdp -eq 1) { 'off (good)' } elseif ($rdp -eq 0) { 'on' } else { 'unknown' }

$status = [ordered]@{
    defender = $defender; realtimeProtection = $rtp; tamperProtection = $tamper
    firewall = $fw; secureBoot = $sb; vbs = $vbs; asrRules = $asrCount
    smartScreen = $ss; rdp = $rdpState; checkedAt = (Get-Date).ToString('o')
}

$dir = Join-Path $env:ProgramData 'EndritOS'
if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
($status | ConvertTo-Json) | Set-Content (Join-Path $dir 'security.json') -Encoding UTF8

if ($Json) { $status | ConvertTo-Json }
else {
    Write-Host "Endrit OS - Security status" -ForegroundColor Cyan
    $status.GetEnumerator() | ForEach-Object { Write-Host ("  {0,-20}: {1}" -f $_.Key, $_.Value) }
    if ($tamper -eq 'off') { Write-Host "  TIP: Enable Tamper Protection in Windows Security > Virus & threat protection settings." -ForegroundColor Yellow }
}
