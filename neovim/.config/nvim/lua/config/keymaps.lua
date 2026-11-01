-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- select all
vim.keymap.set("n", "<C-a>", "gg<S-v>G")

-- delete a word backwards
vim.keymap.set("n", "dw", 'vb"_d')

-- no register commands
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "X", '"_X')

-- tmux navigation
vim.keymap.set("n", "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", {})
vim.keymap.set("n", "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", {})
vim.keymap.set("n", "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", {})
vim.keymap.set("n", "<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>", {})

vim.keymap.set("c", "<C-v>", '<C-r>+')
vim.keymap.set("c", "<D-v>", '<C-r>+')

-- replace
vim.keymap.set("n", "<leader>r", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gc<Left><Left><Left>", { desc = "Replace word under cursor (ignore case, confirm)" })

-- task
vim.keymap.set("n", "<leader>Tn", "<Cmd>TaskNew<CR>", { desc = "新規タスク" })

-- markdown
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local map = vim.keymap.set
    local opts = { silent = true, buf = true }

    -- Insert: 行頭に入れて Insert に戻る
    map("i", "<M-1>", "<Esc>I# <Esc>i", opts)
    map("i", "<M-2>", "<Esc>I## <Esc>i", opts)
    map("i", "<M-3>", "<Esc>I### <Esc>i", opts)
    map("i", "<M-4>", "<Esc>I#### <Esc>i", opts)
    map("i", "<M-5>", "<Esc>I- <Esc>i", opts)
    map("i", "<M-6>", "<Esc>I- [ ] <Esc>i", opts)

    -- Normal: 行頭に入れて Normal のまま
    map("n", "<M-1>", "I# <Esc>", opts)
    map("n", "<M-2>", "I## <Esc>", opts)
    map("n", "<M-3>", "I### <Esc>", opts)
    map("n", "<M-4>", "I#### <Esc>", opts)
    map("n", "<M-5>", "I- <Esc>", opts)
    map("n", "<M-6>", "I- [ ] <Esc>", opts)
  end,
})
