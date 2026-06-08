# Endrit OS v2.4 — Register wallpaper task + update Toolbox config
# Run as Admin after install
param([switch]$Uninstall)

$taskName = 'EndritOS_WallpaperLogon'
$taskPath = '\EndritOS\'

if ($Uninstall) {
    Unregister-ScheduledTask -TaskName $taskName -TaskPath $taskPath -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "Endrit OS: Wallpaper task removed." -ForegroundColor Yellow
    exit 0
}

# --- Wallpaper persistence ---
& "$PSScriptRoot\SET-WALLPAPER-PERSIST.ps1"

# --- Update config version ---
$cfg = Join-Path $env:ProgramData 'EndritOS\config.json'
if (Test-Path $cfg) {
    $c = Get-Content $cfg -Raw | ConvertFrom-Json
    $c.version = '2.4.0'
    $c | ConvertTo-Json | Set-Content $cfg -Encoding UTF8
    Write-Host "Endrit OS: Config updated to v2.4.0" -ForegroundColor Magenta
}

Write-Host "Endrit OS v2.4 post-install complete." -ForegroundColor Green
