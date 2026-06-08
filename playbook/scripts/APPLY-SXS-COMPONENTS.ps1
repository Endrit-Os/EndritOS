# Endrit OS v2.4 — SXS / Optional Windows features removal
# Based on Atlas-OS win-sxs.yml patterns (GPL-3.0)
$ErrorActionPreference = 'SilentlyContinue'

Write-Host "Endrit OS v2.4: Removing optional Windows components (SXS)..." -ForegroundColor Cyan

$removeFeatures = @(
    # Internet Explorer / MSHTML
    'Internet-Explorer-Optional-amd64',
    # Legacy media
    'MediaPlayback',
    'WindowsMediaPlayer',
    # Remote assistance
    'DirectPlay',
    # Tablet / inking (optional, skip if needed)
    # 'TabletPCOC',
    # Work Folders
    'WorkFolders-Client',
    # XPS / legacy printing
    'Printing-XPSServices-Features',
    'Printing-Foundation-InternetPrinting-Client',
    # Legacy help
    'WindowsHelpProgram',
    # Math recognizer
    'MathRecognizer'
)

foreach ($f in $removeFeatures) {
    $state = Get-WindowsOptionalFeature -Online -FeatureName $f -ErrorAction SilentlyContinue
    if ($state -and $state.State -eq 'Enabled') {
        Disable-WindowsOptionalFeature -Online -FeatureName $f -NoRestart -ErrorAction SilentlyContinue
        Write-Host "  Removed: $f" -ForegroundColor DarkGray
    }
}

# DISM: remove Windows capabilities (AI / copilot / Edge WebExperience)
$removeCaps = @(
    'Microsoft.Windows.Ai.Copilot.Provider~~~~0.0.1.0',
    'App.Support.QuickAssist~~~~0.0.1.0',
    'MathRecognizer~~~~0.0.1.0',
    'Microsoft.Windows.WordPad~~~~',
    'OneCoreUAP.OneSync~~~~0.0.1.0'
)

foreach ($cap in $removeCaps) {
    Remove-WindowsCapability -Online -Name $cap -ErrorAction SilentlyContinue | Out-Null
    Write-Host "  Removed capability: $cap" -ForegroundColor DarkGray
}

Write-Host "Endrit OS v2.4: SXS component removal complete." -ForegroundColor Green
