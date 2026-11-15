local os_config = require("config.os")
local local_article = os_config.dev_path("public-git", "article.nvim")
local has_local = vim.uv.fs_stat(local_article) ~= nil

local article_spec
if has_local then
  article_spec = {
    dir = local_article,
    name = "article.nvim",
  }
else
  article_spec = {
    "masisz/article.nvim",
  }
end

-- Resolve OS-specific article directory
local function get_article_dir()
  local cfg = vim.g.masisz or {}
  local paths = cfg.article_paths or {
    windows = "~/Documents/articles",
    mac = "~/articles",
    linux = "~/articles",
  }

  local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
  local is_mac = vim.fn.has("macunix") == 1

  if is_windows then
    return paths.windows or "~/articles"
  elseif is_mac then
    return paths.mac or "~/articles"
  else
    return paths.linux or "~/articles"
  end
end

article_spec.lazy = false
article_spec.opts = function()
  return {
    directory = get_article_dir(),
    usurai_sync = true,
    keymaps = {
      enable = true,
      new = "<leader>an",
      list = "<leader>al",
      grep = "<leader>a/",
      run = "<leader>ax",
      next = "<leader>as",
      insert = "<leader>ab",
      edit = "<leader>ae",
      clear = "<leader>ac",
    },
  }
end

return {
  article_spec,
}
