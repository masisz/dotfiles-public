# Dotfiles

[日本語版はこちら / Japanese version](./README.ja.md)

## Overview

This repository contains my personal dotfiles designed for cross-platform compatibility between **macOS** and **Windows + WSL** environments. The goal is to maintain a consistent development environment across different operating systems.

## Features

- **Cross-platform support**: Configurations work seamlessly on both macOS and Windows (WSL)
- **Unified terminal experience**: Uses WezTerm as a terminal emulator for both platforms
- **Japanese language support**: HackGen font for proper Japanese character display
- **Modern development tools**: tmux, Zellij, zsh, and WezTerm configurations included

## Key Components

### Terminal

- **WezTerm**: Cross-platform GPU-accelerated terminal emulator
  - Works on both Windows and macOS
  - Consistent experience across platforms
  - GPU acceleration for smooth rendering

### Font

- **HackGen**: Japanese programming font
  - Combines Hack font with Japanese glyphs
  - Excellent readability for both English and Japanese
  - Monospaced font optimized for coding

### Included Configurations

- **Neovim**: Managed in a separate repository — [masisz.nvim](https://github.com/masisz/masisz.nvim) (usurai.nvim + todo.nvim + article.nvim)
- **Ghostty**: Terminal emulator settings & Wisteria theme
- **WezTerm**: Cross-platform terminal emulator settings & Wisteria theme
- **Starship**: Shell prompt configuration
- **tmux**: Terminal multiplexer
- **Zellij**: Terminal multiplexer
- **zsh**: Shell configuration
- **PowerShell**: Windows shell profile (`starship`, `zoxide`, `eza`, `bat`, `neovim`)
- **Karabiner-Elements**: macOS keyboard customization
- **Zed**: Editor settings
- **Git / GitHub CLI (`gh`)**: Global gitignore & `gh` CLI preferences (credentials excluded)
- **rufio**: Terminal file manager settings

## Installation

### Prerequisites

- **macOS**: Homebrew, Zsh
- **Windows**: PowerShell 5.1 / 7 (with Developer Mode enabled or Administrator privileges for symlinks) and/or WSL2

### Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/masisz/dotfiles-public.git ~/dotfiles-public
   cd ~/dotfiles-public
   ```

2. (Optional) Install required packages and clone [masisz.nvim](https://github.com/masisz/masisz.nvim):

   **macOS (Homebrew)**:
   ```zsh
   # Check which packages are missing
   ./setup-macos.zsh --check

   # Install packages and clone masisz.nvim into ~/.config/nvim (use --skip-nvim to skip)
   ./setup-macos.zsh

   # Optional: create a machine-specific local Brewfile (~/.Brewfile.local)
   ./setup-macos.zsh --init-local
   ```

   **Windows (winget)**:
   ```powershell
   # Check which packages are missing
   .\setup-windows.ps1 -Check

   # Install Windows-compatible packages and clone masisz.nvim into %LOCALAPPDATA%\nvim (use -SkipNvim to skip)
   .\setup-windows.ps1

   # Optional: create a machine-specific local package list (~\.winget-packages.local.json)
   .\setup-windows.ps1 -InitLocal
   ```

   Machine-specific packages can be kept outside Git in `./Brewfile.local` or `~/.Brewfile.local` (macOS), and `.\winget-packages.local.json` or `~\.winget-packages.local.json` (Windows), or passed via `--extra-file` / `-ExtraFiles`. Templates are provided as `Brewfile.local.example` and `winget-packages.local.json.example`.

3. Create symlinks using the installer script (no GNU Stow required):

   **macOS / Linux / WSL (Zsh)**:
   ```zsh
   # Preview changes without modifying anything
   ./install.zsh --dry-run

   # Link all packages (macOS-only packages like karabiner are skipped on Linux/WSL)
   ./install.zsh

   # Or link specific packages only
   ./install.zsh ghostty wezterm starship
   ```

   **Windows (PowerShell)**:
   ```powershell
   # Preview changes without modifying anything
   .\install.ps1 -DryRun

   # Link Windows-native packages (wezterm, starship, powershell, git, zellij)
   .\install.ps1

   # Or link specific packages only
   .\install.ps1 -Packages wezterm, starship
   ```

   Existing regular files are automatically backed up to `~/.dotfiles_backup/<timestamp>/` before creating symlinks. To remove symlinks managed by this repository, run `./install.zsh --unlink` or `.\install.ps1 -Unlink`.

## Requirements

### Common Tools

- Git
- Neovim (>= 0.9.0)
- tmux
- zsh
- HackGen font

### macOS Specific

- Homebrew
- Requires `/opt/homebrew/bin` in PATH

### Windows + WSL Specific

- WSL2 installed and configured
- WezTerm installed on Windows host
- HackGen font installed on Windows

## Font Installation

### HackGen Font

Download and install from: https://github.com/yuru7/HackGen

- **macOS**: Install via Font Book or `brew install --cask font-hackgen`
- **Windows**: Download and install TTF files manually

## Customization

Each configuration can be customized individually:

- **Ghostty**: Edit `ghostty/.config/ghostty/config`
- **WezTerm**: Edit `wezterm/.config/wezterm/wezterm.lua`
- **Starship**: Edit `starship/.config/starship.toml`
- **tmux**: Edit `tmux/.config/tmux/tmux.conf`
- **Zellij**: Edit `zellij/.config/zellij/config.kdl`
- **zsh**: Edit `zsh/.zshrc` (put machine-specific settings in `~/.zshrc.local`)
- **PowerShell**: Edit `powershell/.config/powershell/Microsoft.PowerShell_profile.ps1` (put machine-specific settings in `~\.powershell_profile.local.ps1`)

## Platform-Specific Notes

### macOS

The zsh configuration includes Homebrew path settings that automatically detect macOS and set appropriate paths.

### Windows + WSL

- WezTerm should be installed on the Windows host
- WSL2 distributions can access the shared configuration
- Ensure proper line endings (LF) for shell scripts

## License

MIT License - Feel free to use and modify for your own purposes.

## Contributing

This is a personal configuration repository, but suggestions and improvements are welcome via issues or pull requests.
