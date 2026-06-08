# Endrit OS v2.4 — Registry tweaks from ReviOS playbook
# Source: github.com/meetrevision/playbook (CC-BY-SA 4.0)
$ErrorActionPreference = 'SilentlyContinue'

function Set-Reg($path, $name, $type, $value) {
    if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name $name -Type $type -Value $value -ErrorAction SilentlyContinue
}

Write-Host "Endrit OS v2.4: Applying ReviOS registry tweaks..." -ForegroundColor Cyan

# ── Telemetry ────────────────────────────────────────────────────────────────
$dc = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
Set-Reg $dc 'AllowTelemetry'                          'DWord' 0
Set-Reg $dc 'AllowCommercialDataPipeline'             'DWord' 0
Set-Reg $dc 'AllowDeviceNameInTelemetry'              'DWord' 0
Set-Reg $dc 'DisableEnterpriseAuthProxy'              'DWord' 1
Set-Reg $dc 'MicrosoftEdgeDataOptIn'                  'DWord' 0
Set-Reg $dc 'DisableTelemetryOptInChangeNotification' 'DWord' 1
Set-Reg $dc 'DisableTelemetryOptInSettingsUx'         'DWord' 1
Set-Reg $dc 'DoNotShowFeedbackNotifications'          'DWord' 1
Set-Reg $dc 'LimitDiagnosticLogCollection'            'DWord' 1
Set-Reg $dc 'LimitDumpCollection'                     'DWord' 1
Set-Reg $dc 'LimitEnhancedDiagnosticDataWindowsAnalytics' 'DWord' 0
Set-Reg $dc 'AllowBuildPreview'                       'DWord' 0
Set-Reg 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 'DWord' 0
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry' 'DWord' 0
Set-Reg 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection' 'AllowTelemetry' 'DWord' 0
Set-Reg 'HKLM:\SYSTEM\ControlSet001\Control\WMI\Autologger\Diagtrack-Listener' 'Start' 'DWord' 0
Set-Reg 'HKLM:\SYSTEM\ControlSet001\Control\WMI\Autologger\SQMLogger'          'Start' 'DWord' 0
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds' 'EnableConfigFlighting' 'DWord' 0

# ── Privacy ──────────────────────────────────────────────────────────────────
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' 'DWord' 1
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 'DWord' 0
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Input\TIPC' 'Enabled' 'DWord' 0
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SilentInstalledAppsEnabled' 'DWord' 0
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContentEnabled' 'DWord' 0
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'ContentDeliveryAllowed' 'DWord' 0
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'OemPreInstalledAppsEnabled' 'DWord' 0
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'PreInstalledAppsEnabled' 'DWord' 0
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'PreInstalledAppsEverEnabled' 'DWord' 0

# ── Kernel / Performance ──────────────────────────────────────────────────────
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' 'DistributeTimers'       'DWord' 1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' 'GlobalTimerResolutionRequests' 'DWord' 1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' 'Win32PrioritySeparation' 'DWord' 38
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'LargeSystemCache' 'DWord' 0
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' 'DisablePagingExecutive' 'DWord' 1

# ── Boot ─────────────────────────────────────────────────────────────────────
bcdedit /set useplatformclock false 2>$null
bcdedit /set useplatformtick  true  2>$null
bcdedit /set disabledynamictick on  2>$null
bcdedit /set tscsyncpolicy enhanced 2>$null
bcdedit /set bootmenupolicy legacy   2>$null

# ── Crash control ─────────────────────────────────────────────────────────────
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' 'AutoReboot'     'DWord' 1
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' 'CrashDumpEnabled' 'DWord' 0
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' 'LogEvent'       'DWord' 0

# ── Disable automatic maintenance ────────────────────────────────────────────
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance' 'MaintenanceDisabled' 'DWord' 1

# ── Multimedia / MMCSS ───────────────────────────────────────────────────────
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'SystemResponsiveness'     'DWord' 0
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'NetworkThrottlingIndex'   'DWord' 4294967295
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'Priority'    'DWord' 6
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'Scheduling Category' 'String' 'High'
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'SFIO Priority' 'String' 'High'
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'GPU Priority'  'DWord' 8

# ── Explorer / UI ────────────────────────────────────────────────────────────
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt'       'DWord' 0
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowSyncProviderNotifications' 'DWord' 0
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackProgs'  'DWord' 0
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackEnabled' 'DWord' 0
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 'DWord' 0
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCortanaButton' 'DWord' 0
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch' 'DWord' 1

# ── Notifications ─────────────────────────────────────────────────────────────
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications' 'ToastEnabled' 'DWord' 0
Set-Reg 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'DisableNotificationCenter' 'DWord' 0

# ── Audio ─────────────────────────────────────────────────────────────────────
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'AlwaysOn' 'DWord' 1
Set-Reg 'HKCU:\SOFTWARE\Microsoft\Multimedia\Audio' 'UserDuckingPreference' 'DWord' 3  # do nothing

# ── Updates ───────────────────────────────────────────────────────────────────
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAutoUpdate' 'DWord' 1
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DisableWindowsUpdateAccess' 'DWord' 0

Write-Host "Endrit OS v2.4: ReviOS registry tweaks applied." -ForegroundColor Green
