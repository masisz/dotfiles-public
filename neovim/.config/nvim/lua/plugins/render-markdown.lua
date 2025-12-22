return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    config = function()
      vim.opt_local.conceallevel = 2
      vim.opt_local.concealcursor = "nc"
      require("render-markdown").setup({})
    end,
  },
}
