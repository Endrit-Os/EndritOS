# Endrit OS v2.5.0

**The biggest technical jump yet — deeper tweaks, 9.6 security hardening, smarter compatibility.**

Windows 11 build 26100 / 26200 · Ranked Safe · anti-cheat compatible · free & open-source.

## Highlights

### Tweaks / Technik (→ 9.5/10)
- **MSI mode** — Message Signaled Interrupts enabled on the GPU for lower interrupt latency
- **Per-game CPU priority** — VALORANT, CS2, Apex, R6, Fortnite, LoL run at High priority via IFEO
- **Fewer processes** — services consolidated into shared svchost (`SvcHostSplitThresholdInKB`)
- **Power throttling off** (desktop) — no foreground thread down-clocking
- **Fault-Tolerant Heap off**, network latency stack (ECN/RSC/timestamps off, ack tuned)
- MMCSS, HAGS (smart-detected), MPO fix, core parking off, global timer resolution

### Security hardening (→ 9.6/10)
- **5 ASR rules** (LSASS, email-exec, Office child, JS/VBS-exec, obfuscated scripts)
- **Exploit protection system-wide** — DEP, ASLR (bottom-up + high-entropy), CFG, SEHOP
- **WDigest off** (anti-Mimikatz), **NTLMv2-only**, no LM hash
- **SMBv1 off**, **SMB signing required**, insecure guest auth off
- **AutoRun/AutoPlay off**, **SmartScreen on**, **DNS-over-HTTPS**
- **PowerShell script-block logging** + legacy v2 engine off
- **LSA protection (RunAsPPL)** when Secure Boot is on
- NetBIOS / mDNS / LLMNR off, RDP off, Defender cloud High + PUA + network protection

### Compatibility (target ~95%)
- Smart hardware detection (AMD/Intel, laptop, old/iGPU, RAM tier, WiFi)
- Automatically reverts MSI mode, svchost merge and FTH on problematic hardware
- Ensures anti-cheat-critical services stay running (BFE, firewall, Defender, EventLog, CryptSvc)
- Laptops keep power throttling + balanced plan; low-RAM keeps prefetch/SysMain

### Toolbox
- Native WinUI 3 desktop app (.exe) — not a localhost web page
- 8 sections, 35+ live toggles, hardware compatibility pre-check, auto-update via GitHub Releases

## Fixed
- **Critical:** 11 playbook scripts had a UTF-8 encoding issue (box-drawing / em-dash without BOM) that would crash on Windows PowerShell 5.1. All re-saved as UTF-8 with BOM and parse-verified.
- Website: Toolbox now correctly described as a desktop .exe (was "localhost"), clickable everywhere.

## Install
1. Download **AME Beta** from amelabs.net
2. Download **EndritOS-v2.5.0.apbx** and open it in AME Wizard (no password to type)
3. Choose **Ranked Safe** (recommended), apply, restart
4. Open Endrit Toolbox → Competitive → Verify (target 8/10+)

Always test in a VM first. A System Restore point is created automatically.

## Checksums
SHA256 (EndritOS-v2.5.0.apbx): `3E54C52562222FCDCB6BC2062FF569E46D2C86290B356FC1147957F81F0B06FA`
