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

-- Cmd+key runs a tmux prefix binding (sends C-b then the key), so the tmux.conf binds stay the source of truth
local function tmux(key)
	return wezterm.action.SendString("\x02" .. key)
end

config.keys = {
	{ key = "t", mods = "CMD|ALT", action = wezterm.action.EmitEvent("toggle-theme") },
	-- Cmd+arrows send Ctrl+h/j/k/l: vim-tmux-navigator moves across nvim splits and tmux panes
	{ key = "LeftArrow", mods = "CMD", action = wezterm.action.SendKey({ key = "h", mods = "CTRL" }) },
	{ key = "DownArrow", mods = "CMD", action = wezterm.action.SendKey({ key = "j", mods = "CTRL" }) },
	{ key = "UpArrow", mods = "CMD", action = wezterm.action.SendKey({ key = "k", mods = "CTRL" }) },
	{ key = "RightArrow", mods = "CMD", action = wezterm.action.SendKey({ key = "l", mods = "CTRL" }) },
	-- Cmd+Shift+arrows resize the tmux pane
	{ key = "LeftArrow", mods = "CMD|SHIFT", action = tmux("H") },
	{ key = "DownArrow", mods = "CMD|SHIFT", action = tmux("J") },
	{ key = "UpArrow", mods = "CMD|SHIFT", action = tmux("K") },
	{ key = "RightArrow", mods = "CMD|SHIFT", action = tmux("L") },

	-- panes (replaces font size on Cmd -/=; Ctrl -/= still zoom the font)
	{ key = "-", mods = "CMD", action = tmux("-") }, -- split, new pane below
	{ key = "=", mods = "CMD", action = tmux("%") }, -- Cmd+ split, new pane to the right
	{ key = "+", mods = "CMD|SHIFT", action = tmux("%") },
	{ key = "d", mods = "CMD", action = tmux("x") }, -- delete pane, no confirm
	{ key = "z", mods = "CMD", action = tmux("v") }, -- nvim in a new window
	{ key = "Backspace", mods = "CMD", action = tmux("z") }, -- zoom pane (toggle)
	{ key = "[", mods = "CMD", action = tmux("[") }, -- copy mode (scroll / search)

	-- windows (tmux windows act as tabs; the WezTerm tab bar is hidden)
	-- a s d sit next to the z x c v edit keys, which keep their usual meaning
	{ key = "s", mods = "CMD", action = tmux("c") }, -- new window
	{ key = "a", mods = "CMD", action = tmux("n") }, -- next window
	{ key = "a", mods = "CMD|SHIFT", action = tmux("N") }, -- previous window
	{ key = "d", mods = "CMD|SHIFT", action = tmux("X") }, -- delete window, no confirm
	{ key = "w", mods = "CMD", action = tmux("w") }, -- pick a window/session from a tree
	{ key = ",", mods = "CMD", action = tmux(",") }, -- rename window

	-- popups / tools
	{ key = "p", mods = "CMD", action = tmux("p") }, -- claude chat
	{ key = "e", mods = "CMD", action = tmux("e") }, -- gaufre
	{ key = "i", mods = "CMD", action = tmux("i") }, -- cht.sh
	{ key = "/", mods = "CMD", action = tmux(" ") }, -- hex cheat sheet (Cmd+Space is Spotlight)

	-- Cmd+r reloads both WezTerm and tmux configs
	{
		key = "r",
		mods = "CMD",
		action = wezterm.action.Multiple({ wezterm.action.ReloadConfiguration, tmux("r") }),
	},
}

-- Cmd+1..9 jump to tmux window N (base-index is 1 in tmux.conf)
for i = 1, 9 do
	table.insert(config.keys, { key = tostring(i), mods = "CMD", action = tmux(tostring(i)) })
end

----------------------------------------------------------------------
-- Font
----------------------------------------------------------------------
-- Load user-installed fonts directly, even if macOS hasn't indexed them yet
config.font_dirs = { wezterm.home_dir .. "/Library/Fonts" }
config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	-- icons: wezterm's bundled Symbols Nerd Font is v3.1 and lacks newer glyphs (e.g. the tmux RAM icon U+EFC5)
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
