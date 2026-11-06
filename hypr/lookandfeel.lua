hl.config({
	general = {
		gaps_in = 1,
		gaps_out = 5,
		border_size = 1,
		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "master",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	master = {
		new_status = "slave",
		allow_small_split = false,
		mfact = 0.5,
		orientation = "right",
		smart_resizing = true,
		drop_at_cursor = true,
		new_on_top = true,
		focus_master_on_close = true,
		center_master_fallback = "left",
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = false,
	},

	input = {
		kb_layout = "us",
		kb_variant = "intl",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 1,
		sensitivity = 0,
		touchpad = {
			natural_scroll = false,
		},
	},
})