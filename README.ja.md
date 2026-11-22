# Dotfiles

[English version](./README.md)

## 概要

このリポジトリは、**macOS**と**Windows + WSL**環境でのクロスプラットフォーム対応を目的とした個人用dotfilesです。異なるOS間で一貫した開発環境を維持することを目標としています。

## 特徴

- **クロスプラットフォーム対応**: macOSとWindows（WSL）の両方でシームレスに動作
- **統一されたターミナル体験**: 両プラットフォームでWezTermを使用
- **日本語サポート**: HackGenフォントによる日本語文字の適切な表示
- **モダンな開発ツール**: tmux、Zellij、zsh、WezTermの設定を含む

## 主要コンポーネント

### ターミナル

- **WezTerm**: クロスプラットフォーム対応のGPUアクセラレーション型ターミナルエミュレータ
  - WindowsとmacOSの両方で動作
  - プラットフォーム間で一貫した体験
  - GPUアクセラレーションによるスムーズなレンダリング

### フォント

- **HackGen**: 日本語プログラミングフォント
  - Hackフォントと日本語グリフを組み合わせ
  - 英語と日本語の両方で優れた可読性
  - コーディングに最適化された等幅フォント

### 含まれる設定

- **Neovim**: 別リポジトリ [masisz.nvim](https://github.com/masisz/masisz.nvim) に移行済み（usurai.nvim + todo.nvim + article.nvim）
- **Ghostty**: ターミナルエミュレータ設定 & Wisteria テーマ
- **WezTerm**: クロスプラットフォーム対応ターミナルエミュレータ設定 & Wisteria テーマ
- **Starship**: プロンプト設定
- **tmux**: ターミナルマルチプレクサ
- **Zellij**: ターミナルマルチプレクサ
- **zsh**: シェル設定
- **PowerShell**: Windows シェルプロファイル（`starship`, `zoxide`, `eza`, `bat`, `neovim`）
- **Karabiner-Elements**: macOS キーボードカスタマイズ
- **Zed**: エディタ設定
- **Git / GitHub CLI (`gh`)**: グローバル gitignore・`gh` 設定（認証情報は除外）
- **rufio**: ターミナルファイラ設定

## インストール

### 前提条件

- **macOS**: Homebrew、Zsh
- **Windows**: PowerShell 5.1 / 7（シンボリックリンク作成のため「開発者モード」有効化または管理者権限）および/または WSL2

### クイックスタート

1. このリポジトリをクローン:
   ```bash
   git clone https://github.com/masisz/dotfiles-public.git ~/dotfiles-public
   cd ~/dotfiles-public
   ```

2. （任意）必要なパッケージと [masisz.nvim](https://github.com/masisz/masisz.nvim) をセットアップ:

   **macOS (Homebrew)**:
   ```zsh
   # 不足パッケージの確認
   ./setup-macos.zsh --check

   # パッケージ導入 & ~/.config/nvim へ masisz.nvim をクローン（不要時は --skip-nvim）
   ./setup-macos.zsh

   # 任意: マシン固有パッケージ用のローカル Brewfile (~/.Brewfile.local) を作成
   ./setup-macos.zsh --init-local
   ```

   **Windows (winget)**:
   ```powershell
   # 不足パッケージの確認
   .\setup-windows.ps1 -Check

   # Windows 対応パッケージ導入 & %LOCALAPPDATA%\nvim へ masisz.nvim をクローン（不要時は -SkipNvim）
   .\setup-windows.ps1

   # 任意: マシン固有パッケージ用のローカル定義 (~\.winget-packages.local.json) を作成
   .\setup-windows.ps1 -InitLocal
   ```

   PC 固有・仕事用のパッケージは Git 管理外の `./Brewfile.local` / `~/.Brewfile.local`（macOS）または `.\winget-packages.local.json` / `~\.winget-packages.local.json`（Windows）に書くと自動読み込みされます（`--extra-file` / `-ExtraFiles` での任意ファイル追加にも対応）。ひな形は `Brewfile.local.example` / `winget-packages.local.json.example` を参照してください。

3. インストーラスクリプトでシンボリックリンクを作成（GNU Stow 不要）:

   **macOS / Linux / WSL (Zsh)**:
   ```zsh
   # 変更内容の事前確認
   ./install.zsh --dry-run

   # 全パッケージをリンク（Linux/WSL では karabiner など macOS 専用設定を自動スキップ）
   ./install.zsh

   # または個別に指定
   ./install.zsh ghostty wezterm starship
   ```

   **Windows (PowerShell)**:
   ```powershell
   # 変更内容の事前確認
   .\install.ps1 -DryRun

   # Windows 向けパッケージをリンク（wezterm, starship, powershell, git, zellij）
   .\install.ps1

   # または個別に指定
   .\install.ps1 -Packages wezterm, starship
   ```

   既存の通常ファイルは自動的に `~/.dotfiles_backup/<タイムスタンプ>/` へバックアップされます。リンク解除は `./install.zsh --unlink` または `.\install.ps1 -Unlink` で行えます。

## 必要なツール

### 共通ツール

- Git
- Neovim (>= 0.9.0)
- tmux
- zsh
- HackGenフォント

### macOS固有

- Homebrew
- PATHに`/opt/homebrew/bin`が必要

### Windows + WSL固有

- WSL2のインストールと設定
- WindowsホストにWezTermをインストール
- WindowsにHackGenフォントをインストール

## フォントのインストール

### HackGenフォント

以下からダウンロードしてインストール: https://github.com/yuru7/HackGen

- **macOS**: Font Bookまたは`brew install --cask font-hackgen`でインストール
- **Windows**: TTFファイルを手動でダウンロードしてインストール

## カスタマイズ

各設定は個別にカスタマイズ可能です:

- **Ghostty**: `ghostty/.config/ghostty/config` を編集
- **WezTerm**: `wezterm/.config/wezterm/wezterm.lua` を編集
- **Starship**: `starship/.config/starship.toml` を編集
- **tmux**: `tmux/.config/tmux/tmux.conf` を編集
- **Zellij**: `zellij/.config/zellij/config.kdl` を編集
- **zsh**: `zsh/.zshrc` を編集（マシン固有設定は `~/.zshrc.local` に記載）
- **PowerShell**: `powershell/.config/powershell/Microsoft.PowerShell_profile.ps1` を編集（マシン固有設定は `~\.powershell_profile.local.ps1` に記載）

## プラットフォーム固有の注意事項

### macOS

zsh設定には、macOSを自動検出して適切なパスを設定するHomebrew用のパス設定が含まれています。

### Windows + WSL

- WezTermはWindowsホストにインストールする必要があります
- WSL2ディストリビューションから共有設定にアクセス可能
- シェルスクリプトの改行コードは適切に設定してください（LF）

## ライセンス

MITライセンス - 自由に使用・改変してください。

## コントリビューション

これは個人用の設定リポジトリですが、IssueやPull Requestによる提案や改善は歓迎します。
