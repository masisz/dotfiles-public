local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local os_config = require("config.os")
local function dev_spec(repo_name, github_path)
  local path = os_config.dev_path("public-git", repo_name)
  if vim.uv.fs_stat(path) then
    return { dir = path, name = repo_name }
  end
  return { github_path or ("masisz/" .. repo_name) }
end

require("lazy").setup({
  spec = {
    -- 1. Base distribution: masisz.nvim (includes usurai.nvim, todo.nvim, article.nvim, which-key)
    vim.tbl_extend("force", dev_spec("masisz.nvim", "masisz/masisz.nvim"), {
      lazy = false,
      priority = 1000,
      import = "masisz.plugins",
    }),

    -- 2. User personal plugins & overrides
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "wisteria", "habamax" } },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
