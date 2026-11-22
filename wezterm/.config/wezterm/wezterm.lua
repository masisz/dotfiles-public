local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()
local target = wezterm.target_triple
local is_windows = target:find("windows") ~= nil
local is_macos = target:find("apple%-darwin") ~= nil

local wisteria = require("colors.wisteria")
config.colors = wisteria.colors

-- Font (aligned with Ghostty: HackGen35 Bold, 14.0, disable ligatures)
config.font = wezterm.font_with_fallback({
  { family = "HackGen35", weight = "Bold" },
  { family = "HackGen35 Console", weight = "Bold" },
  { family = "HackGen", weight = "Bold" },
})
config.font_size = is_windows and 12.0 or 14.0
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0", "dlig=0" }
config.adjust_window_size_when_changing_font_size = false

config.automatically_reload_config = true
config.audible_bell = "Disabled"

-- Background & split appearance (aligned with Ghostty)
config.window_background_opacity = 0.85
config.text_background_opacity = 0.85
if is_macos then
  config.macos_window_background_blur = 15
  -- macos-option-as-alt = true
  config.send_composed_key_when_left_alt_is_pressed = false
  config.send_composed_key_when_right_alt_is_pressed = false
elseif is_windows then
  config.win32_system_backdrop = "Acrylic"
end

-- unfocused-split-opacity = 0.825
config.inactive_pane_hsb = {
  saturation = 1.0,
  brightness = 0.825,
}

-- Mouse (aligned with Ghostty: mouse-hide-while-typing = true)
config.hide_mouse_cursor_when_typing = true

config.cursor_blink_rate = 800
config.default_cursor_style = "BlinkingBlock"

config.window_decorations = "TITLE | RESIZE"
config.hide_tab_bar_if_only_one_tab = true

config.window_frame = {
  inactive_titlebar_bg = "rgba(0, 53, 69, 0.85)",
  active_titlebar_bg = "rgba(0, 18, 23, 0.85)",
  inactive_titlebar_fg = "#6a8088",
  active_titlebar_fg = "#fffdf0",
  inactive_titlebar_border_bottom = "#003545",
  active_titlebar_border_bottom = "#003545",
  button_fg = "#c5c5c5",
  button_bg = "rgba(0, 18, 23, 0.85)",
  button_hover_fg = "#fffdf0",
  button_hover_bg = "#003545",
}

config.window_padding = {
  left = 5,
  right = 5,
  top = 8,
  bottom = 8,
}

if is_windows then
  config.default_prog = { "pwsh.exe" }
end

-- Key bindings (aligned with Ghostty while retaining standard shortcuts & existing leader bindings)
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 2000 }

config.keys = {
  -- Clipboard
  { key = "C", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "V", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

  -- New split (Ghostty: alt+- = down, alt+shift+\ (|) = right)
  { key = "-", mods = "ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "|", mods = "ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "|", mods = "ALT|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "\\", mods = "ALT|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

  -- Resize split (Ghostty: alt+shift+h/j/k/l)
  { key = "h", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "j", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "k", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "l", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
  { key = "H", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "J", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "K", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "L", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

  -- Move split (Ghostty: cmd+h/j/k/l)
  { key = "h", mods = "SUPER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "SUPER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "SUPER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "SUPER", action = act.ActivatePaneDirection("Right") },

  -- Toggle split zoom (Ghostty: cmd+shift+m)
  { key = "m", mods = "SUPER|SHIFT", action = act.TogglePaneZoomState },
  { key = "M", mods = "SUPER|SHIFT", action = act.TogglePaneZoomState },

  -- Shift+Enter sends newline (Ghostty: shift+enter=text:\n)
  { key = "Enter", mods = "SHIFT", action = act.SendString("\n") },

  -- Existing Leader & Ctrl bindings
  { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "|", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
  { key = "w", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },
  { key = "p", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
}

config.key_tables = {
  resize_pane = {
    { key = "h", mods = "NONE", action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "j", mods = "NONE", action = act.AdjustPaneSize({ "Down", 1 }) },
    { key = "k", mods = "NONE", action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "l", mods = "NONE", action = act.AdjustPaneSize({ "Right", 1 }) },
    { key = "Escape", action = "PopKeyTable" },
  },
}

return config
