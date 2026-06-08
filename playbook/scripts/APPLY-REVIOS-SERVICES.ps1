# Endrit OS v2.4 — Services from ReviOS playbook (merged)
# Source: github.com/meetrevision/playbook (CC-BY-SA 4.0)
$ErrorActionPreference = 'SilentlyContinue'

$disable = @(
    # Telemetry / Diagnostics
    'DiagTrack',          # Unified Telemetry Client
    'WerSvc',             # Windows Error Reporting
    'WdiServiceHost',     # Diagnostic Service Host
    'WdiSystemHost',      # Diagnostic System Host
    'PcaSvc',             # Program Compatibility Assistant
    'diagnosticshub.standardcollector.service',
    'wisvc',              # Windows Insider Service
    'UCPD',               # UCPD velocity
    # Xbox / Gaming telemetry
    'XblAuthManager', 'XblGameSave', 'XboxGipSvc', 'XboxNetApiSvc',
    # Location / Sensors
    'lfsvc', 'SensorDataService', 'SensrSvc', 'SensorService',
    # Misc bloat
    'MapsBroker', 'RetailDemo', 'WMPNetworkSvc', 'RemoteRegistry',
    'PrintNotify', 'SmsRouter', 'CDPSvc', 'PhoneSvc', 'WpnService',
    'WpcMonSvc', 'WalletService', 'SEMgrSvc', 'SharedRealitySvc',
    'spectrum', 'stisvc', 'WiaRpc', 'FrameServer', 'FrameServerMonitor',
    'Autotimesvc', 'DevicePickerUserSvc_*', 'MessagingService_*',
    'PimIndexMaintenanceSvc_*', 'UnistoreSvc_*', 'UserDataSvc_*',
    'WpnUserService_*', 'cbdhsvc_*',
    # Power / Energy
    'dam',                # Desktop Activity Moderator
    'GpuEnergyDrv',
    # Network
    'NetBT', 'Wecsvc',
    # Intel telemetry
    'Telemetry'
)

$count = 0
foreach ($name in $disable) {
    Get-Service -Name $name -ErrorAction SilentlyContinue | ForEach-Object {
        Set-Service -Name $_.Name -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name $_.Name -Force -ErrorAction SilentlyContinue
        $count++
    }
}

# condrv must be Automatic (fixes error 0xd000003a)
Set-Service -Name 'condrv' -StartupType Automatic -ErrorAction SilentlyContinue
# EdgeUpdate manual (breaks WebView if disabled)
Set-Service -Name 'edgeupdate' -StartupType Manual -ErrorAction SilentlyContinue

# Disable UCPD scheduled task
Disable-ScheduledTask -TaskPath '\Microsoft\Windows\AppxDeploymentClient' -TaskName 'UCPD velocity' -ErrorAction SilentlyContinue

Write-Host "Endrit OS: Disabled $count background services (ReviOS pattern)." -ForegroundColor Cyan
