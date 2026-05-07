local notify_in_debug = require('tap.utils').notify_in_debug

local M = {}

local notify_opts = { title = 'Cursor' }

---@param message string|nil
function M.error(message)
  vim.notify(message, vim.log.levels.ERROR, notify_opts)
end

---@param message string
function M.warn(message)
  vim.notify(message, vim.log.levels.WARN, notify_opts)
end

---@param message string
function M.info(message)
  notify_in_debug(message, vim.log.levels.INFO, notify_opts)
end

return M
