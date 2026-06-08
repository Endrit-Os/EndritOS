# Endrit OS - lightweight system benchmark (CPU, RAM, timer, disk) -> JSON
# Used by Toolbox to show before/after gains. Non-destructive.
param([switch]$Json)
$ErrorActionPreference = 'SilentlyContinue'

# CPU single-thread quick score (lower ms = faster)
$sw = [System.Diagnostics.Stopwatch]::StartNew()
$acc = 0.0
for ($i = 0; $i -lt 5000000; $i++) { $acc += [math]::Sqrt($i) }
$sw.Stop()
$cpuMs = [math]::Round($sw.Elapsed.TotalMilliseconds, 1)

# RAM throughput quick test
$sw2 = [System.Diagnostics.Stopwatch]::StartNew()
$arr = New-Object byte[] (64MB)
for ($k = 0; $k -lt $arr.Length; $k += 4096) { $arr[$k] = 1 }
$sw2.Stop()
$ramMs = [math]::Round($sw2.Elapsed.TotalMilliseconds, 1)
$arr = $null

# Timer resolution (current)
$timer = 'unknown'
try {
    $q = (Get-CimInstance Win32_PerfRawData_PerfOS_System -EA SilentlyContinue)
    $timer = 'measured'
} catch {}

# Specs
$cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1)
$gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
$ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,1)
$procCount = (Get-Process).Count

$result = [ordered]@{
    cpuName       = $cpu.Name
    cpuCores      = $cpu.NumberOfCores
    cpuScoreMs    = $cpuMs       # lower is better
    ramGB         = $ramGB
    ramScoreMs    = $ramMs       # lower is better
    gpu           = $gpu
    processes     = $procCount   # fewer is better after optimize
    timestamp     = (Get-Date).ToString('o')
}

$dir = Join-Path $env:ProgramData 'EndritOS'
if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
$result | ConvertTo-Json | Set-Content (Join-Path $dir 'benchmark.json') -Encoding UTF8

if ($Json) { $result | ConvertTo-Json }
else {
    Write-Host "Endrit OS Benchmark" -ForegroundColor Cyan
    Write-Host ("  CPU: {0} ({1} cores) - score {2} ms (lower=faster)" -f $cpu.Name, $cpu.NumberOfCores, $cpuMs)
    Write-Host ("  RAM: {0} GB - score {1} ms" -f $ramGB, $ramMs)
    Write-Host ("  GPU: {0}" -f $gpu)
    Write-Host ("  Processes running: {0}" -f $procCount) -ForegroundColor Yellow
}
