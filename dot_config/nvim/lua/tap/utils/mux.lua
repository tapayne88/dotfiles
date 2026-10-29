-- Terminal multiplexer detection, kept free of plugin dependencies so plugin
-- specs can use it while lazy.nvim is still loading them.
local M = {}

---Whether to target rex rather than tmux. tmux wins when nvim runs in tmux
---inside rex, as tmux owns the panes. Matches nic and treehouse-tmux.
---@return boolean
function M.use_rex()
  return vim.env.TMUX == nil and vim.env.REX_SESSION ~= nil
end

---The rex CLI matching the server that runs this terminal
---@return string
function M.rex_bin()
  if vim.env.REX_BIN_DIR then
    return vim.env.REX_BIN_DIR .. '/rex'
  end
  return 'rex'
end

return M
