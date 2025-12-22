return {
  {
    "alexghergh/nvim-tmux-navigation",
    lazy = true,
    event = "VeryLazy",
    config = function()
      local nvim_tmux_nav = require("nvim-tmux-navigation")
      nvim_tmux_nav.setup({
        disable_when_zoomed = true,
        keybinding = {
          left = "<C-h>",
          down = "<C-j>",
          up = "<C-k>",
          right = "<C-l>",
          last_actinve = "<C-\\>",
        },
      })
    end,
  },
}
