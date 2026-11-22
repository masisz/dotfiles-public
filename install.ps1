#Requires -Version 5.1
<#
.SYNOPSIS
    Symlink installer for dotfiles-public on Windows (without GNU Stow).

.DESCRIPTION
    Creates or updates per-file symlinks from this repository into $HOME (and
    %APPDATA% for Windows-native apps such as Zellij, plus $PROFILE for PowerShell).
    Safely replaces old directory symlinks/junctions and backs up existing
    regular files before creating new symlinks.

    Creating symlinks on Windows requires either:
      - Windows Developer Mode enabled (Settings > System > For developers), OR
      - Running PowerShell as Administrator.

.EXAMPLE
    .\install.ps1 -DryRun
    .\install.ps1
    .\install.ps1 -Packages wezterm, starship
    .\install.ps1 -Unlink
#>

[CmdletBinding()]
param(
    [string[]]$Packages,
    [switch]$DryRun,
    [switch]$Unlink,
    [switch]$NoBackup,
    [switch]$List
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$DotfilesDir = $PSScriptRoot
$BackupRoot = Join-Path $HOME '.dotfiles_backup'
$Timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$BackupDir = Join-Path $BackupRoot $Timestamp

# Default packages relevant to native Windows (Unix/WSL packages are managed via install.zsh)
$DefaultWindowsPackages = @('wezterm', 'starship', 'powershell', 'git', 'zellij')

# Counters & state
$script:CountLinked = 0
$script:CountUpdated = 0
$script:CountSkipped = 0
$script:CountBackedUp = 0
$script:CountUnlinked = 0
$script:SeenUnlinkedDirs = @{}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO]   $Message"
}

function Write-Action {
    param(
        [string]$Tag,
        [string]$Message
    )
    if ($DryRun) {
        Write-Host ("[DRYRUN] {0,-10} {1}" -f $Tag, $Message)
    } else {
        Write-Host ("[{0,-6}] {1}" -f $Tag, $Message)
    }
}

function Write-WarnMsg {
    param([string]$Message)
    Write-Warning $Message
}

function Get-DiscoveredPackages {
    $result = @()
    foreach ($dir in (Get-ChildItem -Path $DotfilesDir -Directory -Force)) {
        if ($dir.Name.StartsWith('.')) {
            continue
        }
        $hasDot = $false
        foreach ($child in (Get-ChildItem -Path $dir.FullName -Force)) {
            if ($child.Name.StartsWith('.')) {
                $hasDot = $true
                break
            }
        }
        if ($hasDot) {
            $result += $dir.Name
        }
    }
    return $result
}

function Test-IgnoredRelPath {
    param([string]$RelPath)
    $name = Split-Path -Path $RelPath -Leaf
    if ($name -eq '.DS_Store' -or $name -like '*.swp' -or $name -like '*.bak' -or $name -like '*~') {
        return $true
    }
    $norm = $RelPath -replace '\\', '/'
    if ($norm -eq '.config/tmux/plugins' -or $norm -like '.config/tmux/plugins/*') {
        return $true
    }
    return $false
}

function Resolve-DestinationPath {
    param(
        [string]$Package,
        [string]$RelPath
    )
    $norm = $RelPath -replace '\\', '/'

    # Map Windows-native apps that use non-~/.config paths
    if ($Package -eq 'zellij' -and $norm -like '.config/zellij/*') {
        $sub = $norm.Substring('.config/zellij/'.Length) -replace '/', '\'
        if ($env:ZELLIJ_CONFIG_DIR) {
            return Join-Path $env:ZELLIJ_CONFIG_DIR $sub
        }
        if ($env:APPDATA) {
            return Join-Path (Join-Path $env:APPDATA 'Zellij') $sub
        }
    }
    if ($Package -eq 'powershell' -and $norm -eq '.config/powershell/Microsoft.PowerShell_profile.ps1') {
        return $PROFILE
    }

    $winRel = $norm -replace '/', '\'
    return Join-Path $HOME $winRel
}

function Test-IsReparsePoint {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }
    $item = Get-Item -LiteralPath $Path -Force
    return (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
}

