-- ~/.config/yazi/init.lua

-- ───────────────────────────── Bookmarks (yamb) ──────────────────────────────
local home = os.getenv("HOME")

require("yamb"):setup({
	bookmarks = {
		{ tag = "Desktop", path = home .. "/Desktop/", key = "d" },
	},
	jump_notify = true, -- show a notification after each jump
	cli = "fzf",
	keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
	path = home .. "/.config/yazi/bookmark",
})

-- ─────────────────────────────── Tags (simple-tag) ───────────────────────────
-- Every tag listed below appears in the tag picker (T t / T s / T f),
-- in the order of its name. Tags are saved in ~/.config/yazi/tags.
require("simple-tag"):setup({
	ui_mode = "icon", -- "icon", "text" or "hidden" (T u cycles through them)

	icons = {
		default = "󰚋", -- used for tags without an icon of their own
		["!"] = "",
		["$"] = "",
		["*"] = "*",
		["1"] = "󰚋",
		["e"] = "●",
		["p"] = "",
		["q"] = "●",
		["w"] = "●",
	},

	colors = {
		["!"] = "#cc9057",
		["$"] = "green",
		["*"] = "#bf68d9",
		["1"] = "cyan",
		["e"] = "yellow",
		["p"] = "red",
		["q"] = "red",
		["w"] = "green",
	},
})
