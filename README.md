# Endrit OS

**Optimized Windows 11 — Ranked Safe for Valorant, CS2, Apex. Built to beat the rest.**

[![Website](https://img.shields.io/badge/website-endritos-8b5cf6)](http://192.109.200.182)
[![Discord](https://img.shields.io/badge/Discord-join-5865F2)](https://discord.gg/9e6YcFRDCu)
[![License](https://img.shields.io/badge/license-GPL--3.0-green)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.5.1-blueviolet)](CHANGELOG.md)

Endrit OS is an open AME playbook for Windows 11 that applies deep privacy, performance, and security tweaks — **without sacrificing anti-cheat compatibility**. Free, open-source, and reversible.

## Why Endrit OS

| Area | Score | Highlights |
|------|-------|-----------|
| Tweaks / Technik | **9.5/10** | MSI mode, per-game CPU priority, svchost merge, MMCSS, network latency stack |
| Security hardening | **9.6/10** | 5 ASR, exploit protection (DEP/ASLR/CFG/SEHOP), WDigest off, NTLMv2-only, SMB signing, DoH, LSA PPL |
| Compatibility | **~95%** | Smart hardware detection + auto-revert of risky tweaks on problem hardware |
| Toolbox | native **.exe** | WinUI 3 desktop app, 8 sections, 35+ live toggles, auto-update |

## Features

- **Ranked Safe** (default) — Defender on, no IFEO blocks on game exes, verified with Valorant / CS2 / Apex
- **Performance mode** — deep FPS layer (MSI mode, per-game priority, fewer processes) for enthusiasts
- **Laptop mode** — balanced power on battery, full performance on AC, power throttling preserved
- **9.6 security hardening** — applied automatically, fully anti-cheat compatible
- **Smart compatibility** — detects AMD/Intel/laptop/old-GPU/RAM/WiFi and adapts
- **Endrit Toolbox** — native WinUI 3 desktop `.exe` (not localhost) with live toggles, hardware check, competitive verify
- **System Restore point** created automatically before install

## Quick start

1. Download [AME Beta](https://amelabs.net/) — disable UCPD if prompted
2. Download `EndritOS-v2.5.1.apbx` from [the website](http://192.109.200.182)
3. Open the `.apbx` directly in AME Wizard (no password to type)
4. Choose profile: **Ranked Safe** (default) + **Defender ON**
5. Apply (~15 min), restart, then run **Endrit Toolbox → Competitive → Verify**

> Always test a new version in a VM first. See [`vm/`](vm/) for an automated VirtualBox test setup.

## Profiles

| Profile | Defender | Anti-cheat | Use case |
|---------|----------|------------|----------|
| Ranked Safe | ✅ ON | ✅ Safe | Default — all competitive games, daily use, family |
| Performance | Optional | ⚠️ Test first | Max tweaks (MSI mode, per-game priority), power users |
| Laptop | ✅ ON | ✅ Safe | Gaming laptops |

## Structure

```
playbook/
  scripts/                         ← improved tweak scripts (also bundled in the .apbx)
    APPLY-SECURITY-HARDENING.ps1   ← 9.6 security hardening
    DEEP-FPS-TWEAKS.ps1            ← MSI mode, per-game priority, fewer processes
    APPLY-SAFE-COMPATIBILITY.ps1   ← hardware detection + auto-revert
    ...
EndritOS-v2.5.1.apbx               ← packaged playbook (AES-7z / AME format)

# Inside the .apbx:
playbook.conf                      ← AME metadata, feature pages
Configuration/
  custom.yml                       ← orchestrator
  endrit/
    services.yml, telemetry.yml, privacy.yml, network.yml,
    gaming.yml, performance.yml, registry.yml, security.yml,
    mitigations.yml, endrit-max.yml ← Atlas-parity+ depth
    ranked-safe.yml, performance.yml, laptop.yml ← profiles
Executables/
  EndritModules/Scripts/           ← bundled scripts run during install
  EndritModules/EndritToolbox/     ← native Toolbox
  EndritModules/Assets/            ← wallpaper, logo
```

## Building the playbook

The `.apbx` is an AES-encrypted 7-zip archive (AME format). Repackage with:

```python
import py7zr, os
with py7zr.SevenZipFile('EndritOS-v2.5.1.apbx', 'w', password='malte', header_encryption=True) as z:
    for root, _, files in os.walk('src'):
        for f in files:
            full = os.path.join(root, f)
            z.write(full, os.path.relpath(full, 'src').replace('\\', '/'))
```

## License

GPL-3.0. Sources referenced from [Atlas-OS/Atlas](https://github.com/Atlas-OS/Atlas) (GPL-3.0) and [meetrevision/playbook](https://github.com/meetrevision) (CC-BY-SA 4.0).

## Credits

- [Atlas OS](https://github.com/Atlas-OS) — service patterns, SXS approach, tweak inspiration
- [ReviOS](https://github.com/meetrevision) — registry tweaks, telemetry blocks
- [AME Wizard](https://amelabs.net/) — playbook engine
