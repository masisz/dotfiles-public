return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          root_dir = function(bufnr, on_dir)
            local markers = {
              ["compile_commands.json"] = true,
              ["compile_flags.txt"] = true,
              [".clangd"] = true,
              [".clang-tidy"] = true,
              [".clang-format"] = true,
              [".git"] = true,
            }
            local root = vim.fs.root(bufnr, function(name)
              return markers[name] or name:match("%.uproject$") ~= nil or name:match("%.uplugin$") ~= nil
            end)
            if root then
              on_dir(root)
            end
          end,
        },
      },
    },
  },
}