function Get-ReparseTargetFullPath {
    param([string]$Path)
    $item = Get-Item -LiteralPath $Path -Force
    $targetProp = $item.PSObject.Properties['Target']
    if (-not $targetProp) {
        return $null
    }
    $rawTarget = $targetProp.Value
    if ($rawTarget -is [array]) {
        $rawTarget = $rawTarget[0]
    }
    if ([string]::IsNullOrEmpty($rawTarget)) {
        return $null
    }
    if ([System.IO.Path]::IsPathRooted($rawTarget)) {
        return [System.IO.Path]::GetFullPath($rawTarget)
    }
    $parent = Split-Path -Path $Path -Parent
    return [System.IO.Path]::GetFullPath((Join-Path $parent $rawTarget))
}

function Remove-ReparsePointSafely {
    param([string]$Path)
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.PSIsContainer) {
        # Safe on Windows PowerShell 5.1: removes only the link/junction, never its target contents
        [System.IO.Directory]::Delete($Path, $false)
    } else {
        [System.IO.File]::Delete($Path)
    }
}

function Ensure-RealParentDirectory {
    param([string]$TargetDir)

    $fullTarget = [System.IO.Path]::GetFullPath($TargetDir)
    $root = [System.IO.Path]::GetPathRoot($fullTarget)
    $rest = $fullTarget.Substring($root.Length)
    if ([string]::IsNullOrEmpty($rest)) {
        return
    }

    $current = $root
    foreach ($part in ($rest -split '[\\/]')) {
        if ([string]::IsNullOrEmpty($part)) {
            continue
        }
        $current = Join-Path $current $part
        if (Test-Path -LiteralPath $current) {
            if (Test-IsReparsePoint -Path $current) {
                if (-not $script:SeenUnlinkedDirs.ContainsKey($current)) {
                    $oldTarget = Get-ReparseTargetFullPath -Path $current
                    Write-Action 'REPL-DIR' "$current (symlink -> $oldTarget) -> real directory"
                    $script:SeenUnlinkedDirs[$current] = $true
                    if (-not $DryRun) {
                        Remove-ReparsePointSafely -Path $current
                        New-Item -ItemType Directory -Path $current -Force | Out-Null
                    }
                }
            } elseif (-not (Test-Path -LiteralPath $current -PathType Container)) {
                throw "Cannot create directory because a file exists at: $current"
            }
        } else {
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $current -Force | Out-Null
            }
        }
    }
}

