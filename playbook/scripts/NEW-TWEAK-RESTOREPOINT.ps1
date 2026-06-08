# Endrit OS - create a System Restore point before applying tweaks
# Called by the Toolbox before any risky change so users can always roll back.
param([string]$Label = 'Endrit OS tweak')
$ErrorActionPreference = 'SilentlyContinue'

try {
    Enable-ComputerRestore -Drive 'C:\' -EA SilentlyContinue

    # Bypass the once-per-24h limit so every tweak can checkpoint
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
    if (!(Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
    Set-ItemProperty -Path $key -Name 'SystemRestorePointCreationFrequency' -Type DWord -Value 0 -EA SilentlyContinue

    Checkpoint-Computer -Description $Label -RestorePointType 'MODIFY_SETTINGS' -EA SilentlyContinue
    Write-Host "Endrit OS: restore point created - '$Label'" -ForegroundColor Green
} catch {
    Write-Host "Endrit OS: could not create restore point ($($_.Exception.Message))" -ForegroundColor Yellow
}
