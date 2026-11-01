local M = {}

M.is_mac = vim.fn.has("macunix") == 1
M.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
M.is_unix = vim.fn.has("unix") == 1

M.home = os.getenv(M.is_windows and "USERPROFILE" or "HOME") or vim.fn.expand("~")

function M.joinpath(...)
  return vim.fs.joinpath(...)
end

function M.dev_path(...)
  local root = os.getenv("NVIM_DEV_DIR") or M.joinpath(M.home, "devs")
  return M.joinpath(root, ...)
end

function M.executable(name)
  return vim.fn.executable(name) == 1
end

return M

