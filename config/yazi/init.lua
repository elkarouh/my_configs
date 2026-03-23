-- require("dual-pane"):setup({},)
-- require("dual-pane"):setup({  enabled = true,})



-- You can configure your bookmarks by lua language
local bookmarks = {}

local path_sep = package.config:sub(1, 1)
local home_path = ya.target_family() == "windows" and os.getenv("USERPROFILE") or os.getenv("HOME")
if ya.target_family() == "windows" then
  table.insert(bookmarks, {
    tag = "Scoop Local",
    
    path = (os.getenv("SCOOP") or home_path .. "\\scoop") .. "\\",
    key = "p"
  })
  table.insert(bookmarks, {
    tag = "Scoop Global",
    path = (os.getenv("SCOOP_GLOBAL") or "C:\\ProgramData\\scoop") .. "\\",
    key = "P"
  })
end
table.insert(bookmarks, {
  tag = "Desktop",
  path = home_path .. path_sep .. "Desktop" .. path_sep,
  key = "d"
})

require("yamb"):setup {
  -- Optional, the path ending with path seperator represents folder.
  bookmarks = bookmarks,
  -- Optional, recieve notification everytime you jump.
  jump_notify = true,
  -- Optional, the cli of fzf.
  cli = "fzf",
  -- Optional, a string used for randomly generating keys, where the preceding characters have higher priority.
  keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
  -- Optional, the path of bookmarks
  path = (ya.target_family() == "windows" and os.getenv("APPDATA") .. "\\yazi\\config\\bookmark") or
        (os.getenv("HOME") .. "/.config/yazi/bookmark"),
}
--------------------------------------------------
require("simple-tag"):setup({
  -- UI display mode (icon, text, hidden)
  ui_mode = "icon", -- (Optional)

  -- Disable tag key hints (popup in bottom right corner)
  hints_disabled = false, -- (Optional)

  -- linemode order: adjusts icon/text position. Fo example, if you want icon to be on the mose left of linemode then set linemode_order larger than 1000.
  -- More info: https://github.com/sxyazi/yazi/blob/077faacc9a84bb5a06c5a8185a71405b0cb3dc8a/yazi-plugin/preset/components/linemode.lua#L4-L5
  linemode_order = 500, -- (Optional)

  -- You can backup/restore this folder within the same OS (Linux, windows, or MacOS).
  -- But you can't restore backed up folder in the different OS because they use difference absolute path.
  -- save_path =  -- full path to save tags folder (Optional)
  --       - Linux/MacOS: os.getenv("HOME") .. "/.config/yazi/tags"
  --       - Windows: os.getenv("APPDATA") .. "\\yazi\\config\\tags"

  -- Set tag colors
  colors = { -- (Optional)
	  -- Set this same value with `theme.toml` > [mgr] > hovered > reversed
	  -- Default theme use "reversed = true".
	  -- More info: https://github.com/sxyazi/yazi/blob/077faacc9a84bb5a06c5a8185a71405b0cb3dc8a/yazi-config/preset/theme-dark.toml#L25
	  reversed = true, -- (Optional)

	  -- More colors: https://yazi-rs.github.io/docs/configuration/theme#types.color
    -- format: [tag key] = "color"
	  ["*"] = "#bf68d9", -- (Optional)
	  ["$"] = "green",
	  ["!"] = "#cc9057",
	  ["1"] = "cyan",
	  ["p"] = "red",
  },

  -- Set tag icons. Only show when ui_mode = "icon".
  -- Any text or nerdfont icons should work as long as you use nerdfont to render yazi.
  -- Default icon from mactag.yazi: ●; Some generic icons: , , 󱈤
  -- More icon from nerd fonts: https://www.nerdfonts.com/cheat-sheet
  icons = { -- (Optional)
    -- default icon
		default = "󰚋",

    -- format: [tag key] = "tag icon"
		["*"] = "*",
		["$"] = "",
		["!"] = "",
		["p"] = "",
  },

})
