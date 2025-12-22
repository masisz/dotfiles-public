# Dotfiles

[English version](./README.md)

## 概要

このリポジトリは、**macOS**と**Windows + WSL**環境でのクロスプラットフォーム対応を目的とした個人用dotfilesです。異なるOS間で一貫した開発環境を維持することを目標としています。

## 特徴

- **クロスプラットフォーム対応**: macOSとWindows（WSL）の両方でシームレスに動作
- **統一されたターミナル体験**: 両プラットフォームでWezTermを使用
- **日本語サポート**: HackGenフォントによる日本語文字の適切な表示
- **モダンな開発ツール**: Neovim、tmux、zshの設定を含む

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

- **Neovim**: LazyVimベースのモダンなVimエディタ
- **tmux**: ターミナルマルチプレクサ
- **zsh**: Powerlevel10kテーマを使用したシェル設定
- **WezTerm**: ターミナルエミュレータ設定

## インストール

### 前提条件

- **macOS**: Homebrew
- **Windows**: WSL2（Ubuntuまたは類似のディストリビューション）
- GNU Stow（シンボリックリンク管理用）

### クイックスタート

1. このリポジトリをクローン:
   ```bash
   git clone https://github.com/yourusername/dotfiles-public.git ~/dotfiles-public
   cd ~/dotfiles-public
   ```

2. GNU Stowをインストール:
   ```bash
   # macOS
   brew install stow

   # WSL/Ubuntu
   sudo apt install stow
   ```

3. stowを使用して設定をシンボリックリンク:
   ```bash
   # すべての設定をインストール
   stow neovim zsh tmux wezterm

   # または個別にインストール
   stow neovim
   stow zsh
   stow tmux
   stow wezterm
   ```

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

- **Neovim**: `neovim/.config/nvim/lua/`内のファイルを編集
- **tmux**: `tmux/.config/tmux/tmux.conf`を編集
- **zsh**: `zsh/.zshrc`と`zsh/.p10k.zsh`を編集
- **WezTerm**: `wezterm/.config/wezterm/wezterm.lua`を編集

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
