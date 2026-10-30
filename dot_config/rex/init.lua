-- Port of dot_config/tmux/tmux.conf (plugins excluded). The tmux prefix is the
-- default C-b, so prefixed bindings are written as 'ctrl+b>…' sequences.

local utils = require 'utils'

-- Tmux defaults
rex.bind('ctrl+b>c', 'client.tab.new')
rex.bind('ctrl+b>z', 'pane.zoom')
for i = 1, 9 do
  rex.bind('ctrl+b>' .. i, 'client.tab.goto', { index = i })
end
-- Press Ctrl+B twice to send one to the terminal
rex.bind('ctrl+b>ctrl+b', 'pane.send_key', { key = 'ctrl+b' })

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
    local _, err = rex.block.call(utils.TERM, 'clear', {})
    if err ~= nil then
      error(err, 0)
    end
  end,
}
rex.bind('ctrl+alt+k', 'clear_history')

-- Split creation
rex.bind('ctrl+b>shift+\\', 'pane.split', { direction = 'right' })
rex.bind('ctrl+b>\\', 'pane.split', { direction = 'right' })
rex.bind('ctrl+b>-', 'pane.split', { direction = 'down' })
rex.bind('ctrl+b>shift+-', 'pane.split', { direction = 'down' })

-- Reset pane sizes to current layout
rex.bind('ctrl+b>=', 'pane.balance')

-- Smart pane switching with awareness of Vim splits.
-- See: https://github.com/christoomey/vim-tmux-navigator
-- Returning false passes the key through to vim. focus_direction doesn't wrap,
-- so nothing happens at the edge of the window.
for key, dir in pairs { h = 'left', j = 'down', k = 'up', l = 'right' } do
  rex.bind('ctrl+' .. key, function()
    local fg = utils.fg_process().foreground
    if fg and utils.is_vim(fg.name) then
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
    utils.popup { command = { 'lazygit' } }
  end,
}
rex.bind('ctrl+b>g', 'lazygit_popup')

-- nic popup
rex.action {
  name = 'nic_popup',
  title = 'Nic Popup',
  run = function()
    utils.popup { command = { 'tv', 'nic' } }
  end,
}
rex.bind('ctrl+b>ctrl+n', 'nic_popup')

-- lease a fresh treehouse worktree for the current pane's repo and open it with nic
rex.action {
  name = 'treehouse_lease_popup',
  title = 'Lease Treehouse Worktree',
  run = function()
    utils.popup { command = { 'treehouse-tmux', 'lease-session', utils.current_cwd() } }
  end,
}
rex.bind('ctrl+b>alt+w', 'treehouse_lease_popup')

-- switch back to the previous session, kill this one, and release its worktree lease
rex.action {
  name = 'treehouse_release_popup',
  title = 'Release Treehouse Worktree',
  run = function()
    utils.popup { command = { 'treehouse-tmux', 'release-current', utils.current_cwd() } }
  end,
}
rex.bind('ctrl+b>alt+x', 'treehouse_release_popup')

-- toggle terminal popup
rex.action {
  name = 'toggle_popup',
  title = 'Toggle Popup Terminal',
  run = function()
    local focused, window = utils.focused_block()
    if focused and focused.label == utils.POPUP then
      local _, err = rex.session.detach_block { block_id = focused.block_id }
      if err ~= nil then
        error(err, 0)
      end
      return
    end

    local existing = utils.find_popup()
    if not existing then
      utils.popup { label = utils.POPUP }
    elseif existing.placement == 'placed' and window and existing.window_id == window.window_id then
      rex.session.focus_block { block_id = existing.block_id }
    elseif focused then
      utils.show_popup(existing.block_id, focused.block_id)
    end
  end,
}
rex.bind('ctrl+b>shift+p', 'toggle_popup')

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
