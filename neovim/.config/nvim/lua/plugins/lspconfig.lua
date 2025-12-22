return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      autoformat = false,
      servers = {},
      document_highlight = {
        enabled = false,
      },
    },
  },
  {
    "mason-org/mason.nvim",
    -- version = "^1.0.0",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "emmet-ls",
      })
    end,
  },
}
