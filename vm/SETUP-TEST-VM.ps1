# ===========================================================================
# Endrit OS - Test VM setup (VirtualBox 7, Windows 11 Home compatible)
# Creates a Win11-ready VM (EFI + TPM 2.0 + Secure Boot) so you can test the
# playbook safely before touching your real PC.
#
# Usage:
#   1. Download a Windows 11 ISO from microsoft.com/software-download/windows11
#   2. Run (normal PowerShell, NOT admin needed for VBoxManage):
#        powershell -ExecutionPolicy Bypass -File .\SETUP-TEST-VM.ps1 -IsoPath "C:\path\Win11.iso"
#   3. Install Windows in the VM, then copy the playbook + AME Wizard in and test.
# ===========================================================================
param(
    [string]$IsoPath = "",
    [string]$VmName  = "EndritOS-Test",
    [int]$RamMB      = 8192,
    [int]$Cpus       = 4,
    [int]$DiskGB     = 80
)

$ErrorActionPreference = 'Stop'

function Find-VBoxManage {
    $cmd = Get-Command VBoxManage -EA SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $p = Join-Path $env:ProgramFiles 'Oracle\VirtualBox\VBoxManage.exe'
    if (Test-Path $p) { return $p }
    return $null
}

Write-Host "Endrit OS - Test VM setup" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

# --- 1. Ensure VirtualBox is installed ------------------------------------
$vbox = Find-VBoxManage
if (-not $vbox) {
    Write-Host "VirtualBox not found. Installing via winget..." -ForegroundColor Yellow
    winget install --id Oracle.VirtualBox -e --accept-source-agreements --accept-package-agreements
    $vbox = Find-VBoxManage
    if (-not $vbox) {
        Write-Host "VirtualBox install failed. Install it manually from virtualbox.org and re-run." -ForegroundColor Red
        exit 1
    }
}
Write-Host "VBoxManage: $vbox" -ForegroundColor Green

# --- 2. Validate ISO ------------------------------------------------------
if (-not $IsoPath) {
    $found = Get-ChildItem "$env:USERPROFILE\Downloads" -Filter *.iso -EA SilentlyContinue |
             Where-Object { $_.Length -gt 3GB } | Select-Object -First 1
    if ($found) { $IsoPath = $found.FullName; Write-Host "Auto-detected ISO: $IsoPath" -ForegroundColor Green }
}
if (-not $IsoPath -or -not (Test-Path $IsoPath)) {
    Write-Host "No Windows 11 ISO found." -ForegroundColor Red
    Write-Host "Download one from: https://www.microsoft.com/software-download/windows11" -ForegroundColor Yellow
    Write-Host "Then re-run:  .\SETUP-TEST-VM.ps1 -IsoPath `"C:\path\to\Win11.iso`"" -ForegroundColor Yellow
    exit 1
}

# --- 3. Remove any old VM with the same name ------------------------------
$existing = & $vbox list vms | Select-String "`"$VmName`""
if ($existing) {
    Write-Host "Removing existing VM '$VmName'..." -ForegroundColor Yellow
    & $vbox controlvm $VmName poweroff 2>$null
    Start-Sleep 2
    & $vbox unregistervm $VmName --delete 2>$null
}

# --- 4. Create the VM (Win11, EFI, TPM 2.0, Secure Boot) ------------------
Write-Host "Creating VM '$VmName' ($Cpus vCPU, $RamMB MB RAM, $DiskGB GB disk)..." -ForegroundColor Yellow
& $vbox createvm --name $VmName --ostype "Windows11_64" --register

& $vbox modifyvm $VmName `
    --memory $RamMB --cpus $Cpus `
    --firmware efi `
    --tpm-type 2.0 `
    --secure-boot on `
    --graphicscontroller vboxsvga --vram 128 `
    --nested-hw-virt on `
    --rtcuseutc on `
    --nic1 nat `
    --audio-driver none `
    --usbohci on

# Disk
$vmDir = (& $vbox showvminfo $VmName --machinereadable | Select-String '^CfgFile=').ToString().Split('=')[1].Trim('"')
$vmFolder = Split-Path $vmDir
$disk = Join-Path $vmFolder "$VmName.vdi"
& $vbox createmedium disk --filename $disk --size ($DiskGB * 1024) --format VDI

& $vbox storagectl $VmName --name "SATA" --add sata --controller IntelAHCI --portcount 2
& $vbox storageattach $VmName --storagectl "SATA" --port 0 --device 0 --type hdd --medium $disk
& $vbox storageattach $VmName --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium $IsoPath

# Boot order: DVD first for install
& $vbox modifyvm $VmName --boot1 dvd --boot2 disk --boot3 none --boot4 none

# --- 5. Start it ----------------------------------------------------------
Write-Host "Starting VM..." -ForegroundColor Yellow
& $vbox startvm $VmName --type gui

Write-Host ""
Write-Host "Done. The VM is booting from the Windows 11 ISO." -ForegroundColor Green
Write-Host "Next steps inside the VM:" -ForegroundColor Cyan
Write-Host "  1. Install Windows 11 (Pro or Home, build 26100+)." -ForegroundColor White
Write-Host "  2. After first login, copy in: AME Wizard + EndritOS-v2.4.0.apbx." -ForegroundColor White
Write-Host "  3. Run the playbook (Ranked Safe profile), then test boot + Toolbox Verify." -ForegroundColor White
Write-Host "  4. To reset: VBoxManage snapshot $VmName take clean  (take a snapshot before testing)." -ForegroundColor White
