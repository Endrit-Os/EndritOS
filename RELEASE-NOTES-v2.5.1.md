# Endrit OS v2.5.1

The biggest technical release yet. Free, open-source, anti-cheat compatible.

## What's new in 2.5.1
- **MAX tweak layer** (`endrit-max.yml`, ~30 tweaks): memory management (DisablePagingExecutive, IoPageLockLimit, LargeSystemCache off), NTFS tuning, kernel timer serialization, GPU TDR, crash-dump off, scheduled defrag off.
- **Deeper privacy**: ink/typing personalization off, advertising ID off, activity feed/timeline off, web search & Bing off in Start.

## Carried from 2.5.0
- **Tweaks 9.5/10** — MSI mode on GPU, per-game CPU priority (Valorant/CS2/Apex/R6/Fortnite/LoL), svchost consolidation (fewer processes), power throttling off, network latency stack.
- **Security 9.6/10** — 5 ASR rules, exploit protection system-wide (DEP/ASLR/CFG/SEHOP), WDigest off, NTLMv2-only, SMB signing, SMBv1 off, AutoRun off, SmartScreen on, DNS-over-HTTPS, PowerShell logging, LSA protection.
- **Compatibility ~95%** — smart hardware detection + auto-revert of risky tweaks; anti-cheat-critical services guaranteed running.
- **Toolbox** — native WinUI 3 desktop `.exe`, auto-update via GitHub Releases.
- **Fixed** — 11 scripts had a UTF-8/BOM bug that could crash on PowerShell 5.1; all corrected.

## Install
1. Download AME Beta from amelabs.net
2. Download `EndritOS-v2.5.1.apbx` and open it in AME Wizard (no password to type)
3. Choose **Ranked Safe**, apply, restart
4. Open Endrit Toolbox → Competitive → Verify (target 8/10+)

Always test in a VM first. A System Restore point is created automatically.
