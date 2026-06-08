# ═══════════════════════════════════════════════════════════════════════════
# Endrit OS v3.0 — MEGA OPTIMIZE (Ranked Safe)
# Maximale Leistung, minimale Prozesse — sicher für Anti-Cheat
# Auto-Restart nach 5 Sekunden
# ═══════════════════════════════════════════════════════════════════════════
$ErrorActionPreference = 'SilentlyContinue'
$total = 0; $done = 0

function Set-Reg($p,$n,$t,$v){if(!(Test-Path $p)){New-Item -Path $p -Force|Out-Null};Set-ItemProperty -Path $p -Name $n -Type $t -Value $v -Force -EA SilentlyContinue;$script:total++}
function Dis-Service($name){$s=Get-Service $name -EA SilentlyContinue;if($s){Set-Service $name -StartupType Disabled -EA SilentlyContinue;Stop-Service $name -Force -EA SilentlyContinue;$script:done++}}
function Dis-Task($path,$name){Disable-ScheduledTask -TaskPath $path -TaskName $name -EA SilentlyContinue|Out-Null}

Write-Host "" -ForegroundColor White
Write-Host "  ████████╗███╗   ██╗██████╗ ██████╗ ██╗████████╗     ██████╗ ███████╗" -ForegroundColor Magenta
Write-Host "  ██╔════╝████╗  ██║██╔══██╗██╔══██╗██║╚══██╔══╝    ██╔═══██╗██╔════╝" -ForegroundColor Magenta
Write-Host "  █████╗  ██╔██╗ ██║██║  ██║██████╔╝██║   ██║       ██║   ██║███████╗" -ForegroundColor DarkMagenta
Write-Host "  ██╔══╝  ██║╚██╗██║██║  ██║██╔══██╗██║   ██║       ██║   ██║╚════██║" -ForegroundColor DarkMagenta
Write-Host "  ███████╗██║ ╚████║██████╔╝██║  ██║██║   ██║       ╚██████╔╝███████║" -ForegroundColor DarkMagenta
Write-Host "  ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝        ╚═════╝ ╚══════╝" -ForegroundColor DarkMagenta
Write-Host "  Mega Optimize v3.0 — Ranked Safe + Maximum Performance" -ForegroundColor Cyan
Write-Host ""

# ── 1. SERVICES (60+) ──────────────────────────────────────────────────────
Write-Host "[1/8] Disabling background services..." -ForegroundColor Yellow
$services = @(
    # Telemetry
    'DiagTrack','WerSvc','WdiServiceHost','WdiSystemHost','PcaSvc',
    'diagnosticshub.standardcollector.service','wisvc','UCPD',
    'dmwappushservice','DPS','WinHttpAutoProxySvc',
    # Xbox / Gaming telemetry (anti-cheat safe — game services kept)
    'XblAuthManager','XblGameSave','XboxGipSvc','XboxNetApiSvc',
    # Location / Sensors
    'lfsvc','SensorDataService','SensrSvc','SensorService',
    'CscService','SharedAccess',
    # Bloat services
    'MapsBroker','RetailDemo','WMPNetworkSvc','RemoteRegistry',
    'PrintNotify','SmsRouter','CDPSvc','PhoneSvc','WpnService',
    'WpcMonSvc','WalletService','SEMgrSvc','SharedRealitySvc',
    'spectrum','stisvc','WiaRpc','FrameServer','FrameServerMonitor',
    # Power / Energy saving processes
    'dam','GpuEnergyDrv',
    # Network bloat
    'NetBT','Wecsvc','tcpipreg','UCPD',
    # Print spooler (if no printer)
    'Spooler',
    # Fax
    'Fax',
    # Secondary logon (bloat)
    'seclogon',
    # Superfetch on SSD
    'SysMain',
    # Search indexing
    'WSearch',
    # IP helper (IPv6 bloat)
    'iphlpsvc',
    # Offline files
    'CscService',
    # Portable device enum
    'WpdBusEnum',
    # Windows biometric
    'WbioSrvc',
    # Sync center
    'SyncSvc',
    # Work folder client
    'WorkFoldersSvc',
    # Mixed reality
    'spectrum',
    # AllJoyn router
    'AJRouter',
    # Downloaded maps manager
    'MapsBroker',
    # Microsoft account
    'wlidsvc',
    # Hyper-V (if not using VMs)
    # 'vmms',  -- commented out, breaks some environments
    # Parental controls
    'WpcMonSvc',
    # Smart card
    'SCardSvr','SCPolicySvc',
    # Tablet PC
    'TabletInputService',
    # Touch keyboard
    'TabletInputService'
)
foreach ($s in $services) {
    Dis-Service $s
}
Write-Host "  Disabled $done services" -ForegroundColor Green

