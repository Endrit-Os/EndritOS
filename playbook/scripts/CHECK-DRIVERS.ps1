# Endrit OS - GPU driver age check + guidance -> JSON
param([switch]$Json)
$ErrorActionPreference = 'SilentlyContinue'

$gpus = Get-CimInstance Win32_VideoController | Where-Object { $_.PNPDeviceID -match '^PCI' }
$report = @()
foreach ($g in $gpus) {
    $date = $null
    try { $date = [Management.ManagementDateTimeConverter]::ToDateTime($g.DriverDate) } catch {}
    $ageMonths = if ($date) { [math]::Round(((Get-Date) - $date).TotalDays / 30.0, 1) } else { $null }
    $vendor = switch -Regex ($g.Name) { 'NVIDIA|GeForce|RTX|GTX' {'NVIDIA'} 'Radeon|AMD|RX ' {'AMD'} 'Intel|Arc|UHD|Iris' {'Intel'} default {'Unknown'} }
    $url = switch ($vendor) {
        'NVIDIA' { 'https://www.nvidia.com/Download/index.aspx' }
        'AMD'    { 'https://www.amd.com/en/support' }
        'Intel'  { 'https://www.intel.com/content/www/us/en/download-center/home.html' }
        default  { '' }
    }
    $status = if ($ageMonths -eq $null) { 'unknown' } elseif ($ageMonths -gt 12) { 'outdated' } elseif ($ageMonths -gt 6) { 'aging' } else { 'recent' }
    $report += [ordered]@{
        gpu = $g.Name; vendor = $vendor; driverVersion = $g.DriverVersion
        driverDate = if ($date) { $date.ToString('yyyy-MM-dd') } else { 'unknown' }
        ageMonths = $ageMonths; status = $status; updateUrl = $url
    }
}

$dir = Join-Path $env:ProgramData 'EndritOS'
if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
($report | ConvertTo-Json -Depth 3) | Set-Content (Join-Path $dir 'drivers.json') -Encoding UTF8

if ($Json) { $report | ConvertTo-Json -Depth 3 }
else {
    Write-Host "Endrit OS: GPU driver check" -ForegroundColor Cyan
    foreach ($r in $report) {
        $col = switch ($r.status) { 'outdated' {'Red'} 'aging' {'Yellow'} default {'Green'} }
        Write-Host ("  {0}: {1} ({2}, {3} months) -> {4}" -f $r.gpu, $r.driverVersion, $r.driverDate, $r.ageMonths, $r.status) -ForegroundColor $col
        if ($r.status -eq 'outdated') { Write-Host ("    Update: {0}" -f $r.updateUrl) -ForegroundColor Yellow }
    }
}
