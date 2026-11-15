-- ============================================================================
-- Options Configuration (masisz.nvim based)
-- ============================================================================

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Configure usurai.nvim settings
vim.g.usurai = {
  colorscheme = "wisteria",
  langs = {
    lua = true,
    markdown = true,
    data = true,       -- JSON, YAML, TOML
    shell = true,      -- Bash / Zsh
    pwsh = true,       -- PowerShell Core
    docker = true,     -- Dockerfile & Compose
    python = true,     -- Python (pyright)
    typescript = true, -- TypeScript / JavaScript (vtsls)
    rust = true,       -- Rust (rust_analyzer)
    zig = true,        -- Zig (zls)
    ruby = true,       -- Ruby (ruby_lsp)
    cpp = true,        -- C / C++ (clangd)
    go = true,         -- Go (gopls)
    java = false,      -- Java (jdtls, optional)
    csharp = false,    -- C# (omnisharp, optional)
    sql = true,        -- SQL (sqlls)
  },
}

-- OS-Specific Directory Settings (Windows, macOS, Linux)
vim.g.masisz = {
  article_paths = {
    windows = "~/Documents/articles",
    mac = "~/articles",
    linux = "~/articles",
  },
  todo_paths = {
    windows = "~/Documents/todos",
    mac = "~/todos",
    linux = "~/todos",
  },
}

-- General options
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.termguicolors = true
opt.splitright = true
opt.splitbelow = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
