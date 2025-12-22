return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "RRethy/nvim-treesitter-endwise" },
    opts = function(_, opts)
      opts.endwise = { enable = true }
      opts.highlight = { enable = true }
      opts.ensure_installed = {
        "bash",
        "cmake",
        "c_sharp",
        "cpp",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "razor",
        "ruby",
        "vim",
        "zig",
        "css",
        "latex",
        "norg",
        "scss",
        "svelte",
        "typst",
        "vue",
      }
    end,
  },
}
