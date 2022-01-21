local new_timer = vim.loop.new_timer
local nnoremap = require("tap.utils").nnoremap
local a = require("plenary.async_lib.async")
local log = require("plenary.log")

local escape_terminal_keys = function(keys)
    -- Escape characters with special meaning in shells
    return vim.fn.escape(keys, "*")
end

local get_test_command = function(file_name, pattern)
    local cmd = {"npx", "jest", file_name, "--watch"}
    if pattern then
        return vim.tbl_flatten({
            cmd,
            {
                "--testNamePattern",
                string.format('"%s"', escape_terminal_keys(pattern))
            }
        })
    end

    return cmd
end

local get_command_string = function(cmd) return table.concat(cmd, " ") end

local get_buffer_name = function(file_name)
    return string.format("jest-nvim:%s:terminal", file_name)
end

local sleep = a.wrap(function(delay, done)
    local timer = new_timer()
    timer:start(delay, 0, function()
        timer:close()
        done()
    end)
end, "vararg")

local schedule = a.async(function(func)
    vim.schedule(func)
    a.await(a.scheduler)
end)

local send_keys = a.async(function(keys)
    if keys == nil then return end

    a.await(schedule(function()
        vim.api
            .nvim_chan_send(vim.b.terminal_job_id, escape_terminal_keys(keys))
    end))

    -- Allow jest UI time to respond to keystrokes
    a.await(sleep(200))
end)

local run_in_term = a.async(function(buf_name, cmd, cwd, pattern)
    if vim.fn.bufexists(buf_name) ~= 0 then
        local term_bufnr = vim.fn.bufnr(buf_name)
        local wins_with_buf = vim.fn.win_findbuf(term_bufnr)

        -- close all open splits
        vim.tbl_map(function(win) vim.api.nvim_win_close(win, true) end,
                    wins_with_buf)

        vim.cmd("vsplit " .. buf_name)

        a.await(send_keys("t"))
        a.await(send_keys(pattern))
        a.await(send_keys("\r"))
    else
        -- open new split on right
        vim.cmd("vertical new")
        vim.fn.termopen(get_command_string(cmd), {cwd = cwd})
        vim.api.nvim_buf_set_name(0, buf_name)
    end

    a.await(schedule(function()
        -- swap back to previous window which is left
        vim.cmd("wincmd h")
    end))
end)

local function find_in_children(node, buf, predicate, max_depth)
    max_depth = max_depth or 5

    if max_depth == 0 then return nil end

    for child_node in node:iter_children() do
        if predicate(child_node) then return child_node end

        local ret = find_in_children(child_node, buf, predicate, max_depth - 1)
        if ret ~= nil then return ret end
    end

    return nil
end

local get_test_expression = function(node, buf)
    local target_text = {"test", "it", "describe"}

    if node:type() ~= "call_expression" then return nil end

    local child_test_node = find_in_children(node, buf, function(child_node)
        return child_node:type() == "identifier" and
                   vim.tbl_contains(target_text, vim.treesitter
                                        .get_node_text(child_node, buf))
    end, 1)

    return child_test_node ~= nil and node or nil
end

local function find_in_ancestors(node, buf, root, selector, acc)
    if root == node then return acc end

    local target_node = selector(node, buf)
    if target_node ~= nil then table.insert(acc, target_node) end

    return find_in_ancestors(node:parent(), buf, root, selector, acc)
end

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

local tbl_reverse = function(tbl)
    local rev_tbl = {}
    for i = #tbl, 1, -1 do table.insert(rev_tbl, tbl[i]) end
    return rev_tbl
end

local jest_regex_escape = function(str) return vim.fn.escape(str, "()|") end

local get_pattern_from_test_nodes = function(nodes, buf)
    local test_strings = vim.tbl_map(function(node)
        local str_node = find_in_children(node, buf, function(child_node)
            -- TODO: handle variables as test strings
            return child_node:type() == "string"
        end, 3)

        if str_node == nil then
            log.warn("couldn't find child string of test node")
            return ""
        end

        return vim.treesitter.get_node_text(str_node:child(1), buf)
    end, nodes)

    return table.concat(
               vim.tbl_map(jest_regex_escape, tbl_reverse(test_strings)), " ")
end

local get_nearest_pattern = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(vim.fn.win_getid())
    local test_nodes = get_test_nodes_from_cursor(bufnr, cursor)

    if #test_nodes == 0 then return nil end

    return get_pattern_from_test_nodes(test_nodes, bufnr)
end

local vim_regex_escape = function(regex)
    -- Vim regex needs to escape (, ) and |
    -- Because this is lua, we need to escape the escaping, hence \\ not \
    return vim.fn.escape(vim.fn.escape(regex, "()|"), "\\")
end

local file_pattern = vim_regex_escape(
                         "((__tests__|spec)/.*|(spec|test))\\.(js|jsx|coffee|ts|tsx)$")

local with_validate_file_path = function(fn)
    return function()
        local file_path = vim.fn.expand("%")

        if vim.regex(file_pattern):match_str(file_path) ~= nil then
            log.info("not a test file")
            return
        end

        return fn(file_path)
    end
end

local test_file = with_validate_file_path(function(file_path)
    local cwd = vim.fn.expand("%:p:h")
    local file_name = vim.fn.expand("%:p")

    local cmd = get_test_command(file_name)

    local buf_name = get_buffer_name(file_path)
    a.run(run_in_term(buf_name, cmd, cwd))
end)

local test_nearest = with_validate_file_path(function(file_path)
    local cwd = vim.fn.expand("%:p:h")
    local file_name = vim.fn.expand("%:p")

    local pattern = get_nearest_pattern()
    local cmd = get_test_command(file_name, pattern)

    if pattern == nil then
        log.info("couldn't find pattern")
        return
    end

    local buf_name = get_buffer_name(file_path)
    a.run(run_in_term(buf_name, cmd, cwd, pattern))
end)

nnoremap('t<C-f>', test_file)
nnoremap('t<C-n>', test_nearest)


