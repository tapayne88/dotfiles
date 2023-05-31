local a = require 'plenary.async'
local Job = require 'plenary.job'

local M = {}

--- Run cmd async and trigger callback on completion - wrapped with plenary.async
---@param cmd string[]
---@param cwd string|nil
---@param fn fun(result: string[], code: number, signal: number)
M.get_os_command_output_async = a.wrap(function(cmd, cwd, fn)
  if type(cmd) ~= 'table' then
    print '[get_os_command_output_async]: cmd has to be a table'
    return {}
  end
  local command = table.remove(cmd, 1)
  local job = Job:new { command = command, args = cmd, cwd = cwd }
  job:after(vim.schedule_wrap(function(j, code, signal)
    if code == 0 then
      return fn(j:result(), code, signal)
    end
    return fn(j:stderr_result(), code, signal)
  end))
  job:start()
end, 3)

---Read file contents
---@param path string
---@return unknown
function M.read_file(path)
  local err_open, fd = a.uv.fs_open(path, 'r', 438)
  assert(not err_open, err_open)

  local err_stat, stat = a.uv.fs_fstat(fd)
  assert(not err_stat, err_stat)

  local err_read, data = a.uv.fs_read(fd, stat.size, 0)
  assert(not err_read, err_read)

  local err_close = a.uv.fs_close(fd)
  assert(not err_close, err_close)

  return data
end

---Attempt to get the global asdf executable path of a tool
---@param tool_name string tool name
---@return string|nil
M.get_asdf_global_executable = function(tool_name)
  local home_dir = vim.fn.getenv 'HOME'

  local res, code =
    M.get_os_command_output_async({ 'asdf', 'which', tool_name }, home_dir)

  if code ~= 0 then
    require('tap.utils').logger.warn(
      '[get_asdf_global_executable] failed to find asdf node executable in '
        .. home_dir
    )
    return nil
  end

  local node_path = res[1]

  require('tap.utils').logger.info(
    '[get_asdf_global_executable] using asdf node executable ' .. node_path
  )

  return node_path
end

---Attempt to get the global asdf version of a tool
---@param tool_name string tool name
---@return string
M.get_asdf_global_version = function(tool_name)
  local tool_versions_raw = M.read_file(os.getenv 'HOME' .. '/.tool-versions')
  local tool_versions_parsed = vim.split(tool_versions_raw, '\n')

  for _, line in ipairs(tool_versions_parsed) do
    local tool_version = vim.split(line, ' ')
    if tool_version[1] == tool_name then
      return tool_version[2]
    end
  end

  return ''
end

return M
