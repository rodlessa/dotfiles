-- #######################################################################################
-- HYPRLAND CONFIG — converted from legacy hyprland.conf (hyprlang) to the
-- Lua format introduced in Hyprland 0.55.
-- Docs: https://wiki.hypr.land/Configuring/ (see the 0.55+ / Lua pages)
-- #######################################################################################

----------------
-- PROGRAMS ----
----------------

local terminal = "alacritty"
local fileManager = "dolphin"
local menu = "hyprlauncher"
local mainMod = "SUPER"

----------------
-- MONITORS ----
----------------

hl.monitor({
	output = "DP-3",
	mode = "3440x1440@144",
	position = "2560x0",
	scale = 1,
})

------------------------
-- MISC TOP-LEVEL OPTS --
------------------------

-- NOTE: "splash = flase" in the original file was a typo (and "splash" is not
-- a documented top-level/misc key in the 0.55+ reference) — fixed to `false`
-- and placed under `misc`. Verify this key still does what you expect; if
-- Hyprland rejects it, drop it.
hl.config({
	misc = {
		disable_splash_rendering = false,
	},
	render = {
		direct_scanout = 1,
	},
	xwayland = {
		force_zero_scaling = true,
	},
})

hl.workspace_rule({
	workspace = "1",
	monitor = "DP-3",
	default = true,
})

----------------
-- AUTOSTART ---
----------------

hl.exec_cmd("nm-applet &")
hl.exec_cmd("waywallen-layer-shell")
hl.exec_cmd("waybar & waywallen --no-ui")
hl.exec_cmd("hyprctl dispatch focusmonitor DP-3 && hyprctl dispatch workspace 1")

--------------------------
-- ENVIRONMENT VARIABLES -
--------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

----------------
-- PERMISSIONS -
----------------

-- Requires ecosystem.enforce_permissions = true (restart required) — see below.
-- hl.config({ ecosystem = { enforce_permissions = true } })
-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

------------------------
-- LOOK AND FEEL -------
------------------------

hl.config({
	general = {
		gaps_in = 1,
		gaps_out = 5,
		border_size = 1,
		["col.active_border"] = "rgba(33ccffee) rgba(00ff99ee) 45deg",
		["col.inactive_border"] = "rgba(595959aa)",
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
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
		new_status = "master",
	},

	misc = {
		force_default_wallpaper = -1,
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

-- dwindle {} — empty block in the original, nothing to set.

--------------------------
-- ANIMATIONS & CURVES ---
--------------------------

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

--------------------------------
-- WORKSPACE RULES (commented) --
--------------------------------

-- "Smart gaps" / "No gaps when only" — uncomment if you want it.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--   name = "no-gaps-wtv1",
--   match = { float = false, workspace = "w[tv1]" },
--   border_size = 0,
--   rounding    = 0,
-- })
-- hl.window_rule({
--   name = "no-gaps-f1",
--   match = { float = false, workspace = "f[1]" },
--   border_size = 0,
--   rounding    = 0,
-- })

----------------
-- GESTURES ----
----------------

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

----------------
-- DEVICES -----
----------------

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

------------------
-- KEYBINDINGS ---
------------------

hl.bind(mainMod .. "+Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. "+C", hl.dsp.window.close())
hl.bind(
	mainMod .. "+M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit")
)
hl.bind(mainMod .. "+E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. "+V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. "+space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. "+P", hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. "+J", hl.dsp.layout("togglesplit")) -- dwindle
hl.bind(mainMod .. "+F", hl.dsp.window.fullscreen())

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. "+left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. "+right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. "+up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. "+down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. "+SHIFT+left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. "+SHIFT+right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. "+SHIFT+up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. "+SHIFT+down", hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
for i = 1, 9 do
	hl.bind(mainMod .. "+" .. i, hl.dsp.focus({ workspace = tostring(i) }))
end
hl.bind(mainMod .. "+0", hl.dsp.focus({ workspace = "10" }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 9 do
	hl.bind(mainMod .. "+SHIFT+" .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end
hl.bind(mainMod .. "+SHIFT+0", hl.dsp.window.move({ workspace = "10" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. "+S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. "+SHIFT+S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. "+mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. "+mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
-- (verify these two against the current hl.dsp.window API — "drag"/"resize"
-- semantics for mouse binds shifted slightly under the new dispatcher system)
hl.bind(mainMod .. "+mouse:272", hl.dsp.window.drag(), { drag = true })
hl.bind(mainMod .. "+mouse:273", hl.dsp.window.resize({}), { drag = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
-- WINDOWS AND WORKSPACES ------
--------------------------------

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})
