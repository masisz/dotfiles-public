# frozen_string_literal: true

# ~/.config/rufio/config.rb
# rufio DSL Configuration File
#
# このファイルは rufio の設定を定義します。
# 同じディレクトリにある script_paths.yml と bookmarks.yml を読み込みます。

# ========================================
# 言語設定
# ========================================
# 'en' (English) または 'ja' (Japanese)
LANGUAGE = 'ja'

# ========================================
# カラー設定
# ========================================
# HSL形式: [色相(0-360), 彩度(0-100), 明度(0-100)]
COLORS = {
  directory: { hsl: [220, 80, 60] },    # 青色
  file: { hsl: [0, 0, 90] },            # 白色
  executable: { hsl: [120, 70, 50] },   # 緑色
  selected: { hsl: [50, 90, 70] },      # 黄色
  preview: { hsl: [180, 60, 65] }       # シアン
}.freeze

# ========================================
# キーバインド設定
# ========================================
KEYBINDS = {
  quit: %w[q ESC],
  up: %w[k UP],
  down: %w[j DOWN],
  left: %w[h LEFT],
  right: %w[l RIGHT ENTER],
  top: %w[g],
  bottom: %w[G],
  refresh: %w[r],
  search: %w[/],
  open_file: %w[o SPACE]
}.freeze

# ========================================
# アプリケーション関連付け
# ========================================
# 拡張子ごとに開くアプリケーションを指定
APPLICATIONS = {
  %w[txt md rb py js html css json xml yaml yml zig] => 'nvim',
  %w[jpg jpeg png gif bmp svg webp] => 'open',
  %w[mp4 avi mkv mov wmv] => 'open',
  %w[pdf] => 'open',
  %w[doc docx xls xlsx ppt pptx] => 'open',
  :default => 'nvim'
}.freeze

# ========================================
# コマンド履歴サイズ
# ========================================
COMMAND_HISTORY_SIZE = 1000

# ========================================
# スクリプトパスとブックマークは別ファイルで管理
# ========================================
# script_paths.yml - スクリプトディレクトリの一覧
# bookmarks.yml    - ブックマークの一覧
#
# これらのファイルは rufio が自動的に読み込みます。
# 手動で編集することも、rufio の UI から管理することもできます。
