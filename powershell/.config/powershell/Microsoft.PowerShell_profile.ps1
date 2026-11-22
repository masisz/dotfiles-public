# PowerShell profile for Windows (compatible with PowerShell 7 and Windows PowerShell 5.1)

# UTF-8 encoding
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# PSReadLine settings (if available)
if (Get-Module -ListAvailable -Name PSReadLine) {
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -HistoryNoDuplicates
}

# Tool aliases / wrappers (aligned with zsh/.zshrc)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    if (Test-Path Alias:ls) {
        Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    }
    function ls { eza @args }
    function la { eza -a @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    if (Test-Path Alias:cat) {
        Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    }
    function cat { bat @args }
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name vi -Value nvim
    Set-Alias -Name vim -Value nvim
}

# zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# starship
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Local machine-specific configuration (not tracked in dotfiles-public)
$localProfile = Join-Path $HOME '.powershell_profile.local.ps1'
if (Test-Path -LiteralPath $localProfile) {
    . $localProfile
}
