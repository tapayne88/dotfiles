local new_timer = vim.loop.new_timer
local nnoremap = require("tap.utils").nnoremap
local a = require("plenary.async")
local Path = require("plenary.path")

--- Wrapper for vim.notify
---@param msg string
---@param level string
---@return nil
local notify =
    function(msg, level) vim.notify(msg, level, {title = "jest-nvim"}) end

--- Wrapper for vim.fn.escape
---@param chars string
---@return fun(str: string)
local escape = function(chars)
    return function(str) return vim.fn.escape(str, chars) end
end

local escape_terminal_keys = escape("*") --- Escape characters with special meaning in shells
local regex_escape = escape("()|") --- Escape regex characters

---@class Node
---@field iter_children fun()
---@field parent fun()
---@field child fun(id: number)

--- Get the test command for a given filename and test pattern
---@param file_name string
---@return string[]
local get_test_command = function(file_name)
    local cmd = {"npx", "jest", file_name, "--watch"}

    return cmd
end

--- Add pattern to command table
---@param cmd string[]
---@param pattern string
---@return string[]
local command_with_pattern = function(cmd, pattern)
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
local get_command_string = function(cmd) return table.concat(cmd, " ") end

--- Get test buffer name for file - one buffer per file
---@param file_name string
---@return string
local get_buffer_name = function(file_name)
    -- having :terminal suffix convinces telescope to put a terminal icon for
    -- the buffer in the buffer list
    return string.format("jest-nvim:%s:terminal", file_name)
end

--- Sleep to allow time for other processes to respond
---@param delay number
---@param done fun()
---@return nil
local sleep = a.wrap(function(delay, done)
    local timer = new_timer()
    timer:start(delay, 0, function()
        timer:close()
        done()
    end)
end, 2)

