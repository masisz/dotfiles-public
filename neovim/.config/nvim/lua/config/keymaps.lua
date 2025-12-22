-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- select all
vim.keymap.set("n", "<C-a>", "gg<S-v>G")

-- delete a word backwards
vim.keymap.set("n", "dw", 'vb"_d')

-- undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

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
