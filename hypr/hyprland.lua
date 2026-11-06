-- #############################################################################
-- HYPRLAND CONFIG — entry point (Hyprland 0.55+ Lua format)
-- Docs: https://wiki.hypr.land/Configuring/
--
-- NOTE: hl.include() does NOT exist in the Lua config API (verified against the
-- 0.56.2 API surface: hl.config, hl.bind, hl.monitor, hl.on, ... — no include).
-- Modules are loaded with Lua's standard require(), which resolves against this
-- directory because Hyprland adds ~/.config/hypr to package.path. The Lua state
-- is recreated on every config parse, so each require() re-executes on every
-- `hyprctl reload` — nothing goes stale.
-- #############################################################################

require('programs')
require('monitors')
require('misc')
require('autostart')
require('env')
require('permissions')
require('lookandfeel')
require('animations')
require('gestures')
require('devices')
require('keybindings')

-- End of config
