local wezterm = require("wezterm")
local config = wezterm.config_builder()

----------------------------------------------------------------------
-- Color schemes
----------------------------------------------------------------------
local black = "#000000"

config.color_schemes = {
	["Original"] = {
		foreground = "#CBE0F0",
		background = black,
		cursor_bg = "#47FF9C",
		cursor_border = "#47FF9C",
		cursor_fg = "#011423",
		selection_bg = "#033259",
		selection_fg = "#CBE0F0",
		ansi = {
			"#214969", -- black
			"#E52E2E", -- red
			"#44FFB1", -- green
			"#D4A574", -- yellow
			"#6B9FD8", -- blue
			"#a277ff", -- magenta
			"#24EAF7", -- cyan
			"#CBE0F0", -- white
		},
		brights = {
			"#2A5A7F", -- bright black
			"#FF6B6B", -- bright red
			"#5FFFC4", -- bright green
			"#E8C294", -- bright yellow
			"#7EB3E8", -- bright blue
			"#B88FFF", -- bright magenta
			"#5FF4FF", -- bright cyan
			"#E0F0FF", -- bright white
		},
		-- UI extras, using colors already in your palette
		split = "#214969",
		scrollbar_thumb = "#214969",
		copy_mode_active_highlight_bg = { Color = "#a277ff" },
		copy_mode_active_highlight_fg = { Color = black },
		quick_select_label_bg = { Color = "#47FF9C" },
		quick_select_label_fg = { Color = black },
		tab_bar = {
			background = black,
			active_tab = { bg_color = "#033259", fg_color = "#47FF9C" },
			inactive_tab = { bg_color = black, fg_color = "#2A5A7F" },
			new_tab = { bg_color = black, fg_color = "#2A5A7F" },
		},
	},

	-- Old-school amber phosphor
	["Amber"] = {
		foreground = "#FFB000",
		background = black,
		cursor_bg = "#FFB000",
		cursor_border = "#FFB000",
		cursor_fg = black,
		selection_bg = "#4D3300",
		selection_fg = "#FFE0A0",
		ansi = {
			"#3D2A00", -- black   (dim burnt amber)
			"#FF5F1F", -- red     (red-orange: errors, deletions)
			"#FFB000", -- green   (core amber: success, additions)
			"#FFD24D", -- yellow  (gold: warnings)
			"#C98500", -- blue    (deep amber: dirs, paths)
			"#FF8A3D", -- magenta (orange: keywords, git branch)
			"#FFC766", -- cyan    (light amber)
			"#F0B45A", -- white
		},
		brights = {
			"#7A5A1E", -- bright black (comments / autosuggestions)
			"#FF7F4D",
			"#FFC940",
			"#FFE58A",
			"#E0A030",
			"#FFA366",
			"#FFD98C",
			"#FFF0D0",
		},
		split = "#3D2A00",
		scrollbar_thumb = "#3D2A00",
		copy_mode_active_highlight_bg = { Color = "#FFB000" },
		copy_mode_active_highlight_fg = { Color = black },
		quick_select_label_bg = { Color = "#FFE58A" },
		quick_select_label_fg = { Color = black },
		tab_bar = {
			background = black,
			active_tab = { bg_color = "#4D3300", fg_color = "#FFB000" },
			inactive_tab = { bg_color = black, fg_color = "#7A5A1E" },
			new_tab = { bg_color = black, fg_color = "#7A5A1E" },
		},
	},
}

config.color_scheme = "Original" -- which one to start with

-- Cmd+Opt+T toggles Original <-> Amber
wezterm.on("toggle-theme", function(window)
	local overrides = window:get_config_overrides() or {}
	local current = window:effective_config().color_scheme
	overrides.color_scheme = (current == "Original") and "Amber" or "Original"
	window:set_config_overrides(overrides)
end)

config.keys = {
	{ key = "t", mods = "CMD|ALT", action = wezterm.action.EmitEvent("toggle-theme") },
}

----------------------------------------------------------------------
-- Font
----------------------------------------------------------------------
-- Load user-installed fonts directly, even if macOS hasn't indexed them yet
config.font_dirs = { wezterm.home_dir .. "/Library/Fonts" }
config.font = wezterm.font_with_fallback({
	"MesloLGS Nerd Font Mono",
	"Symbols Nerd Font Mono",
})
config.font_size = 19
config.line_height = 1.1

----------------------------------------------------------------------
-- Window
----------------------------------------------------------------------
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.75
config.macos_window_background_blur = 80
config.window_padding = { left = 16, right = 16, top = 12, bottom = 8 }
config.adjust_window_size_when_changing_font_size = false
config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.6 }

config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 530
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

config.max_fps = 120
config.scrollback_lines = 10000

wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

return config
