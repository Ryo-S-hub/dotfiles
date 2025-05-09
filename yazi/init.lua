require("git"):setup({
	show_branch = true,
	modified_sign = "M",
	deleted_sign = "D",
})

require("projects"):setup({
	save = {
		method = "yazi", -- yazi | lua
		lua_save_path = "", -- comment out to get the default value
		-- windows: "%APPDATA%/yazi/state/projects.json"
		-- unix: "~/.local/state/yazi/projects.json"
	},
	last = {
		update_after_save = true,
		update_after_load = true,
		load_after_start = false,
	},
	merge = {
		quit_after_merge = false,
	},
	notify = {
		enable = true,
		title = "Projects",
		timeout = 3,
		level = "info",
	},
})

require("full-border"):setup()
