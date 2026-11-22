#Requires -Version 5.1
<#
.SYNOPSIS
    Windows bootstrap script for dotfiles-public using winget.

.DESCRIPTION
    Installs Windows-compatible packages listed in winget-packages.json via winget,
    plus any optional local/extra package files, and clones masisz.nvim into
    %LOCALAPPDATA%\nvim if not already present.

    Local package files (gitignored / machine-specific) are automatically loaded if present:
      1. .\winget-packages.local.json
      2. ~\.winget-packages.local.json

    Local and extra JSON files support either:
      - Standard winget import schema (Sources[].Packages[].PackageIdentifier)
      - Simplified object format: { "packages": ["GitHub.cli", "sharkdp.fd"] }
      - Simplified array format:  ["GitHub.cli", "sharkdp.fd"]

.EXAMPLE
    .\setup-windows.ps1 -InitLocal
    .\setup-windows.ps1 -DryRun
    .\setup-windows.ps1 -Check
    .\setup-windows.ps1
    .\setup-windows.ps1 -ExtraFiles ~\winget-packages.work.json -Link
#>

[CmdletBinding()]
param(
    [string[]]$ExtraFiles,
    [switch]$InitLocal,
    [switch]$DryRun,
    [switch]$Check,
    [switch]$NoLocal,
    [switch]$SkipNvim,
    [switch]$Link
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$DotfilesDir = $PSScriptRoot
$PackageFile = Join-Path $DotfilesDir 'winget-packages.json'
$RepoLocalPackageFile = Join-Path $DotfilesDir 'winget-packages.local.json'
$HomeLocalPackageFile = Join-Path $HOME '.winget-packages.local.json'
$LocalTemplateFile = Join-Path $DotfilesDir 'winget-packages.local.json.example'
$NvimRepoUrl = 'https://github.com/masisz/masisz.nvim.git'
$NvimConfigDir = if ($env:LOCALAPPDATA) { Join-Path $env:LOCALAPPDATA 'nvim' } else { Join-Path $HOME 'AppData\Local\nvim' }

# winget exit code when package is already installed and no upgrade is applicable (0x8A15002B)
$WingetNoUpdateApplicable = -1978335189

$script:CountInstalled = 0
$script:CountSkipped = 0
$script:CountMissing = 0
$script:CountFailed = 0

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

function Initialize-LocalPackageFile {
    if (Test-Path -LiteralPath $HomeLocalPackageFile) {
        Write-Info "Local package file already exists: $HomeLocalPackageFile (not overwritten)"
        return
    }
    if (-not (Test-Path -LiteralPath $LocalTemplateFile -PathType Leaf)) {
        throw "Template not found: $LocalTemplateFile"
    }
    if ($DryRun) {
        Write-Action 'COPY' "$LocalTemplateFile -> $HomeLocalPackageFile"
        return
    }
    Copy-Item -LiteralPath $LocalTemplateFile -Destination $HomeLocalPackageFile
    Write-Info "Created local package file: $HomeLocalPackageFile"
    Write-Info 'Edit it to add machine-specific winget package IDs, then run .\setup-windows.ps1'
}

function Get-PackageIdsFromFile {
    param([string]$FilePath)

    $json = Get-Content -LiteralPath $FilePath -Raw -Encoding UTF8 | ConvertFrom-Json
    $ids = @()

    # Format 1: plain JSON array of package IDs: ["GitHub.cli", ...]
    if ($json -is [array]) {
        foreach ($entry in $json) {
            if ($entry -is [string] -and -not [string]::IsNullOrWhiteSpace($entry)) {
                $ids += $entry.Trim()
            }
        }
        return $ids
    }

    # Format 2: simplified object: { "packages": ["GitHub.cli", ...] }
    if ($json.PSObject.Properties['packages'] -and $json.packages) {
        foreach ($entry in $json.packages) {
            if ($entry -is [string] -and -not [string]::IsNullOrWhiteSpace($entry)) {
                $ids += $entry.Trim()
            } elseif ($entry.PSObject.Properties['PackageIdentifier'] -and $entry.PackageIdentifier) {
                $ids += ([string]$entry.PackageIdentifier).Trim()
            }
        }
        return $ids
    }

    # Format 3: official winget import schema (Sources[].Packages[].PackageIdentifier)
    if ($json.PSObject.Properties['Sources'] -and $json.Sources) {
        foreach ($source in $json.Sources) {
            if ($source.PSObject.Properties['Packages'] -and $source.Packages) {
                foreach ($pkg in $source.Packages) {
                    if ($pkg.PSObject.Properties['PackageIdentifier'] -and $pkg.PackageIdentifier) {
                        $ids += ([string]$pkg.PackageIdentifier).Trim()
                    }
                }
            }
        }
    }
    return $ids
}

function Test-WingetPackageInstalled {
    param([string]$PackageId)

    $output = & winget list --id $PackageId --exact --source winget --accept-source-agreements 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        return $false
    }
    $text = ($output | Out-String)
    return ($text -match [regex]::Escape($PackageId))
}

