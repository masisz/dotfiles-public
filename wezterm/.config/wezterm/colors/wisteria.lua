local colors = {
  foreground = "#c5c5c5",
  background = "#001217",
  cursor_bg = "#8fa8aa",
  cursor_fg = "#002831",
  cursor_border = "#8fa8aa",
  selection_fg = "#a0b5b5",
  selection_bg = "#003545",
  scrollbar_thumb = "#5a7580",
  split = "#003545",
  ansi = {
    "#003545",
    "#c44f4f",
    "#8ab020",
    "#e6d5a8",
    "#8fadce",
    "#ddc8f2",
    "#8ed49a",
    "#f5ead5",
  },
  brights = {
    "#5a7580",
    "#bd3613",
    "#5a7580",
    "#6a8088",
    "#8fa8aa",
    "#7068d0",
    "#a0b5b5",
    "#fffdf0",
  },
  tab_bar = {
    background = "rgba(0, 18, 23, 0.85)",
    active_tab = {
      bg_color = "#ddc8f2",
      fg_color = "#001217",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "rgba(0, 53, 69, 0.85)",
      fg_color = "#6a8088",
    },
    inactive_tab_hover = {
      bg_color = "#8fa8aa",
      fg_color = "#001217",
    },
    new_tab = {
      bg_color = "rgba(0, 53, 69, 0.85)",
      fg_color = "#c5c5c5",
    },
    new_tab_hover = {
      bg_color = "#8fa8aa",
      fg_color = "#001217",
    },
  },
}

return {
  colors = colors,
}
