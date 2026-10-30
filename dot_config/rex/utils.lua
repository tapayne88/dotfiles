local M = {}

M.TERM = 'com.superlogical.terminal'
M.SHELL = 'com.superlogical.terminal.shell'

-- Processes running in the focused terminal
function M.fg_process()
  local proc = rex.block.call(M.TERM, 'process', {})
  return proc or {}
end

-- Equivalent of #{pane_current_path}
function M.current_cwd()
  local proc = M.fg_process()
  return (proc.foreground and proc.foreground.cwd) or (proc.child and proc.child.cwd)
end

-- Same set as the tmux is_vim regex: g?(view|n?vim?x?)(diff)?
function M.is_vim(name)
  if not name then
    return false
  end
  local n = name:gsub('^g', ''):gsub('diff$', '')
  return n == 'view' or n:match '^n?vim?x?$' ~= nil
end

local POPUP_BOUNDS = { 0.1, 0.1, 0.8, 0.8 }

-- Equivalent of display-popup -E -xC -yC -w 80% -h 80% -d "#{pane_current_path}"
---@param opts { command?: string[], label?: string, cwd?: string }
function M.popup(opts)
  local layer, err = rex.session.new_layer {
    bounds = POPUP_BOUNDS,
    focus = true,
    layout = rex.layout.block {
      flavor = M.SHELL,
      label = opts.label,
      options = { command = opts.command, cwd = opts.cwd or M.current_cwd() },
    },
  }
  if err ~= nil then
    error(err, 0)
  end
  return layer
end

-- Persistent popup terminal, the equivalent of the tmux "popup" session. The
-- popup terminal is labelled 'popup' and hidden by detaching it, so it keeps
-- running until shown again. Exit its shell to start afresh at the current path.
M.POPUP = 'popup'

-- The focused block and the active window
function M.focused_block()
  local view = rex.session.view {}
  for _, window in ipairs((view and view.windows) or {}) do
    if window.window_id == view.active_window_id then
      for _, layer in ipairs(window.layers or {}) do
        for _, block in ipairs(layer.blocks or {}) do
          if block.block_id == window.focused_block_id then
            return block, window
          end
        end
      end
      return nil, window
    end
  end
end

function M.find_popup()
  local list = rex.session.list_blocks {}
  for _, block in ipairs((list and list.blocks) or {}) do
    if block.label == M.POPUP then
      return block
    end
  end
end

-- Place the popup beside the focused block, then float it over the window
function M.show_popup(block_id, anchor_id)
  local _, err = rex.session.move_block { block_id = block_id, anchor_block_id = anchor_id }
  if err == nil then
    _, err = rex.session.float_block { block_id = block_id, bounds = POPUP_BOUNDS }
  end
  if err == nil then
    _, err = rex.session.focus_block { block_id = block_id }
  end
  if err ~= nil then
    error(err, 0)
  end
end

return M
