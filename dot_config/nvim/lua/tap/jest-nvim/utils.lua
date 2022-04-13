local a = require("plenary.async")
local sleep = require("plenary.async.util").sleep
local Path = require("plenary.path")

local M = {}

--- Wrapper for vim.notify
---@param msg string
---@param level string
---@return nil
function M.notify(msg, level) vim.notify(msg, level, {title = "jest-nvim"}) end

--- Wrapper for vim.fn.escape
---@param chars string
---@return fun(str: string)
function M.escape(chars)
    return function(str) return vim.fn.escape(str, chars) end
end

--- Get the test command for a given filename and test pattern
---@param file_name string
---@return string[]
function M.get_test_command(file_name)
    local cmd = {"npx", "jest", file_name, "--watch"}

    return cmd
end

local escape_terminal_keys = M.escape("*") --- Escape characters with special meaning in shells

--- Add pattern to command table
---@param cmd string[]
---@param pattern string
---@return string[]
function M.command_with_pattern(cmd, pattern)
    return pattern == nil and cmd or vim.tbl_flatten({
        cmd,
        {
            "--testNamePattern",
            string.format('"%s"', escape_terminal_keys(pattern))
        }
    })
end

--- Convert command table to string
---@param cmd string[]
---@return string
function M.get_command_string(cmd) return table.concat(cmd, " ") end

--- Get test buffer name for file - one buffer per file
---@param file_name string
---@return string
function M.get_buffer_name(file_name)
    -- having :terminal suffix convinces telescope to put a terminal icon for
    -- the buffer in the buffer list
    return string.format("jest-nvim:%s:terminal", file_name)
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
    if keys == nil then return end

    M.schedule(function()
        vim.api
            .nvim_chan_send(vim.b.terminal_job_id, escape_terminal_keys(keys))
    end)

    -- Allow jest UI time to respond to keystrokes
    sleep(200)
end

--- Reverse the order of a list
---@param tbl table
---@return table
function M.tbl_reverse(tbl)
    local rev_tbl = {}
    for i = #tbl, 1, -1 do table.insert(rev_tbl, tbl[i]) end
    return rev_tbl
end

--- Get directory path of parent containing package.json file
---@param path string
---@return string
function M.resolve_package_json_parent(path)
    local function _resolve_package_json_parent(_path)
        if _path.filename == Path.path.root() then return nil end

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

return M
