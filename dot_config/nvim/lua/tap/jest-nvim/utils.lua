local a = require 'plenary.async'
local sleep = require('plenary.async.util').sleep
local Path = require 'plenary.path'
local log = require 'plenary.log'

local debug = vim.fn.getenv 'DEBUG_JEST_NVIM'
if debug == vim.NIL then
  debug = false
end

local M = {}

M.logger = log.new { plugin = 'Jest.nvim', level = debug and 'debug' or 'info' }

--- Wrapper for vim.notify
---@param msg string
---@param level string
---@return nil
function M.notify(msg, level)
  vim.notify(msg, level, { title = 'jest-nvim' })
end

--- Wrapper for vim.fn.escape
---@param chars string
---@return fun(str: string)
function M.escape(chars)
  return function(str)
    return vim.fn.escape(str, chars)
  end
end

--- Get the test command for a given filename and test pattern
---@param file_name string
---@return string[]
function M.get_test_command(file_name)
  local cmd = { 'npm', 'test', '--', file_name, '--watch' }

  return cmd
end

local escape_terminal_keys = M.escape '*' --- Escape characters with special meaning in shells

M.regex_escape = M.escape '()|' --- Escape regex characters

--- Add pattern to command table
---@param cmd string[]
---@param pattern string
---@return string[]
function M.command_with_pattern(cmd, pattern)
  return pattern == nil and cmd
    or vim
      .iter({
        cmd,
        {
          '--testNamePattern',
          string.format('"%s"', M.regex_escape(escape_terminal_keys(pattern))),
        },
      })
      :flatten()
      :totable()
end

--- Convert command table to string
---@param cmd string[]
---@return string
function M.get_command_string(cmd)
  return table.concat(cmd, ' ')
end

-- having :terminal suffix convinces telescope to put a terminal icon for
-- the buffer in the buffer list
local test_buffer_name_format = 'jest-nvim:%s:terminal'
local test_buffer_name_pattern = 'jest%-nvim:.+:terminal'

--- Get test buffer name for file - one buffer per file
---@param file_name string
---@return string
function M.get_buffer_name(file_name)
  return string.format(test_buffer_name_format, file_name)
end

--- Check if buffer name is test runner
---@param buffer_name string
---@return boolean
function M.test_buffer_name(buffer_name)
  return string.find(buffer_name, test_buffer_name_pattern) ~= nil
end

--- Use vim.schedule to register a function and await it before continuing
---@param func fun()
---@param done fun()
---@return nil
M.schedule = a.wrap(function(func, done)
  vim.schedule(function()
    -- run our scheduled function
    func()
    -- complete our async function and allow coroutine to progress
    done()
  end)
end, 2)

--- Send keystrokes to the terminal running jest and wait before continuing
---@params keys string
---@return nil
function M.send_keys(keys)
  if keys == nil then
    return
  end

  M.logger.debug('sending keys', keys)

  M.schedule(function()
    vim.api.nvim_chan_send(vim.b.terminal_job_id, keys)
  end)

  -- Allow jest UI time to respond to keystrokes
  sleep(200)
end

--- Reverse the order of a list
---@param tbl table
---@return table
function M.tbl_reverse(tbl)
  local rev_tbl = {}
  for i = #tbl, 1, -1 do
    table.insert(rev_tbl, tbl[i])
  end
  return rev_tbl
end

--- Get directory path of parent containing package.json file
---@param path string
---@return string
function M.resolve_package_json_parent(path)
  local function _resolve_package_json_parent(_path)
    if _path.filename == Path.path.root() then
      return nil
    end

    local parent = _path:parent()
    if parent:joinpath('package.json'):exists() then
      return parent.filename
    end

    return _resolve_package_json_parent(parent)
  end

  return _resolve_package_json_parent(Path:new(path))
end

--- Get the test file path relative to the package.json
---@param file_path string
---@param test_root string
---@return string
function M.get_relative_test_filename(file_path, test_root)
  return Path:new(file_path):make_relative(test_root)
end

--- Close all open test runner windows
---@return nil
function M.close_all_test_windows()
  local test_buffers = vim.tbl_filter(function(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)
    return M.test_buffer_name(name)
  end, vim.api.nvim_list_bufs())

  M.logger.debug('test buffers', test_buffers)

  local wins_with_bufs = vim
    .iter(vim.tbl_map(function(bufnr)
      return vim.fn.win_findbuf(bufnr)
    end, test_buffers))
    :flatten()
    :totable()

  -- close all open splits
  vim.tbl_map(function(win)
    vim.api.nvim_win_close(win, true)
  end, wins_with_bufs)
end

return M