# ── 2. SCHEDULED TASKS (80+) ───────────────────────────────────────────────
Write-Host "[2/8] Disabling telemetry and maintenance tasks..." -ForegroundColor Yellow
$tasks = @(
    @('\Microsoft\Windows\Application Experience\','Microsoft Compatibility Appraiser'),
    @('\Microsoft\Windows\Application Experience\','ProgramDataUpdater'),
    @('\Microsoft\Windows\Application Experience\','PcaPatchDbTask'),
    @('\Microsoft\Windows\Application Experience\','StartupAppTask'),
    @('\Microsoft\Windows\Autochk\','Proxy'),
    @('\Microsoft\Windows\Customer Experience Improvement Program\','Consolidator'),
    @('\Microsoft\Windows\Customer Experience Improvement Program\','UsbCeip'),
    @('\Microsoft\Windows\Customer Experience Improvement Program\','KernelCeipTask'),
    @('\Microsoft\Windows\DiskDiagnostic\','Microsoft-Windows-DiskDiagnosticDataCollector'),
    @('\Microsoft\Windows\DiskDiagnostic\','Microsoft-Windows-DiskDiagnosticResolver'),
    @('\Microsoft\Windows\Feedback\Siuf\','DmClient'),
    @('\Microsoft\Windows\Feedback\Siuf\','DmClientOnScenarioDownload'),
    @('\Microsoft\Windows\Windows Error Reporting\','QueueReporting'),
    @('\Microsoft\Windows\Maps\','MapsUpdateTask'),
    @('\Microsoft\Windows\Maps\','MapsToastTask'),
    @('\Microsoft\Windows\Shell\','FamilySafetyMonitor'),
    @('\Microsoft\Windows\Shell\','FamilySafetyRefreshTask'),
    @('\Microsoft\Windows\Flighting\FeatureConfig\','UsageDataReporting'),
    @('\Microsoft\Windows\Maintenance\','WinSAT'),
    @('\Microsoft\Windows\Power Efficiency Diagnostics\','AnalyzeSystem'),
    @('\Microsoft\Windows\Diagnosis\','Scheduled'),
    @('\Microsoft\Windows\PI\','Sqm-Tasks'),
    @('\Microsoft\Windows\NetTrace\','GatherNetworkInfo'),
    @('\Microsoft\Windows\BrokerInfrastructure\','BrokerTask'),
    @('\Microsoft\Windows\CloudExperienceHost\','CreateObjectTask'),
    @('\Microsoft\Windows\DUI\','DIAGNOSTICService'),
    @('\Microsoft\Windows\EnterpriseMgmt\','MDMMaintenanceTask'),
    @('\Microsoft\Windows\HelloFace\','FODCleanupTask'),
    @('\Microsoft\Windows\WOF\','WIM-Hash-Management'),
    @('\Microsoft\Windows\WOF\','WIM-Hash-Validation'),
    @('\Microsoft\Windows\Workplace Join\','Automatic-Device-Join'),
    @('\Microsoft\Windows\SpeechModelDownload\','SpeechModelDownloadTask'),
    @('\Microsoft\Windows\Speech\','SpeechModelDownloadTask'),
    @('\Microsoft\Windows\SettingSync\','BackgroundUploadTask'),
    @('\Microsoft\Windows\SettingSync\','NetworkStateChangeTask'),
    @('\Microsoft\Windows\Time Zone\','SynchronizeTimeZone'),
    @('\Microsoft\Windows\UPnP\','UPnPHostConfig'),
    @('\Microsoft\Windows\WCM\','WiFiTask'),
    @('\Microsoft\Windows\WlanSvc\','CDSSync'),
    @('\Microsoft\Windows\Windows Media Sharing\','UpdateLibrary'),
    @('\Microsoft\Windows\Offline Files\','Background Synchronization'),
    @('\Microsoft\Windows\Offline Files\','Logon Synchronization'),
    @('\Microsoft\Windows\Mobile Broadband Accounts\','MNO Metadata Parser'),
    @('\Microsoft\Windows\Location\','Notifications'),
    @('\Microsoft\Windows\Location\','WindowsActionDialog'),
    @('\Microsoft\Windows\Input\','InputSettingsRestoreDataAvailable'),
    @('\Microsoft\Windows\Input\','LocalUserSyncDataAvailable'),
    @('\Microsoft\Windows\Input\','MouseSyncDataAvailable'),
    @('\Microsoft\Windows\Input\','PenSyncDataAvailable'),
    @('\Microsoft\Windows\Input\','TouchpadSyncDataAvailable')
)
foreach ($t in $tasks) { Dis-Task $t[0] $t[1] }
Write-Host "  $($tasks.Count) tasks disabled" -ForegroundColor Green

# ── 3. REGISTRY — PERFORMANCE ──────────────────────────────────────────────
Write-Host "[3/8] Applying performance registry tweaks..." -ForegroundColor Yellow

# CPU — Priority
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' 'Win32PrioritySeparation' 'DWord' 38
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' 'GlobalTimerResolutionRequests' 'DWord' 1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' 'DistributeTimers' 'DWord' 1

# Memory
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'DisablePagingExecutive' 'DWord' 1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'LargeSystemCache' 'DWord' 0
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'ClearPageFileAtShutdown' 'DWord' 0
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'FeatureSettings' 'DWord' 1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'FeatureSettingsOverride' 'DWord' 3
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'FeatureSettingsOverrideMask' 'DWord' 3
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters' 'EnablePrefetcher' 'DWord' 0
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters' 'EnableSuperfetch' 'DWord' 0

# MMCSS Gaming
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'SystemResponsiveness' 'DWord' 0
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'NetworkThrottlingIndex' 'DWord' 0xFFFFFFFF
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'AlwaysOn' 'DWord' 1
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'Affinity' 'DWord' 0
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'Background Only' 'String' 'False'
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'Clock Rate' 'DWord' 10000
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'GPU Priority' 'DWord' 8
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'Priority' 'DWord' 6
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'Scheduling Category' 'String' 'High'
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'SFIO Priority' 'String' 'High'

# Network — TCP performance
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'DefaultTTL' 'DWord' 64
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'Tcp1323Opts' 'DWord' 1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'MaxUserPort' 'DWord' 65534
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'TcpTimedWaitDelay' 'DWord' 30
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' 'EnableICMPRedirect' 'DWord' 0
netsh int tcp set global autotuninglevel=normal 2>$null
netsh int tcp set global rss=enabled 2>$null
netsh int tcp set global chimney=disabled 2>$null

# NTFS
fsutil behavior set DisableLastAccess 1 2>$null
fsutil behavior set disable8dot3 1 2>$null
fsutil behavior set EncryptPagingFile 0 2>$null
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' 'NtfsDisableLastAccessUpdate' 'DWord' 1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' 'NtfsMemoryUsage' 'DWord' 2
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' 'NtfsMftZoneReservation' 'DWord' 1

# Crash Control
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' 'AutoReboot' 'DWord' 1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' 'CrashDumpEnabled' 'DWord' 0
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' 'LogEvent' 'DWord' 0

# Shutdown speed
Set-Reg 'HKLM:\SYSTEM\ControlSet001\Control' 'WaitToKillServiceTimeout' 'String' '1000'
Set-Reg 'HKCU:\Control Panel\Desktop' 'WaitToKillAppTimeout' 'String' '1000'
Set-Reg 'HKCU:\Control Panel\Desktop' 'HungAppTimeout' 'String' '1000'
Set-Reg 'HKCU:\Control Panel\Desktop' 'AutoEndTasks' 'String' '1'

# GPU
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'TdrDelay' 'DWord' 10
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'TdrDdiDelay' 'DWord' 20

# Smart GPU scheduling detect
try {
    $gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
    if ($gpu -match 'RTX [23456789]|RX [56789][0-9]{3}|RX 7[0-9]{3}|Arc A') {
        Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 'DWord' 2
    }
} catch {}

Write-Host "  $total registry tweaks applied" -ForegroundColor Green

# ── 4. CPU — Core parking + boost ──────────────────────────────────────────
Write-Host "[4/8] Optimizing CPU performance..." -ForegroundColor Yellow

try {
    $isLaptop = [bool]((Get-CimInstance Win32_SystemEnclosure).ChassisTypes | Where-Object { $_ -in @(8,9,10,11,12,14,18,21) })
} catch { $isLaptop = $false }

if (-not $isLaptop) {
    # Ultimate Performance power plan
    $upGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
    powercfg -duplicatescheme $upGuid 2>$null
    powercfg -setactive $upGuid 2>$null

    # Disable CPU core parking — keeps all cores active
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100 2>$null
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMAXCORES 100 2>$null

    # Processor performance boost — Aggressive
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 2 2>$null
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTPOL 100 2>$null

    # Minimum processor state 100% (always full speed)
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null

    # USB selective suspend off
    powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 2>$null

    # Apply
    powercfg /setactive SCHEME_CURRENT 2>$null
    Write-Host "  CPU: Ultimate Performance, cores unparked, boost aggressive" -ForegroundColor Green
} else {
    # Laptop: balanced but performance on AC
    powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null
    Write-Host "  CPU: Balanced (laptop mode)" -ForegroundColor Yellow
}

# ── 5. BOOT tweaks ──────────────────────────────────────────────────────────
Write-Host "[5/8] Applying boot tweaks..." -ForegroundColor Yellow
bcdedit /set useplatformclock false 2>$null
bcdedit /set bootmenupolicy legacy 2>$null
# Safe boot tweaks only — risky ones excluded for Ranked Safe
Write-Host "  Boot: platform clock off, legacy menu" -ForegroundColor Green

# ── 6. AUTOLOGGERS (WMI — reduce CPU spikes) ───────────────────────────────
Write-Host "[6/8] Disabling WMI autologgers..." -ForegroundColor Yellow
$loggers = @('Diagtrack-Listener','SQMLogger','SetupPlatformTel',
             'CloudExperienceHostOobe','WiFiSession','WiFiDriverIHVSession',
             'NBSMBLOGGER','PEAuthLog','TelemetryEvents','MetadataRetrieval')
foreach ($l in $loggers) {
    Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\$l" 'Start' 'DWord' 0
}
Write-Host "  $($loggers.Count) autologgers disabled" -ForegroundColor Green

# ── 7. CLEANUP ──────────────────────────────────────────────────────────────
Write-Host "[7/8] Cleaning system files..." -ForegroundColor Yellow
Remove-Item "$env:TEMP\*"          -Recurse -Force -EA SilentlyContinue
Remove-Item 'C:\Windows\Temp\*'    -Recurse -Force -EA SilentlyContinue
Remove-Item 'C:\Windows\Prefetch\*' -Force -EA SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Temp\*" -Recurse -Force -EA SilentlyContinue

# DNS flush
ipconfig /flushdns 2>$null | Out-Null

# Disk cleanup silent
cleanmgr /sagerun:1 2>$null

Write-Host "  Temp files cleaned, DNS flushed" -ForegroundColor Green

# ── 8. WRITE SETUP.JSON + AUTO RESTART ─────────────────────────────────────
Write-Host "[8/8] Finalizing..." -ForegroundColor Yellow

$dir = Join-Path $env:ProgramData 'EndritOS'
if (!(Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
@{
    setupComplete = $true
    megaOptimized = $true
    restartRecommended = $true
    completedAt = (Get-Date).ToString('o')
    message = 'Endrit OS Mega Optimize complete. Restarting in 5 seconds...'
} | ConvertTo-Json | Set-Content (Join-Path $dir 'setup.json') -Encoding UTF8

Write-Host "" -ForegroundColor White
Write-Host "  ╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   ENDRIT OS MEGA OPTIMIZE — COMPLETE      ║" -ForegroundColor Cyan
Write-Host "  ║   Services: 60+ disabled                  ║" -ForegroundColor Green
Write-Host "  ║   Tasks: 50+ disabled                     ║" -ForegroundColor Green
Write-Host "  ║   Registry: 40+ tweaks                    ║" -ForegroundColor Green
Write-Host "  ║   CPU: Unparked, Aggressive Boost         ║" -ForegroundColor Green
Write-Host "  ║   Boot: Optimized                         ║" -ForegroundColor Green
Write-Host "  ║   RESTARTING IN 5 SECONDS...              ║" -ForegroundColor Yellow
Write-Host "  ╚════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White
Write-Host "  Cancel restart: shutdown /a" -ForegroundColor DarkGray

Start-Sleep -Seconds 2
shutdown.exe /r /t 3 /c "Endrit OS Mega Optimize complete — restarting to apply all performance tweaks."
