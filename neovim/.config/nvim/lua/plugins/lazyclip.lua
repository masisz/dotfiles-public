return {
  "atiladefreitas/lazyclip",
  config = function()
    require("lazyclip").setup({})
  end,
  keys = {
    { "<leader>Cw", desc = "Open Clipboard Manager" },
  },
}

