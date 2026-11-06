local p = require('programs')
local terminal = p.terminal
local fileManager = p.fileManager
local menu = p.menu
local mainMod = p.mainMod

-- General keybinds
hl.bind(mainMod .. "+Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. "+C", hl.dsp.window.close())
hl.bind(mainMod .. "+M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. "+E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. "+V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. "+space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. "+P", hl.dsp.window.pseudo())
hl.bind(mainMod .. "+J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. "+F", hl.dsp.window.fullscreen())

-- Move focus
hl.bind(mainMod .. "+left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. "+right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. "+up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. "+down", hl.dsp.focus({ direction = "down" }))

-- Move window
hl.bind(mainMod .. "+SHIFT+left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. "+SHIFT+right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. "+SHIFT+up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. "+SHIFT+down", hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces
for i = 1, 9 do
    hl.bind(mainMod .. "+" .. i, hl.dsp.focus({ workspace = tostring(i) }))
end
hl.bind(mainMod .. "+0", hl.dsp.focus({ workspace = "10" }))

-- Move active window to workspace
for i = 1, 9 do
    hl.bind(mainMod .. "+SHIFT+" .. i, hl.dsp.window.move({ workspace = tostring(i) }))
end
hl.bind(mainMod .. "+SHIFT+0", hl.dsp.window.move({ workspace = "10" }))

-- Scratchpad
hl.bind(mainMod .. "+S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. "+SHIFT+S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll workspaces
hl.bind(mainMod .. "+mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. "+mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Drag windows
hl.bind(mainMod .. "+mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. "+mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Windows and workspaces rules
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
