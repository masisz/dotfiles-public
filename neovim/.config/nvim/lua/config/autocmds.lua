-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
  pattern = { "*.pdf", "*.docx", "*.xlsx", "*.pptx", "*.jpg", "*.png" },
  callback = function()
    local os_config = require("config.os")
    local filepath = vim.fn.expand("<afile>")
    print("open external file: " .. filepath)
    if os_config.is_mac then
      vim.fn.jobstart({ "open", filepath }, { detach = true })
    elseif os_config.is_windows then
      vim.fn.jobstart({ "cmd.exe", "/C", "start", "", filepath }, { detach = true })
    elseif os_config.is_unix then
      vim.fn.jobstart({ "xdg-open", filepath }, { detach = true })
    end
    vim.cmd("bdelete")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = false
  end,
})

local function paste_image()
  local os_config = require("config.os")

  -- make file path
  local current_file = vim.fn.expand("%:p")
  if current_file == "" then
    vim.notify("No file is currently open.")
    return
  end

  local file_dir = vim.fn.fnamemodify(current_file, ":h")
  local file_name = os.date("%Y%m%d_%H%M%S")
  local full_path = os_config.joinpath(file_dir, file_name .. ".png")
  local relative_path = "./" .. file_name .. ".png"

  local cmd
  if os_config.is_mac and os_config.executable("pngpaste") then
    cmd = { "pngpaste", full_path }
  elseif os_config.is_windows and os_config.executable("powershell.exe") then
    local powershell_path = full_path:gsub("'", "''")
    cmd = {
      "powershell.exe",
      "-NoProfile",
      "-Command",
      "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; "
        .. "$img = [Windows.Forms.Clipboard]::GetImage(); "
        .. "if ($null -eq $img) { exit 1 }; "
        .. "$img.Save('"
        .. powershell_path
        .. "', [Drawing.Imaging.ImageFormat]::Png)",
    }
  end

  if not cmd then
    vim.notify("PasteImage is not configured for this OS.", vim.log.levels.WARN)
    return
  end

  vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("No image was saved from the clipboard.", vim.log.levels.WARN)
    return
  end

  -- put markdown link
  local markdown_link = string.format("![%s](%s)", file_name, relative_path)
  vim.api.nvim_put({ markdown_link }, "c", true, true)
  vim.notify("Image saved to " .. full_path)
end

vim.api.nvim_create_user_command("PasteImage", paste_image, {})

local function today()
  local title = os.date("%Y/%m/%d")
  vim.api.nvim_put({ title }, "c", true, true)
end

vim.api.nvim_create_user_command("Today", today, {})

vim.filetype.add({
  extension = {
    erb = "erb",
  },
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.erb",
  callback = function()
    vim.bo.filetype = "eruby"
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "Rakefile",
  callback = function()
    vim.bo.filetype = "ruby"
  end,
})
