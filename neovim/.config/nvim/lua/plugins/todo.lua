local os_config = require("config.os")
local local_todo = os_config.dev_path("public-git", "todo.nvim")
local has_local = vim.uv.fs_stat(local_todo) ~= nil

local todo_spec
if has_local then
  todo_spec = {
    dir = local_todo,
    name = "todo.nvim",
  }
else
  todo_spec = {
    "masisz/todo.nvim",
  }
end

todo_spec.lazy = false
todo_spec.keys = {
  { "<leader>Tn", "<Cmd>TodoNew<CR>", desc = "新規タスク" },
  { "<Space>Tl", "<Cmd>TaskList<CR>", desc = "タスク一覧" },
}
todo_spec.opts = {
  directory = "~/tasks",
  extension = "task",
}

return {
  todo_spec,
}
