local wezterm = require 'wezterm'
local act = wezterm.action
local io = require 'io';
local os = require 'os';
local wsl_domains = wezterm.default_wsl_domains()
local gpus = wezterm.gui.enumerate_gpus()

wezterm.on("gui-startup", function(cmd)
  -- local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  -- see https://github.com/wez/wezterm/issues/1794
  -- window:gui_window():toggle_fullscreen()
end)
--
for _, domain in ipairs(wsl_domains) do
  domain.default_cwd = "~"
end

wezterm.on('update-status', function(window, pane)
  -- Custom status bar content
  local date = wezterm.strftime '%Y-%m-%d %H:%M:%S'
  window:set_right_status(wezterm.format {
    { Text = date },
  })
end)

wezterm.on('open-uri', function(window, pane, uri)
  local user = os.getenv('USER')
  local start, _ = string.find(uri, '/Users/' .. user)
  if start == 1 then
    local direction = 'Up'
    local hx_pane = pane:tab():get_pane_direction(direction)
    if hx_pane == nil then
      local action = wezterm.action{
        SplitPane={
          direction = direction,
          command = { args = { 'emacsclient -n -c', uri } }
          -- command = { args = { '/auto/home/ekhassan/bin/ec', uri } }
        };
      };
      window:perform_action(action, pane);
    else
      local action = wezterm.action.SendString(':open ' .. uri .. '\r\n')
      window:perform_action(action, hx_pane);
    end
    -- prevent the default action from opening in a browser
    return false
  end
  -- otherwise, by not specifying a return value, we allow later
  -- handlers and ultimately the default action to caused the
  -- URI to be opened in the browser
end)

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
local function basename(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local SOLID_LEFT_ARROW = utf8.char(0xe0ba)
local SOLID_LEFT_MOST = utf8.char(0x2588)
local SOLID_RIGHT_ARROW = utf8.char(0xe0bc)

local ADMIN_ICON = utf8.char(0xf49c)

local CMD_ICON = utf8.char(0xe62a)
local NU_ICON = utf8.char(0xe7a8)
local PS_ICON = utf8.char(0xe70f)
local ELV_ICON = utf8.char(0xfc6f)
local WSL_ICON = utf8.char(0xf83c)
local YORI_ICON = utf8.char(0xf1d4)
local NYA_ICON = utf8.char(0xf61a)

local VIM_ICON = utf8.char(0xe62b)
local PAGER_ICON = utf8.char(0xf718)
local FUZZY_ICON = utf8.char(0xf0b0)
local HOURGLASS_ICON = utf8.char(0xf252)
local SUNGLASS_ICON = utf8.char(0xf9df)

local PYTHON_ICON = utf8.char(0xf820)
local NODE_ICON = utf8.char(0xe74e)
local DENO_ICON = utf8.char(0xe628)
local LAMBDA_ICON = utf8.char(0xfb26)

local SUP_IDX = { "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹", "¹⁰",
  "¹¹", "¹²", "¹³", "¹⁴", "¹⁵", "¹⁶", "¹⁷", "¹⁸", "¹⁹", "²⁰" }
local SUB_IDX = { "₁", "₂", "₃", "₄", "₅", "₆", "₇", "₈", "₉", "₁₀",
  "₁₁", "₁₂", "₁₃", "₁₄", "₁₅", "₁₆", "₁₇", "₁₈", "₁₉", "₂₀" }

-------------------------------------------------------------------------------------------------------------------------------
-- Better Unicode characters for slanted tabs
local SLANT_LEFT = utf8.char(0xe0b2)  -- 
local SLANT_RIGHT = utf8.char(0xe0b0) -- 
local SLANT_LEFT_THIN = utf8.char(0xe0b3)  -- 
local SLANT_RIGHT_THIN = utf8.char(0xe0b1) -- 

-- Enhanced process icons
local PROCESS_ICONS = {
  ["nvim"] = VIM_ICON,
  ["vim"] = VIM_ICON,
  ["emacs"] = utf8.char(0xe926),
  ["zsh"] = utf8.char(0xf489),
  ["bash"] = utf8.char(0xf489),
  ["fish"] = utf8.char(0xf739),
  ["ksh"] = utf8.char(0xf489),
  ["python"] = PYTHON_ICON,
  ["node"] = NODE_ICON,
  ["deno"] = DENO_ICON,
  ["git"] = utf8.char(0xf1d3),
  ["docker"] = utf8.char(0xf308),
  ["ssh"] = utf8.char(0xf489),
  ["htop"] = utf8.char(0xf85a),
  ["default"] = utf8.char(0xf120),
}

local function get_process_icon(process_name)
  local exec_name = basename(process_name):gsub("%.exe$", ""):lower()
  return PROCESS_ICONS[exec_name] or PROCESS_ICONS["default"]
end

-- Tab title formatting function
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local edge_background = "#121212"
  local background = "#4E4E4E"
  local foreground = "#1C1B19"
  local dim_foreground = "#3A3A3A"

  if tab.is_active then
    background = "#FBB829"
  elseif hover then
    background = "#FF8700"
  end

  local edge_foreground = background
  local process_name = tab.active_pane.foreground_process_name
  local exec_name = basename(process_name):gsub("%.exe$", "")
  -- Fixed: Use tab.active_pane.title instead of tab:get_title()
  local user_title = tab.active_pane.title
  local pane_title = user_title and #user_title > 0 and user_title or exec_name

  local left_arrow = tab.tab_index == 0 and SOLID_LEFT_MOST or SOLID_LEFT_ARROW
  local id = SUB_IDX[tab.tab_index + 1]
  local pid = SUP_IDX[tab.active_pane.pane_index + 1]
  local title = " " .. wezterm.truncate_right(pane_title, max_width - 6) .. " "

  return {
    { Attribute = { Intensity = "Bold" } },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = left_arrow },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = id },
    { Text = title },
    { Foreground = { Color = dim_foreground } },
    { Text = pid },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
    { Attribute = { Intensity = "Normal" } },
  }
