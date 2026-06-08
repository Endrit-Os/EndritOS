# Endrit OS — Test VM

Test the playbook safely in a virtual machine before applying it to your real PC.

Your PC runs **Windows 11 Home**, so Hyper-V Manager isn't available — we use
**VirtualBox 7**, which supports the TPM 2.0 + Secure Boot that Windows 11 (and
Vanguard) require.

## Quick start

1. **Download a Windows 11 ISO**
   https://www.microsoft.com/software-download/windows11 (select "Windows 11 (multi-edition ISO)").

2. **Run the setup script** (normal PowerShell):
   ```powershell
   cd C:\Users\abu46\EndritOS\vm
   powershell -ExecutionPolicy Bypass -File .\SETUP-TEST-VM.ps1 -IsoPath "C:\Users\abu46\Downloads\Win11.iso"
   ```
   This installs VirtualBox (if missing), creates `EndritOS-Test`
   (4 vCPU / 8 GB RAM / 80 GB disk, EFI + TPM 2.0 + Secure Boot) and boots the ISO.

3. **Install Windows 11** inside the VM (build 26100+).

4. **Take a clean snapshot** so you can re-test instantly:
   ```powershell
   & "$env:ProgramFiles\Oracle\VirtualBox\VBoxManage.exe" snapshot EndritOS-Test take clean
   ```

5. **Copy in and run the playbook**
   - AME Wizard (from amelabs.net)
   - `EndritOS-v2.4.0.apbx`
   - Apply the **Ranked Safe** profile.

6. **Verify** after reboot:
   - System boots cleanly
   - Endrit Toolbox launches as a desktop `.exe`
   - Toolbox → Competitive → Verify scores 8/10+

## Reset between tests

```powershell
& "$env:ProgramFiles\Oracle\VirtualBox\VBoxManage.exe" snapshot EndritOS-Test restore clean
```

## What to watch for

- **Boot loop / BSOD** → a boot tweak is incompatible; `APPLY-SAFE-COMPATIBILITY.ps1` reverts these.
- **Vanguard "VAN 1067"** → Secure Boot must be ON (it is, in this VM).
- **No audio** → expected (`--audio-driver none` for cleaner testing).