function Install-WingetPackage {
    param([string]$PackageId)

    if ($DryRun) {
        Write-Action 'INSTALL' "winget install --id $PackageId --exact --source winget"
        $script:CountInstalled++
        return
    }

    $alreadyInstalled = Test-WingetPackageInstalled -PackageId $PackageId

    if ($Check) {
        if ($alreadyInstalled) {
            Write-Action 'OK' "$PackageId (installed)"
            $script:CountSkipped++
        } else {
            Write-Action 'MISS' "$PackageId (not installed)"
            $script:CountMissing++
        }
        return
    }

    if ($alreadyInstalled) {
        Write-Action 'SKIP' "$PackageId (already installed)"
        $script:CountSkipped++
        return
    }

    Write-Action 'INSTALL' $PackageId
    & winget install --id $PackageId --exact --source winget --accept-package-agreements --accept-source-agreements
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        $script:CountInstalled++
    } elseif ($exitCode -eq $WingetNoUpdateApplicable) {
        Write-Action 'SKIP' "$PackageId (already up to date)"
        $script:CountSkipped++
    } else {
        Write-WarnMsg "Failed to install $PackageId (winget exit code: $exitCode)"
        $script:CountFailed++
    }
}

function Resolve-GitCommand {
    $cmd = Get-Command git -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }
    $candidates = @()
    if ($env:ProgramFiles) {
        $candidates += (Join-Path $env:ProgramFiles 'Git\cmd\git.exe')
    }
    if (${env:ProgramFiles(x86)}) {
        $candidates += (Join-Path ${env:ProgramFiles(x86)} 'Git\cmd\git.exe')
    }
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return $candidate
        }
    }
    return $null
}

function Invoke-SetupNeovim {
    if ($SkipNvim) {
        return
    }

    if (Test-Path -LiteralPath $NvimConfigDir) {
        Write-Action 'SKIP' "Neovim config already exists: $NvimConfigDir"
        return
    }

    if ($DryRun) {
        Write-Action 'CLONE' "git clone $NvimRepoUrl $NvimConfigDir"
        return
    }

    $gitExe = Resolve-GitCommand
    if (-not $gitExe) {
        Write-WarnMsg "git was not found; skipping Neovim config clone ($NvimRepoUrl)."
        Write-Info "Re-open PowerShell and run: git clone $NvimRepoUrl `"$NvimConfigDir`""
        return
    }

    $parentDir = Split-Path -Path $NvimConfigDir -Parent
    if (-not (Test-Path -LiteralPath $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    Write-Action 'CLONE' "$NvimRepoUrl -> $NvimConfigDir"
    & $gitExe clone $NvimRepoUrl $NvimConfigDir
    if ($LASTEXITCODE -ne 0) {
        Write-WarnMsg "Failed to clone Neovim config (git exit code: $LASTEXITCODE)"
        $script:CountFailed++
    }
}

# --- Main ---
if ($InitLocal) {
    Initialize-LocalPackageFile
    exit 0
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host '[ERROR]  winget was not found.' -ForegroundColor Red
    Write-Host '         Install "App Installer" from Microsoft Store and re-run this script.' -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path -LiteralPath $PackageFile -PathType Leaf)) {
    throw "Package list not found: $PackageFile"
}

$sourceFiles = @($PackageFile)

if (-not $NoLocal) {
    if (Test-Path -LiteralPath $RepoLocalPackageFile -PathType Leaf) {
        $sourceFiles += $RepoLocalPackageFile
    }
    if (Test-Path -LiteralPath $HomeLocalPackageFile -PathType Leaf) {
        $sourceFiles += $HomeLocalPackageFile
    }
}

if ($ExtraFiles -and $ExtraFiles.Count -gt 0) {
    foreach ($extra in $ExtraFiles) {
        if (-not (Test-Path -LiteralPath $extra -PathType Leaf)) {
            throw "Extra package file not found: $extra"
        }
        $sourceFiles += $extra
    }
}

$packageIds = @()
foreach ($file in $sourceFiles) {
    $ids = @(Get-PackageIdsFromFile -FilePath $file)
    Write-Info "Loaded package list: $file ($($ids.Count) packages)"
    $packageIds += $ids
}

# Deduplicate while preserving order
$seen = @{}
$uniqueIds = @()
foreach ($id in $packageIds) {
    $key = $id.ToLowerInvariant()
    if (-not $seen.ContainsKey($key)) {
        $seen[$key] = $true
        $uniqueIds += $id
    }
}

if ($DryRun) {
    Write-Info 'Mode: dry-run (no changes will be made)'
} elseif ($Check) {
    Write-Info 'Mode: check (checking installed packages via winget)'
}

foreach ($id in $uniqueIds) {
    Install-WingetPackage -PackageId $id
}

Write-Host ''
if ($Check) {
    Write-Info "Done. installed=$($script:CountSkipped), missing=$($script:CountMissing)"
    if ($script:CountMissing -gt 0) {
        exit 1
    }
    exit 0
}

Write-Info "Done. installed=$($script:CountInstalled), skipped=$($script:CountSkipped), failed=$($script:CountFailed)"
Write-Info 'Note: HackGen font is not published on winget. Download manually from: https://github.com/yuru7/HackGen/releases'

Invoke-SetupNeovim

if ($script:CountFailed -gt 0) {
    exit 1
}

if ($Link) {
    $installer = Join-Path $DotfilesDir 'install.ps1'
    if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) {
        throw "Symlink installer not found: $installer"
    }
    if ($DryRun) {
        Write-Info "[DRYRUN] Would run: $installer"
    } else {
        Write-Info 'Running symlink installer...'
        & $installer
    }
}
