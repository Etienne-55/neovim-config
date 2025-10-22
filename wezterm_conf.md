-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- config.color_scheme = "Tokyo Night"


config.colors = {
    foreground = "#CBE0F0",
    background = "#000000",  
    cursor_bg = "#47FF9C",
    cursor_border = "#47FF9C",
    cursor_fg = "#011423",
    selection_bg = "#033259",
    selection_fg = "#CBE0F0",
    ansi = { 
        "#214969",  -- black
        "#E52E2E",  -- red
        "#44FFB1",  -- green
        "#6B9FD8",  -- blue (toned down)
        "#D4A574",  -- yellow (toned down)
        "#a277ff",  -- magenta
        "#24EAF7",  -- cyan
        "#CBE0F0"   -- white
    },
    brights = { 
        "#2A5A7F",  -- bright black
        "#FF6B6B",  -- bright red
        "#5FFFC4",  -- bright green
        "#7EB3E8",  -- bright blue (muted)
        "#E8C294",  -- bright yellow (muted)
        "#B88FFF",  -- bright magenta
        "#5FF4FF",  -- bright cyan
        "#E0F0FF"   -- bright white
    },
}


config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 19

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.75
config.macos_window_background_blur = 80

local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

-- and finally, return the configuration to wezterm
return config

-- config.colors = {
-- 	foreground = "#CBE0F0",
-- 	background = "#011423",
-- 	cursor_bg = "#47FF9C",
-- 	cursor_border = "#47FF9C",
-- 	cursor_fg = "#011423",
-- 	selection_bg = "#033259",
-- 	selection_fg = "#CBE0F0",
-- 	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
-- 	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
-- }

