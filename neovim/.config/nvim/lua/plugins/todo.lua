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

-- Resolve OS-specific todo directory
local function get_todo_dir()
  local cfg = vim.g.masisz or {}
  local paths = cfg.todo_paths or {
    windows = "~/Documents/todos",
    mac = "~/todos",
    linux = "~/todos",
  }

  local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
  local is_mac = vim.fn.has("macunix") == 1

  if is_windows then
    return paths.windows or "~/todos"
  elseif is_mac then
    return paths.mac or "~/todos"
  else
    return paths.linux or "~/todos"
  end
end

todo_spec.lazy = false
todo_spec.keys = {
  { "<leader>tn", "<Cmd>TodoNew<CR>", desc = "New Task" },
  { "<leader>tl", "<Cmd>TodoList<CR>", desc = "Task List" },
  { "<leader>tr", "<Cmd>RoadmapList<CR>", desc = "Roadmap List" },
}
todo_spec.opts = function()
  return {
    directory = get_todo_dir(),
    extension = "todo",
  }
end

return {
  todo_spec,
}
