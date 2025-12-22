return {
  {
    "keaising/im-select.nvim",
    event = { "InsertEnter", "CmdlineEnter" },
    config = function()
      local config = {}

      if vim.fn.has("mac") == 1 then
        config = {
          default_im_select = "com.apple.keylayout.ABC",
          default_command = "im-select",
        }
      elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
        config = {
          default_im_select = "1033",
          default_command = "im-select.exe",
        }
      else
        config = {
          default_im_select = "keyboard-us",
          default_command = "fcitx5-remote",
        }
      end

      config.set_default_events = {
        "VimEnter",
        "FocusGained",
        "InsertLeave",
        "CmdlineLeave",
      }
      config.set_previous_events = { "InsertEnter" }
      config.keep_quiet_on_no_binary = true
      config.async_switch_im = true

      require("im_select").setup(config)
    end,
  },
}
