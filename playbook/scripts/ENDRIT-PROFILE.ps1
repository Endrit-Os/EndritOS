# Endrit OS - export/import tweak profile (share your config)
# Usage: ENDRIT-PROFILE.ps1 -Mode Export|Import [-Path file.reg]
param(
    [ValidateSet('Export','Import')] [string]$Mode = 'Export',
    [string]$Path
)
$ErrorActionPreference = 'SilentlyContinue'

# Registry roots Endrit tweaks live under (exported as a portable .reg)
$keys = @(
    'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile',
    'HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl',
    'HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers',
    'HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters',
    'HKCU\System\GameConfigStore',
    'HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR'
)

if (-not $Path) {
    $dir = Join-Path $env:ProgramData 'EndritOS'
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $Path = Join-Path $dir 'EndritProfile.reg'
}

if ($Mode -eq 'Export') {
    if (Test-Path $Path) { Remove-Item $Path -Force }
    "Windows Registry Editor Version 5.00`r`n" | Set-Content $Path -Encoding Unicode
    foreach ($k in $keys) {
        $tmp = Join-Path $env:TEMP ("ek_" + ([guid]::NewGuid().ToString('N')) + '.reg')
        reg export $k $tmp /y 2>$null | Out-Null
        if (Test-Path $tmp) {
            # strip the duplicate header line and append
            (Get-Content $tmp | Select-Object -Skip 1) | Add-Content $Path -Encoding Unicode
            Remove-Item $tmp -Force
        }
    }
    Write-Host "Endrit OS: profile exported to $Path" -ForegroundColor Green
}
else {
    if (-not (Test-Path $Path)) { Write-Host "Profile file not found: $Path" -ForegroundColor Red; exit 1 }
    reg import $Path 2>$null | Out-Null
    Write-Host "Endrit OS: profile imported from $Path (restart recommended)" -ForegroundColor Green
}