--- Use vim.schedule to register a function and await it before continuing
---@param func fun()
---@param done fun()
---@return nil
local schedule = a.wrap(function(func, done)
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
local send_keys = function(keys)
    if keys == nil then return end

    schedule(function()
        vim.api
            .nvim_chan_send(vim.b.terminal_job_id, escape_terminal_keys(keys))
    end)

    -- Allow jest UI time to respond to keystrokes
    sleep(200)
end

--- Run command with jest --watch in neovim's terminal, send updates to the same terminal
---@param buf_name string
---@param cmd string[]
---@param cwd string
---@param pattern? string|nil
---@return nil
local jest_test = function(buf_name, cmd, cwd, pattern)
    if vim.fn.bufexists(buf_name) ~= 0 then
        local term_bufnr = vim.fn.bufnr(buf_name)
        local wins_with_buf = vim.fn.win_findbuf(term_bufnr)

        -- close all open splits
        vim.tbl_map(function(win) vim.api.nvim_win_close(win, true) end,
                    wins_with_buf)

        vim.cmd("vsplit " .. buf_name)

        send_keys("t") -- select test pattern in jest
        send_keys(pattern) -- send pattern
        send_keys("\r") -- send enter key
    else
        -- open new split on right
        vim.cmd("vertical new")
        vim.fn.termopen(get_command_string(command_with_pattern(cmd, pattern)),
                        {cwd = cwd})
        vim.api.nvim_buf_set_name(0, buf_name)
    end

    schedule(function()
        -- swap back to previous window which is left
        vim.cmd("wincmd h")
    end)
end

--- Find child that passes predicate, limiting depth
---@param node Node
---@param predicate fun(node: Node)
---@param max_depth? number|nil
---@return Node|nil
local function find_in_children(node, predicate, max_depth)
    max_depth = max_depth or 5

    if max_depth == 0 then return nil end

    for child_node in node:iter_children() do
        if predicate(child_node) then return child_node end

        local ret = find_in_children(child_node, predicate, max_depth - 1)
        if ret ~= nil then return ret end
    end

    return nil
end

--- Return node if it has child test node
---@param node Node
---@param buf number
---@return string[]
local get_test_expression = function(node, buf)
    local target_text = {"test", "it", "describe"}

    if node:type() ~= "call_expression" then return nil end

    local child_test_node = find_in_children(node, function(child_node)
        return child_node:type() == "identifier" and
                   vim.tbl_contains(target_text, vim.treesitter
                                        .get_node_text(child_node, buf))
    end, 1)

    return child_test_node ~= nil and node or nil
end

--- Collect selected data from all parent nodes
---@param node Node
---@param buf number
---@param root Node
---@param selector fun(node: Node, buf: number): Node
---@param acc Node[]
---@return Node[]
local function find_in_ancestors(node, buf, root, selector, acc)
    if root == node then return acc end

    local target_node = selector(node, buf)
    if target_node ~= nil then table.insert(acc, target_node) end

    return find_in_ancestors(node:parent(), buf, root, selector, acc)
end

--- Get all parent test nodes for cursor position
---@param buf number
---@param cursor number[]
---@return Node[]
local get_test_nodes_from_cursor = function(buf, cursor)
    local line = cursor[1] - 1
    local col = cursor[2]

    local parser = vim.treesitter.get_parser(buf)
    local ret
    parser:for_each_tree(function(tree)
        if ret then return end
        local root = tree:root()
        if root then
            local node = root:descendant_for_range(line, col, line, col)
            ret = find_in_ancestors(node, buf, root, get_test_expression, {})
        end
    end)
    return ret
end

--- Reverse the order of a list
---@param tbl table
---@return table
local tbl_reverse = function(tbl)
    local rev_tbl = {}
    for i = #tbl, 1, -1 do table.insert(rev_tbl, tbl[i]) end
    return rev_tbl
end

--- Get test strings of test nodes
---@param nodes Node[]
---@param buf number
---@return string
local get_pattern_from_test_nodes = function(nodes, buf)
    local test_strings = vim.tbl_map(function(node)
        local str_node = find_in_children(node, function(child_node)
            -- TODO: handle variables as test strings
            return child_node:type() == "string"
        end, 3)

        if str_node == nil then
            notify("couldn't find child string of test node",
                   vim.log.levels.WARN)
            return ""
        end

        return vim.treesitter.get_node_text(str_node:child(1), buf)
    end, nodes)

    return table.concat(vim.tbl_map(regex_escape, tbl_reverse(test_strings)),
                        " ")
end

--- Get test string for cursor position
---@return string
local get_nearest_pattern = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(vim.fn.win_getid())
    local test_nodes = get_test_nodes_from_cursor(bufnr, cursor)

    if #test_nodes == 0 then return nil end

    return get_pattern_from_test_nodes(test_nodes, bufnr)
end

local file_pattern = regex_escape(
                         "((__tests__|spec)/.*|(spec|test))\\.(js|jsx|coffee|ts|tsx)$")

--- Get directory path of parent containing package.json file
---@param path string
---@return string
local function resolve_package_json_parent(path)
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
local get_relative_test_filename = function(file_path, test_root)
    return Path:new(file_path):make_relative(test_root)
end

--- HOF to create test runner
---@param fn fun(run: fun(pattern?: string|nil))
---@return fun()
local as_test_command = function(fn)
    return function()
        local file_path = vim.api.nvim_buf_get_name(0)
        local test_root = resolve_package_json_parent(file_path)

        if test_root == nil then
            notify("couldn't find test root for " .. file_path,
                   vim.log.levels.WARN)
            return
        end

        local test_file_path = get_relative_test_filename(file_path, test_root)

        if not vim.regex(file_pattern):match_str(test_file_path) then
            notify("not a test file", vim.log.levels.INFO)
            return
        end

        local buf_name = get_buffer_name(vim.fn.expand("%"))
        local cmd = get_test_command(test_file_path)

        local run = function(pattern)
            a.run(function()
                jest_test(buf_name, cmd, test_root, pattern)
            end)
        end

        return fn(run)
    end
end

--- Run jest tests for the current file
local test_file = as_test_command(function(run) run() end)

--- Run jest tests for the nearest test node
local test_nearest = as_test_command(function(run)
    local pattern = get_nearest_pattern()

    if pattern == nil then
        notify("couldn't find pattern", vim.log.levels.WARN)
        return
    end

    run(pattern)
end)

nnoremap('t<C-f>', test_file, {description = "[Jest.nvim] Test file"})
nnoremap('t<C-n>', test_nearest, {description = "[Jest.nvm] Test nearest"})
