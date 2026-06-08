# Changelog

All notable changes to Endrit OS. Test every new version in a VM before your main PC.

## [2.5.1] — 2026-06-08
### Added
- **MAX tweak layer** (`endrit-max.yml`): memory management (DisablePagingExecutive, IoPageLockLimit, LargeSystemCache off), NTFS tuning (last-access off, 8.3 off, RefsDisableLastAccessUpdate), kernel timer serialization, GPU TDR delays, crash-dump off, scheduled defrag off.
- **Deeper privacy**: input/ink/typing personalization off, advertising ID off (system + user), activity feed/timeline off, web search & Bing off in Start menu.

## [2.5.0] — 2026-06-08
### Added
- **Deep FPS layer** (`DEEP-FPS-TWEAKS.ps1`): MSI mode on GPU, per-game CPU priority (VALORANT, CS2, Apex, R6, Fortnite, LoL), svchost consolidation (fewer processes), power throttling off (desktop), fault-tolerant heap off, network latency stack (ECN/RSC/timestamps off).
- **9.6 security hardening** (`APPLY-SECURITY-HARDENING.ps1`): 5 ASR rules, exploit protection system-wide (DEP/ASLR/CFG/SEHOP), WDigest off, NTLMv2-only, SMB signing required, SMBv1 off, AutoRun off, SmartScreen on, DNS-over-HTTPS, PowerShell script-block logging, LSA protection (RunAsPPL with Secure Boot).
- **Smart compatibility** (`APPLY-SAFE-COMPATIBILITY.ps1`): hardware detection (AMD/Intel/laptop/old-GPU/RAM/WiFi), auto-revert of risky tweaks, anti-cheat-critical services guaranteed running.
- Scripts wired into Ranked Safe and Performance profiles.
### Fixed
- **Critical:** 11 playbook scripts had a UTF-8 encoding issue (box-drawing/em-dash without BOM) that would crash on Windows PowerShell 5.1. All re-saved as UTF-8 with BOM and parse-verified.
- Website: Toolbox correctly described as a native desktop `.exe` (was "localhost"); clickable everywhere.

## [2.3.x] — 2026-06-07
### Added
- Ranked Safe / Performance / Laptop profiles.
- 8-check Competitive Verify tool.
- Local Toolbox, wallpaper persistence, automatic restore point.
- 500+ base tweaks (Atlas + ReviOS patterns), rebranded to Endrit OS.

[2.5.1]: https://github.com/Endrit-Os/EndritOS/releases/tag/v2.5.1
[2.5.0]: https://github.com/Endrit-Os/EndritOS/releases/tag/v2.5.0