end)

-- Vim navigation functions
local function is_vim(pane)
  -- this is set by the plugin, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == 'true'
end

local direction_keys = {
  Left = 'h',
  Down = 'j',
  Up = 'k',
  Right = 'l',
  -- reverse lookup
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}

local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == 'resize' and 'META' or 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
        }, pane)
      else
        if resize_or_move == 'resize' then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

wezterm.on('trigger-vim-with-scrollback', function(window, pane)
  -- Retrieve the text from the pane
  local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)

  -- Create a temporary file to pass to vim
  local name = os.tmpname()
  local f = io.open(name, 'w+')
  f:write(text)
  f:flush()
  f:close()

  -- Open a new window running emacs client and tell it to open the file
  window:perform_action(
    act.SpawnCommandInNewWindow {
      -- args = { 'emacsclient', '-n', '-c', name },
      args = { '/auto/home/ekhassan/bin/ec', name },
    },
    pane
  )

  -- Wait "enough" time for vim to read the file before we remove it.
  -- The window creation and process spawn are asynchronous wrt. running
  -- this script and are not awaitable, so we just pick a number.
  --
  -- Note: We don't strictly need to remove this file, but it is nice
  -- to avoid cluttering up the temporary directory.
  wezterm.sleep_ms(1000)
  os.remove(name)
end)

