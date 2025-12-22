-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- font configuration
config.font = wezterm.font(
  'HackGen35', { weight = 'Bold' }
)

config.font_size = 13.5
config.line_height = 1.1

-- load ashikaga color scheme
local ashikaga = require("colors.wisteria")
config.colors = ashikaga.colors

config.automatically_reload_config = true
config.audible_bell = "Disabled"

-- background settings (matching ghostty: opacity 0.80, blur 15)
config.window_background_opacity = 0.80
config.macos_window_background_blur = 15

-- cursor settings (matching ghostty)
config.cursor_blink_rate = 800
config.default_cursor_style = "BlinkingBlock"

config.window_decorations = "TITLE | RESIZE"
config.hide_tab_bar_if_only_one_tab = true

config.window_frame = {
	inactive_titlebar_bg = "#353535",
	active_titlebar_bg = "#2b2042",
	inactive_titlebar_fg = "#cccccc",
	active_titlebar_fg = "#ffffff",
	inactive_titlebar_border_bottom = "#2b2042",
	active_titlebar_border_bottom = "#2b2042",
	button_fg = "#cccccc",
	button_bg = "#2b2042",
	button_hover_fg = "#ffffff",
	button_hover_bg = "#3b3052",
}

config.window_padding = {
	left = 5,
	right = 5,
	top = 8,
	bottom = 8,
}

local mux = wezterm.mux

-- position and size
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():set_position(0, 0)
	window:gui_window():set_inner_size(800, 1200)
end)

config.mouse_bindings = {
	{
		-- copy clipboard from mouse right click
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
}

-- customize key bindings
config.disable_default_key_bindings = true

-- It will peepaed export keybind configuration command
-- wezterm show-keys --lua > ~/.config/wezterm/keybindings.lua
local keybind = require("keybindings")
config.keys = keybind.keys
config.key_tables = keybind.key_tables

-- disable pane controll, becase i using tmux.  
-- config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 2000 }
--
-- local act = wezterm.action
-- config.keys = {
-- 	-- control pane
-- 	{ key = "-", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
-- 	{ key = "|", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
-- 	{ key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
-- 	{ key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
-- 	{ key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
-- 	{ key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
-- 	{ key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
-- 	{ key = "[", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },
--
-- 	-- change resize pane mode
-- 	{ key = "p", mods = "CTRL|SHIFT", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
--
-- 	-- tab
-- 	{ key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
--
-- }
--
-- config.key_tables = {
-- 	resize_pane = {
-- 		{ key = "h", mods = "NONE", action = act.AdjustPaneSize({ "Left", 1 }) },
-- 		{ key = "j", mods = "NONE", action = act.AdjustPaneSize({ "Down", 1 }) },
-- 		{ key = "k", mods = "NONE", action = act.AdjustPaneSize({ "Up", 1 }) },
-- 		{ key = "l", mods = "NONE", action = act.AdjustPaneSize({ "Right", 1 }) },
-- 		{ key = "Escape", action = "PopKeyTable" },
-- 	},
-- }

-- and finally, return the configuration to wezterm
return config
