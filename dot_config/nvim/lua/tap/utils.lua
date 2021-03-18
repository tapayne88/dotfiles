local Job = require('plenary.job')

local utils = {}

function utils.get_os_command_output_async(cmd, fn, cwd)
  if type(cmd) ~= "table" then
    print('[get_os_command_output_async]: cmd has to be a table')
    return {}
  end
  local command = table.remove(cmd, 1)
  job = Job:new({ command = command, args = cmd, cwd = cwd })
  job:after(
    vim.schedule_wrap(
      function(j, code, signal)
        if code == 0 then
          return fn(j:result(), code, signal)
        end
        return fn(j:stderr_result(), code, signal)
      end
    )
  )
  job:start()
end

function utils.get_os_command_output(cmd, cwd)
  if type(cmd) ~= "table" then
    print('[get_os_command_output]: cmd has to be a table')
    return {}
  end
  local command = table.remove(cmd, 1)
  local stderr = {}
  local stdout, ret = Job:new({ command = command, args = cmd, cwd = cwd, on_stderr = function(_, data)
    table.insert(stderr, data)
  end }):sync()
  return stdout, ret, stderr
end

function utils.map_table_to_key(tbl, key)
  return vim.tbl_map(function(value)
    return value[key]
  end, tbl)
end

return utils
