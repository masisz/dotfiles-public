-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
  pattern = "*.pdf,*.docx,*.xlsx,*.pptx,*.jpg,*.png",
  callback = function()
    local filepath = vim.fn.expand("<afile>")
    print("open external file: " .. filepath)
    if vim.fn.has("macunix") == 1 then
      vim.fn.jobstart({ "open", filepath }, { detach = true })
    elseif vim.fn.has("unix") == 1 then
      vim.fn.jobstart({ "xdbg-open", filepath }, { detach = true })
    elseif vim.fn.has("win32") == 1 then
      vim.fn.jobstart({ "cmd.exe", "/C", "start", "", filepath }, { detach = true })
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
  -- make file path
  local current_file = vim.fn.expand("%:p")
  if current_file == "" then
    vim.notify("No file is currently open.")
    return
  end

  local file_dir = vim.fn.fnamemodify(current_file, ":h")
  local file_name = os.date("%Y%m%d_%H%M%S")
  local full_path = file_dir .. "/" .. file_name .. ".png"
  local relative_path = "./" .. file_name .. ".png"

  -- save image file to current file
  local cmd = string.format("pngpaste %s", full_path)
  os.execute(cmd)

  -- put markdown link
  local markdown_link = string.format("![%s](%s)", file_name, relative_path)
  vim.api.nvim_put({ markdown_link }, "c", true, true)
  vim.notify("Image saved to" .. full_path)
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

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities.documentHighlightProvider = false
    end
  end,
})
