# Endrit OS v2.4 — Wallpaper persistence via logon scheduled task
# Registers a task that re-applies the wallpaper at every user logon,
# so it survives reboots and Windows Update resets.
$ErrorActionPreference = 'Stop'

$dataDir   = Join-Path $env:ProgramData 'EndritOS'
$scriptDir = 'C:\WINDOWS\EndritModules'
$wallScript = Join-Path $scriptDir 'Scripts\APPLY-WALLPAPER.ps1'

if (!(Test-Path $wallScript)) {
    Write-Warning "APPLY-WALLPAPER.ps1 not found at $wallScript"
    exit 1
}

$taskName  = 'EndritOS_WallpaperLogon'
$taskPath  = '\EndritOS\'

Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:$false -ErrorAction SilentlyContinue

$action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$wallScript`""

$trigger  = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 2) `
    -MultipleInstances IgnoreNew `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries
$principal = New-ScheduledTaskPrincipal -GroupId 'BUILTIN\Users' -RunLevel Highest

$task = New-ScheduledTask `
    -Action $action -Trigger $trigger `
    -Settings $settings -Principal $principal `
    -Description 'Endrit OS: Re-applies wallpaper at logon to survive reboots.'

Register-ScheduledTask -TaskName $taskName -TaskPath $taskPath -InputObject $task -Force | Out-Null
Write-Host "Endrit OS: Wallpaper logon task registered." -ForegroundColor Magenta
Start-ScheduledTask -TaskName $taskName -TaskPath $taskPath -ErrorAction SilentlyContinue
Write-Host "Endrit OS: Wallpaper applied immediately." -ForegroundColor Magenta
