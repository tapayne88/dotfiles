-- Seemless vim <-> rex navigation, mirroring aserowy/tmux.nvim's navigation.
-- The rex keymap (dot_config/rex/init.lua) passes C-hjkl through to nvim, so
-- nvim moves between its own splits and hands off to rex at the edge.
local rex_bin = require('tap.utils.mux').rex_bin

local M = {}

local directions = { h = 'left', j = 'down', k = 'up', l = 'right' }

-- Runs in the rex server against this terminal's session. Mirrors tmux.nvim's
-- persist_zoom by leaving the rex pane zoomed rather than navigating away.
local focus_script = [[
local view = rex.session.view {}
for _, window in ipairs((view and view.windows) or {}) do
  if window.window_id == view.active_window_id and window.zoomed_block_id then
    return
  end
end
rex.session.focus_direction { direction = rex.args.direction }
]]

---@param key 'h'|'j'|'k'|'l'
function M.move(key)
  local win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(key)
  if vim.api.nvim_get_current_win() == win then
    vim.system { rex_bin(), 'do', '-e', focus_script, 'direction=' .. directions[key] }
  end
end

function M.move_left()
  M.move 'h'
end

function M.move_bottom()
  M.move 'j'
end

function M.move_top()
  M.move 'k'
end

function M.move_right()
  M.move 'l'
end

function M.setup()
  -- stylua: ignore start
  vim.keymap.set('n', '<C-h>', M.move_left,   { desc = 'Swap to split left' })
  vim.keymap.set('n', '<C-j>', M.move_bottom, { desc = 'Swap to split below' })
  vim.keymap.set('n', '<C-k>', M.move_top,    { desc = 'Swap to split above' })
  vim.keymap.set('n', '<C-l>', M.move_right,  { desc = 'Swap to split right' })
  -- stylua: ignore end
end

return M
