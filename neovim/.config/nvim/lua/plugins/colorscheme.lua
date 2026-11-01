local os_config = require("config.os")
local local_wisteria = os_config.dev_path("public-git", "wisteria.nvim")
local has_local = vim.uv.fs_stat(local_wisteria) ~= nil

local wisteria_spec
if has_local then
  wisteria_spec = {
    dir = local_wisteria,
    name = "wisteria",
    opts = {
      style = "dark",
      transparent = true,
    },
  }
else
  wisteria_spec = {
    "masisz/wisteria.nvim",
    name = "wisteria",
    opts = {
      style = "dark",
      transparent = true,
    },
  }
end

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "wisteria",
    },
  },
  wisteria_spec,
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      theme = "wisteria",
    },
  },
}
