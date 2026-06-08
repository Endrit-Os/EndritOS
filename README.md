# Endrit OS

**Optimized Windows 11 — Ranked Safe for Valorant, CS2, Apex.**

[![Website](https://img.shields.io/badge/website-192.109.200.182-blue)](http://192.109.200.182)
[![Discord](https://img.shields.io/badge/Discord-join-5865F2)](https://discord.gg/endritos)
[![License](https://img.shields.io/badge/license-GPL--3.0-green)](LICENSE)

Endrit OS is an open AME playbook for Windows 11 that applies 500+ privacy, performance, and usability tweaks — without sacrificing anti-cheat compatibility.

## Features

- **Ranked Safe** (default) — Defender on, no IFEO blocks on game exes, verified with Valorant / CS2 / Apex
- **Performance mode** — deeper disables, IFEO telemetry blocks, maximum tweaks
- **Laptop mode** — balanced power plan on battery, high performance on AC
- **AI / Copilot removal** — Copilot, Recall, Windows AI removed via DISM
- **ReviOS + Atlas service patterns** — 40+ services disabled
- **SXS component removal** — Internet Explorer, Media Player, legacy components
- **Endrit Toolbox** — local web app on `127.0.0.1` with toggles, wallpaper, competitive verify
- **System Restore point** created automatically before install

## Quick start

1. Download [AME Beta](https://amelabs.net/) — disable UCPD if prompted
2. Download `EndritOS-v2.4.0.apbx` from [endritos.net](http://192.109.200.182)
3. Open the `.apbx` directly in AME Wizard (no password to type)
4. Choose profile: **Ranked Safe** (default) + **Defender ON**
5. Apply (~15 min), restart, then run **Endrit Toolbox → Competitive → Verify**

## Profiles

| Profile | Defender | Anti-cheat | Use case |
|---------|----------|------------|----------|
| Ranked Safe | ✅ ON | ✅ Safe | Default — all competitive games |
| Performance | Optional | ⚠️ Test first | Max tweaks, power users |
| Laptop | ✅ ON | ✅ Safe | Gaming laptops |

## Structure

```
playbook/
  EndritOS-v2.4.0-src/
    playbook.conf              ← AME metadata + options
    Configuration/
      main.yml                 ← Entry point
      Tasks/
        services.yml           ← 40+ services (ReviOS + Atlas)
        appx.yml               ← APPX removals
        sxs.yml                ← SXS component removal
        registry/
          telemetry.yml        ← Telemetry + firewall blocks
          performance.yml      ← Kernel, MMCSS, boot
          gaming.yml           ← Game DVR, mouse, MMCSS
          explorer.yml         ← UI cleanup
          security.yml         ← Defender, LLMNR, privacy
          privacy.yml          ← Internet communication blocks
        profile-ranked-safe.yml
        profile-performance.yml
        profile-laptop.yml
        finalize.yml
  scripts/
    APPLY-REVIOS-SERVICES.ps1
    APPLY-REVIOS-REGISTRY.ps1
    APPLY-SXS-COMPONENTS.ps1
    SET-WALLPAPER-PERSIST.ps1
```

## License

GPL-3.0. Sources referenced from [Atlas-OS/Atlas](https://github.com/Atlas-OS/Atlas) (GPL-3.0) and [meetrevision/playbook](https://github.com/meetrevision/playbook) (CC-BY-SA 4.0).

## Credits

- [Atlas OS](https://github.com/Atlas-OS) — service patterns, SXS approach
- [ReviOS](https://github.com/meetrevision) — registry tweaks, telemetry blocks
- [AME Wizard](https://amelabs.net/) — playbook engine