function Test-HasUnlinkedAncestor {
    param([string]$Path)
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    foreach ($dir in $script:SeenUnlinkedDirs.Keys) {
        $prefix = $dir.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
        if ($fullPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

function Backup-ExistingPath {
    param(
        [string]$Dest,
        [string]$Package,
        [string]$RelPath
    )
    $winRel = $RelPath -replace '/', '\'
    $backupPath = Join-Path (Join-Path $BackupDir $Package) $winRel
    Write-Action 'BACKUP' "$Dest -> $backupPath"
    if (-not $DryRun) {
        $backupParent = Split-Path -Path $backupPath -Parent
        if (-not (Test-Path -LiteralPath $backupParent)) {
            New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
        }
        Move-Item -LiteralPath $Dest -Destination $backupPath -Force
    }
    $script:CountBackedUp++
}

function New-FileSymlink {
    param(
        [string]$Src,
        [string]$Dest
    )
    try {
        New-Item -ItemType SymbolicLink -Path $Dest -Target $Src -Force | Out-Null
    } catch {
        $msg = $_.Exception.Message
        if ($msg -match 'privilege|denied|Unauthorized|権限') {
            Write-Host ''
            Write-Host '[ERROR] Failed to create symbolic link due to insufficient privileges.' -ForegroundColor Red
            Write-Host '        Enable Windows Developer Mode (Settings > System > For developers),' -ForegroundColor Yellow
            Write-Host '        or re-run this script in an elevated (Administrator) PowerShell.' -ForegroundColor Yellow
        }
        throw
    }
}

function Invoke-LinkFile {
    param(
        [string]$Src,
        [string]$Package,
        [string]$RelPath
    )
    $dest = Resolve-DestinationPath -Package $Package -RelPath $RelPath
    $destParent = Split-Path -Path $dest -Parent
    $fullSrc = [System.IO.Path]::GetFullPath($Src)

    Ensure-RealParentDirectory -TargetDir $destParent

    if ($DryRun -and (Test-HasUnlinkedAncestor -Path $dest)) {
        Write-Action 'LINK' "$dest -> $fullSrc"
        $script:CountLinked++
        return
    }

    if (Test-Path -LiteralPath $dest) {
        if (Test-IsReparsePoint -Path $dest) {
            $existingTarget = Get-ReparseTargetFullPath -Path $dest
            if ($existingTarget -and ($existingTarget.Equals($fullSrc, [System.StringComparison]::OrdinalIgnoreCase))) {
                Write-Action 'SKIP' "$dest (already linked)"
                $script:CountSkipped++
                return
            }
            Write-Action 'UPDATE' "$dest (was -> $existingTarget) -> $fullSrc"
            if (-not $DryRun) {
                Remove-ReparsePointSafely -Path $dest
                New-FileSymlink -Src $fullSrc -Dest $dest
            }
            $script:CountUpdated++
            return
        }

        if ($NoBackup) {
            Write-Action 'REMOVE' "$dest (-NoBackup)"
            if (-not $DryRun) {
                Remove-Item -LiteralPath $dest -Recurse -Force
            }
        } else {
            Backup-ExistingPath -Dest $dest -Package $Package -RelPath $RelPath
        }
    }

    Write-Action 'LINK' "$dest -> $fullSrc"
    if (-not $DryRun) {
        New-FileSymlink -Src $fullSrc -Dest $dest
    }
    $script:CountLinked++
}

function Invoke-UnlinkFile {
    param(
        [string]$Src,
        [string]$Package,
        [string]$RelPath
    )
    $dest = Resolve-DestinationPath -Package $Package -RelPath $RelPath
    $fullSrc = [System.IO.Path]::GetFullPath($Src)

    if ((Test-Path -LiteralPath $dest) -and (Test-IsReparsePoint -Path $dest)) {
        $existingTarget = Get-ReparseTargetFullPath -Path $dest
        if ($existingTarget -and ($existingTarget.Equals($fullSrc, [System.StringComparison]::OrdinalIgnoreCase))) {
            Write-Action 'UNLINK' $dest
            if (-not $DryRun) {
                Remove-ReparsePointSafely -Path $dest
            }
            $script:CountUnlinked++
            return
        }
    }

    Write-Action 'SKIP' "$dest (not linked to this repo)"
    $script:CountSkipped++
}

function Invoke-ProcessPackage {
    param([string]$Package)

    $pkgDir = Join-Path $DotfilesDir $Package
    if (-not (Test-Path -LiteralPath $pkgDir -PathType Container)) {
        Write-WarnMsg "Package directory not found: $Package"
        return
    }

    Write-Info "Package: $Package"
    $files = Get-ChildItem -Path $pkgDir -File -Recurse -Force
    if (-not $files) {
        Write-WarnMsg "No files found in package: $Package"
        return
    }

    $prefix = $pkgDir.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    foreach ($file in $files) {
        $rel = $file.FullName.Substring($prefix.Length)
        if (Test-IgnoredRelPath -RelPath $rel) {
            continue
        }
        if ($Unlink) {
            Invoke-UnlinkFile -Src $file.FullName -Package $Package -RelPath $rel
        } else {
            Invoke-LinkFile -Src $file.FullName -Package $Package -RelPath $rel
        }
    }
}

# --- Main ---
$allPackages = @(Get-DiscoveredPackages)

if ($List) {
    $allPackages | ForEach-Object { Write-Output $_ }
    exit 0
}

$targetPackages = @()
if ($Packages -and $Packages.Count -gt 0) {
    $targetPackages = $Packages
} else {
    foreach ($pkg in $allPackages) {
        if ($DefaultWindowsPackages -contains $pkg) {
            $targetPackages += $pkg
        }
    }
}

if ($targetPackages.Count -eq 0) {
    Write-WarnMsg "No matching Windows packages found in $DotfilesDir"
    exit 1
}

Write-Info "Repository: $DotfilesDir"
Write-Info "Target HOME: $HOME"
if ($DryRun) {
    Write-Info 'Mode: dry-run (no changes will be made)'
}

foreach ($pkg in $targetPackages) {
    Invoke-ProcessPackage -Package $pkg
}

Write-Host ''
if ($Unlink) {
    Write-Info "Done. unlinked=$($script:CountUnlinked), skipped=$($script:CountSkipped)"
} else {
    Write-Info "Done. linked=$($script:CountLinked), updated=$($script:CountUpdated), skipped=$($script:CountSkipped), backed_up=$($script:CountBackedUp)"
    if (($script:CountBackedUp -gt 0) -and (-not $DryRun)) {
        Write-Info "Backups saved to: $BackupDir"
    }
}
