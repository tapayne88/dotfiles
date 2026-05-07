local M = {}

local defaults = {
  target = {
    pane_id = nil,
    pane_title = 'Cursor Agent',
  },
  send = {
    submit = true,
    use_bracketed_paste = true,
  },
  refresh = {
    enable_autoread = true,
    events = { 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' },
    watch_files = true,
  },
}

M.options = vim.deepcopy(defaults)

---@param opts table|nil
---@return table
function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', vim.deepcopy(defaults), opts or {})
  return M.options
end

return M
