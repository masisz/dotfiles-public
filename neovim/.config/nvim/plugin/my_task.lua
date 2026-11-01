if vim.g.loaded_my_task then
  return
end
vim.g.loaded_my_task = true

vim.api.nvim_create_user_command("TaskNew", function()
  require("my_task.creator").create_task()
end, { desc = "新規タスクを作成" })

