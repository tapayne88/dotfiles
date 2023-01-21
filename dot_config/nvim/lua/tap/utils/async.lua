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

return M
