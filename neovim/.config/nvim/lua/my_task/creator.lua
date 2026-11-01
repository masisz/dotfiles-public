local M = {}

function M.create_task()
  local directory = vim.fn.fnamemodify(vim.fn.expand(require("my_task").config.directory), ":p")
  vim.fn.mkdir(directory, "p")
  local date = os.date("%Y%m%d")
  local seq, path = 1, nil
  repeat
    path = directory .. string.format("%s-%02d.task", date, seq)
    seq = seq + 1
  until not vim.uv.fs_stat(path) and vim.fn.bufnr(path) == -1

  vim.cmd.edit(vim.fn.fnameescape(path))
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {
    "[Title]",
    "",
    "[Memo]",
    "",
    "[Due]",
    os.date("%Y-%m-%d"),
    "[Duration]",
    "1h",
  })
  vim.bo.filetype = "task"
  vim.api.nvim_win_set_cursor(0, { 2, 0 })
  vim.cmd("startinsert!")
  return path
end

return M

