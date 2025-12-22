# Dotfiles

[日本語版はこちら / Japanese version](./README.ja.md)

## Overview

This repository contains my personal dotfiles designed for cross-platform compatibility between **macOS** and **Windows + WSL** environments. The goal is to maintain a consistent development environment across different operating systems.

## Features

- **Cross-platform support**: Configurations work seamlessly on both macOS and Windows (WSL)
- **Unified terminal experience**: Uses WezTerm as a terminal emulator for both platforms
- **Japanese language support**: HackGen font for proper Japanese character display
- **Modern development tools**: Neovim, tmux, zsh configurations included

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

- **Neovim**: Modern Vim-based editor with LazyVim
- **tmux**: Terminal multiplexer
- **zsh**: Shell configuration with Powerlevel10k theme
- **WezTerm**: Terminal emulator settings

## Installation

### Prerequisites

- **macOS**: Homebrew
- **Windows**: WSL2 (Ubuntu or similar)
- GNU Stow (for symlink management)

### Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles-public.git ~/dotfiles-public
   cd ~/dotfiles-public
   ```

2. Install GNU Stow:
   ```bash
   # macOS
   brew install stow

   # WSL/Ubuntu
   sudo apt install stow
   ```

3. Use stow to symlink configurations:
   ```bash
   # Install all configurations
   stow neovim zsh tmux wezterm

   # Or install individually
   stow neovim
   stow zsh
   stow tmux
   stow wezterm
   ```

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

- **Neovim**: Edit files in `neovim/.config/nvim/lua/`
- **tmux**: Edit `tmux/.config/tmux/tmux.conf`
- **zsh**: Edit `zsh/.zshrc` and `zsh/.p10k.zsh`
- **WezTerm**: Edit `wezterm/.config/wezterm/wezterm.lua`

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
