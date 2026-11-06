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