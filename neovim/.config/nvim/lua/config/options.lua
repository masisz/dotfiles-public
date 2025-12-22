-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_ruby_lsp = "ruby_lsp"
vim.g.lazyvim_ruby_formatter = "rubocop"
vim.g.lazyvim_picker = "snacks"
vim.g.lazyvim_prettier_needs_config = false
vim.g.lazyvim_eslint_auto_format = false
vim.g.autoformat = false
vim.g.lazyvim_mini_snippets_in_completion = true

vim.opt.termguicolors = true
vim.opt.cursorline = false
vim.opt.hlsearch = false

vim.opt.guicursor = {
  "n-v-c:block-blinkon0",
  "i-ci-ve:ver25-blinkon0",
  "r-cr:hor20-blinkon0",
  "o:hor50-blinkon0",
  "sm:block-blinkon0",
}