local config = {
  set_environment_variables                  = { WEZTERM = "wezterm", },
  initial_cols                               = 80,
  initial_rows                               = 25,
  -- front_end                                  = "Software",
  -- enable_wayland                             = false,
  -- front_end                                  = "WebGpu",
  -- webgpu_preferred_adapter                   = gpus[1],
  -- webgpu_force_fallback_adapter              = true,
  color_scheme                               = "Builtin Solarized Dark",
  font_size                                  = 16,
  font                                       = wezterm.font {
    -- family = 'FiraCode NFM',
    family = 'FiraCode',
    weight = 'Light',
    stretch = 'Normal',
    style = 'Normal',
    harfbuzz_features = { 'cv29', 'cv30', 'ss01', 'ss03', 'ss06', 'ss07', 'ss09' },
  },
  window_decorations                         = "RESIZE",
  -- window_decorations                         = "NONE",
  use_ime                                    = true,
  window_background_opacity                  = 1.0,
  tab_max_width                              = 36,
  use_fancy_tab_bar                          = false,
  tab_bar_at_bottom                          = true,
  adjust_window_size_when_changing_font_size = false,
  audible_bell                               = 'Disabled',
  check_for_updates                          = false,
  inactive_pane_hsb                          = {
    hue = 1.0,
    saturation = 1.0,
    brightness = 1.0,
  },
  default_prog                               = { '/bin/ksh', '-l' },
  launch_menu                                = {},
  colors                                     = {
    foreground = '#C0C5CE',
    background = '#2B303B',
    ansi = {
      '#4C4C4C', -- black
      '#FF3C3C', -- red
      '#0DBC79', -- green
      '#E5E510', -- yellow
      '#3B8EEA', -- blue
      '#BC3FBC', -- magenta
      '#11A8CD', -- cyan
      '#E5E5E5', -- white
    },
    brights = {
      '#666666', -- black
      '#F14C4C', -- red
      '#23D18B', -- green
      '#F5F543', -- yellow
      '#3B8EEA', -- blue
      '#D670D6', -- magenta
      '#29B8DB', -- cyan
      '#E5E5E5', -- white
    },
    tab_bar = {
      background = "#1a1b26",
      new_tab = { 
        bg_color = "#1a1b26", 
        fg_color = "#7aa2f7", 
        intensity = "Bold" 
      },
      new_tab_hover = { 
        bg_color = "#24283b", 
        fg_color = "#ff9e64", 
        intensity = "Bold" 
      },
      active_tab = { 
        bg_color = "#7aa2f7", 
        fg_color = "#1a1b26",
        intensity = "Bold"
      },
      inactive_tab = {
        bg_color = "#24283b",
        fg_color = "#a9b1d6"
      },
      inactive_tab_hover = {
        bg_color = "#32344a",
        fg_color = "#ff9e64"
      }
    } 
  },
  disable_default_key_bindings               = true,
  exit_behavior                              = 'Close',
  force_reverse_video_cursor                 = true,
  hide_tab_bar_if_only_one_tab               = true,
  scrollback_lines                           = 100000,
  use_dead_keys                              = false,
  unicode_version                            = 14,
  window_close_confirmation                  = 'NeverPrompt',
  window_padding                             = {
    left = 0,
    right = 0,
    top = '0.2cell',
    bottom = 0,
  },
  wsl_domains                                = wsl_domains,
  leader                                     = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1500, },
  keys                                       = {
    -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
    { key = "a", mods = "LEADER|CTRL", action = wezterm.action { SendString = "\x01" } },
    { key = 'c', mods = 'CTRL|SHIFT',  action = act.CopyTo 'ClipboardAndPrimarySelection' },
    { key = 'v', mods = 'CTRL|SHIFT',  action = act.PasteFrom 'Clipboard' },
    -- { key = 'v', mods = 'CTRL',        action = act.PasteFrom 'PrimarySelection' },
    { key = 's', mods = 'LEADER',      action = act.Search("CurrentSelectionOrEmptyString") },

    {
      key = "r",
      mods = "CTRL|SHIFT",
      action = wezterm.action.PromptInputLine {
        description = "Rename Tab",
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      }},
    -----------------------
    --  PANE
    -----------------------
    -- split into panels
    {
      key = '\\',
      mods = 'LEADER', -- LEADER key is Ctrl-a
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' }
    },
    {
      key = ']',
      mods = 'LEADER',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' }
    }, -- LEADER key is Ctrl-a
    { key = "z",          mods = "LEADER",     action = "TogglePaneZoomState" }, -- LEADER key is Ctrl-a
    -- move focus between panels
    { key = 'RightArrow', mods = 'SHIFT',      action = act.ActivatePaneDirection 'Right' },
    { key = 'LeftArrow',  mods = 'SHIFT',      action = act.ActivatePaneDirection 'Left' },
    { key = 'DownArrow',  mods = 'SHIFT',      action = act.ActivatePaneDirection 'Down' },
    { key = 'UpArrow',    mods = 'SHIFT',      action = act.ActivatePaneDirection 'Up' },
    -- adjust panel size
    -- CAVEAT there is an asymetry between the shortcuts because of a BUG !!!!
    -- { key = 'LeftArrow',  mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { "Left", 3 } },  -- DOESN'T WORK
    { key = 'LeftArrow',  mods = 'CTRL',       action = act.AdjustPaneSize { "Left", 3 } },
    -- { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { "Right", 3 } }, -- DOESN'T WORK
    { key = 'RightArrow', mods = 'CTRL',       action = act.AdjustPaneSize { "Right", 3 } },
    { key = 'UpArrow',    mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { "Up", 3 } },
    { key = 'DownArrow',  mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { "Down", 3 } },

    -----------------------
    --  TAB
    -----------------------
    { key = 't',          mods = 'CTRL',       action = act.SpawnTab 'CurrentPaneDomain' },
    { key = "F4", mods = "CTRL", action = wezterm.action { CloseCurrentTab = { confirm = true } } },
    -- move focus between tabs
    { key = "LeftArrow",  mods = "CTRL",       action = wezterm.action { ActivateTabRelative = -1 } },
    { key = "RightArrow", mods = "CTRL",       action = wezterm.action { ActivateTabRelative = 1 } },
    -- -----------------------
    { key = 'PageUp',     mods = "CTRL|SHIFT", action = act.ScrollByPage(-1) },
    { key = 'PageDown',   mods = "CTRL|SHIFT", action = act.ScrollByPage(1) },
    --{ key = 'PageUp',     action = act.ScrollByPage(-1) },
    --{ key = 'PageDown',   action = act.ScrollByPage(1) },

    {
      key = 'End',
      mods = 'CTRL|SHIFT',
      action = act.CopyMode 'MoveToScrollbackBottom',
    },
    {
      key = 'Home',
      mods = 'CTRL|SHIFT',
      action = act.CopyMode 'MoveToScrollbackTop',
    },

    {
      key = 'E',
      mods = 'CTRL|SHIFT',
      action = act.PromptInputLine {
        description = 'Enter new name for tab',
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      },
    },
    --  MODE
    { key = "Escape", mods = "LEADER",                         action = act.ActivateCopyMode },
    {
      key = "e", 
      mods = "LEADER", -- LEADER key is Ctrl-a
      action = act.EmitEvent 'trigger-vim-with-scrollback',      
      -- action = wezterm.action { EmitEvent =  "trigger-vim-with-scrollback" }
    },
    { key = 'C',      mods = 'CTRL|SHIFT',                     action = wezterm.action.CopyTo 'Clipboard' },
    { key = '-',      mods = 'CTRL',                           action = wezterm.action.DecreaseFontSize },
    { key = '+',      mods = 'CTRL',                           action = wezterm.action.IncreaseFontSize },
    { key = 'V',      mods = 'CTRL|SHIFT',                     action = wezterm.action.PasteFrom 'Clipboard' },
    { key = '0',      mods = 'CTRL',                           action = wezterm.action.ResetFontSize },
    { key = 'F11',    action = wezterm.action.ToggleFullScreen },
    { key = 'Enter',  mods = 'ALT',                            action = wezterm.action.Nop },
    --
  },
  hyperlink_rules                            = { { regex = '\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b', format = '$0' }, },
}

config.status_update_interval = 1000
config.window_frame = {
  font = wezterm.font { family = 'Roboto', weight = 'Bold' },
  font_size = 10.0,
}

return config
