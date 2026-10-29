-- Port of dot_config/tmux/tmux.conf (plugins excluded). The tmux prefix is the
-- default C-b, so prefixed bindings are written as 'ctrl+b>…' sequences.

local TERM = 'com.superlogical.terminal'
local SHELL = 'com.superlogical.terminal.shell'

-- Processes running in the focused terminal
local function fg_process()
  local proc = rex.block.call(TERM, 'process', {})
  return proc or {}
end

-- Equivalent of #{pane_current_path}
local function current_cwd()
  local proc = fg_process()
  return (proc.foreground and proc.foreground.cwd) or (proc.child and proc.child.cwd)
end

-- Same set as the tmux is_vim regex: g?(view|n?vim?x?)(diff)?
local function is_vim(name)
  if not name then
    return false
  end
  local n = name:gsub('^g', ''):gsub('diff$', '')
  return n == 'view' or n:match '^n?vim?x?$' ~= nil
end

-- Equivalent of display-popup -E -xC -yC -w 80% -h 80% -d "#{pane_current_path}"
local function popup(argv)
  local _, err = rex.session.new_layer {
    bounds = { 0.1, 0.1, 0.8, 0.8 },
    focus = true,
    layout = rex.layout.block {
      flavor = SHELL,
      options = { command = argv, cwd = current_cwd() },
    },
  }
  if err ~= nil then
    error(err, 0)
  end
end

-- Source local config file - if it exists
local config_dir = (os.getenv 'XDG_CONFIG_HOME' or (os.getenv 'HOME' .. '/.config')) .. '/rex'
local local_config = io.open(config_dir .. '/local.lua', 'r')
if local_config then
  local_config:close()
  require 'local'
end

-- Tmux defaults
rex.bind('ctrl+b>c', 'client.tab.new')
rex.bind('ctrl+b>z', 'pane.zoom')
for i = 1, 9 do
  rex.bind('ctrl+b>' .. i, 'client.tab.goto', { index = i })
end
-- Press Ctrl+B twice to send one to the terminal
rex.bind('ctrl+b>ctrl+b', 'pane.send_key', { key = 'ctrl+b' })

-- New window at current path
rex.action {
  name = 'new_tab_here',
  title = 'New Tab at Current Path',
  run = function()
    local _, err = rex.session.new_window {
      layout = rex.layout.block { flavor = SHELL, options = { cwd = current_cwd() } },
    }
    if err ~= nil then
      error(err, 0)
    end
  end,
}
rex.bind('ctrl+b>shift+.', 'new_tab_here')

-- Fullscreen pane toggle
rex.bind('ctrl+x', 'pane.zoom')

-- keybindings to make resizing easier, repeatable until Escape/Enter
rex.mode('resize', { exclusive = true })
rex.action {
  name = 'resize_step',
  title = 'Resize Pane and Enter Resize Mode',
  args = { direction = 'string' },
  run = function(_, args)
    rex.client.queue('pane.resize', { direction = args.direction, amount = 2 })
    rex.client.queue('client.mode.enter', { name = 'resize' })
  end,
}
for key, dir in pairs { h = 'left', j = 'down', k = 'up', l = 'right' } do
  rex.bind('ctrl+b>shift+' .. key, 'resize_step', { direction = dir })
  rex.bind('resize/shift+' .. key, 'pane.resize', { direction = dir, amount = 2 })
  rex.bind('resize/' .. key, 'pane.resize', { direction = dir, amount = 2 })
end
rex.bind('resize/enter', 'client.mode.exit')

-- reload config
rex.bind('ctrl+b>r', 'client.config.reload')

-- Session switcher (replaces the fzf and tv tmux-sessions popups)
rex.bind('ctrl+b>ctrl+j', 'session.switch')
rex.bind('ctrl+b>s', 'session.switch')

-- Clear scrollback history - similar to zsh binding C-M-l to clear visibile history
rex.action {
  name = 'clear_history',
  title = 'Clear Scrollback',
  run = function()
    local _, err = rex.block.call(TERM, 'clear', {})
    if err ~= nil then
      error(err, 0)
    end
  end,
}
rex.bind('ctrl+alt+k', 'clear_history')

-- Split creation
rex.action {
  name = 'split_here',
  title = 'Split Pane at Current Path',
  args = { direction = 'string' },
  run = function(_, args)
    local _, err = rex.session.new_split {
      direction = args.direction,
      side = 'after',
      focus = true,
      layout = rex.layout.block { flavor = SHELL, options = { cwd = current_cwd() } },
    }
    if err ~= nil then
      error(err, 0)
    end
  end,
}
rex.bind('ctrl+b>shift+\\', 'split_here', { direction = 'horizontal' })
rex.bind('ctrl+b>\\', 'split_here', { direction = 'horizontal' })
rex.bind('ctrl+b>-', 'split_here', { direction = 'vertical' })
rex.bind('ctrl+b>shift+-', 'split_here', { direction = 'vertical' })

-- Reset pane sizes to current layout
rex.bind('ctrl+b>=', 'pane.balance')

-- Smart pane switching with awareness of Vim splits.
-- See: https://github.com/christoomey/vim-tmux-navigator
-- Returning false passes the key through to vim. focus_direction doesn't wrap,
-- so nothing happens at the edge of the window.
for key, dir in pairs { h = 'left', j = 'down', k = 'up', l = 'right' } do
  rex.bind('ctrl+' .. key, function()
    local fg = fg_process().foreground
    if fg and is_vim(fg.name) then
      return false
    end
    rex.session.focus_direction { direction = dir }
    return true
  end)
end

-- Provide way to clear terminal (since Ctrl-l is taken)
rex.bind('ctrl+alt+l', 'pane.send_key', { key = 'ctrl+l' })

-- lazygit popup
rex.action {
  name = 'lazygit_popup',
  title = 'Lazygit Popup',
  run = function()
    popup { 'lazygit' }
  end,
}
rex.bind('ctrl+b>g', 'lazygit_popup')

-- Not ported:
-- * Terminal/server options (history-limit, escape-time, default-terminal,
--   terminal-overrides, extended-keys, focus-events, allow-rename, mode-keys)
--   live in the Rex app settings.
-- * Status bar and theme: Rex draws its own tabs and sidebar.
-- * M-{ / M-} tab navigation: covered by Rex defaults.
-- * synchronize-panes (prefix a), select-layout even-* (prefix ! / @) and
--   swap with last pane (prefix C-o): no Rex equivalent.
-- * C-y copy mode and copy-mode-vi bindings: Rex has no copy mode, so C-y
--   always reaches the terminal.
-- * Pane hide/rejoin (prefix b / j / k / M).
-- TODO: these call tmux themselves and need Rex versions first:
-- * prefix i       tmux-cht.sh
-- * prefix C-w     tv treehouse
-- * prefix C-n     tv nic
-- * prefix M-w/M-x treehouse-tmux lease-session / release-current
-- * prefix P/M-p   persistent popup session
