local M = {}

local function get_relative_path(path)
  if path == nil or path == '' then
    return '[No Name]'
  end

  local relative = vim.fn.fnamemodify(path, ':.')
  return relative == '' and path or relative
end

---@param bufnr number
---@param range? { line1: number, line2: number }
---@return string
local function get_this_context(bufnr, range)
  local path = vim.api.nvim_buf_get_name(bufnr)
  local location = get_relative_path(path)

  if range ~= nil then
    location = string.format('%s:%d-%d', location, range.line1, range.line2)
  end

  return '@' .. location
end

---@param bufnr number
---@param prompt string
---@param range? { line1: number, line2: number }
---@return string
function M.build_prompt(bufnr, prompt, range)
  local this_context = get_this_context(bufnr, range)
  local expanded, _ = prompt:gsub('@this', this_context)
  return expanded
end

return M
