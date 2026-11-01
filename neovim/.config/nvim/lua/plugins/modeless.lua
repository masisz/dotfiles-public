local os_config = require("config.os")
local modeless_path = os_config.dev_path("modeless.nvim")

return {
  {
    dir = modeless_path,
    enabled = vim.uv.fs_stat(modeless_path) ~= nil,
    ft = "markdown",
    config = function()
      require("modeless").setup({})
    end,
  },
}

