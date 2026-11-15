-- ============================================================================
-- masisz.nvim - Ultra-fast Neovim environment for developers and writers
-- ============================================================================

-- 1. Load basic options, leader keys, language catalog & directory paths
require("config.options")

-- 2. Bootstrap lazy.nvim & masisz.nvim distribution
require("config.lazy")

-- 3. Load autocmds and keymaps
require("config.autocmds")
require("config.keymaps")

-- 4. Utility commands
if vim.fn.exists(":LspInfo") == 0 then
  vim.api.nvim_create_user_command("LspInfo", function()
    vim.cmd("checkhealth vim.lsp")
  end, { desc = "Show LSP health information" })
end
