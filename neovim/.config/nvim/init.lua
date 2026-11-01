-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if vim.fn.exists(":LspInfo") == 0 then
  vim.api.nvim_create_user_command("LspInfo", function()
    vim.cmd("checkhealth vim.lsp")
  end, { desc = "Show LSP health information" })
end
