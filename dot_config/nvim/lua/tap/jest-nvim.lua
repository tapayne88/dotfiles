local timer = vim.loop.new_timer()
local nnoremap = require("tap.utils").nnoremap

local get_test_command = function(file_name, pattern)
    local cmd = {"yarn", "exec", "jest", file_name, "--", "--watch"}
    if pattern then
        return vim.tbl_flatten({
            cmd, {"--testNamePattern", string.format("\"%s\"", pattern)}
        })
    end

    return cmd
end

local get_command_string = function(cmd) return table.concat(cmd, " ") end

local get_buffer_name = function(file_name)
    return string.format("jest-nvim:%s", file_name)
end

local sleep = function(delay)
    delay = delay or 1000
    timer:start(delay, 0, function() timer:close() end)
end

local send_keys = function(keys)
    vim.api.nvim_chan_send(vim.b.terminal_job_id, keys)

    -- TODO: swap to sleep function above, requires async
    vim.cmd("sleep 1")
end

local run_in_term = function(buf_name, cmd, cwd, pattern)
    -- print("args", buf_name, vim.inspect(cmd), cwd, pattern)

    if vim.fn.bufexists(buf_name) ~= 0 then
        -- print("buf found")

        local term_bufnr = vim.fn.bufnr(buf_name)
        local wins_with_buf = vim.fn.win_findbuf(term_bufnr)

        -- close all open splits
        vim.tbl_map(function(win) vim.api.nvim_win_close(win, true) end,
                    wins_with_buf)

        vim.cmd("vsplit " .. buf_name)

        send_keys("t")
        if pattern then send_keys(pattern) end
        send_keys("\r")
    else
        -- print("buf not found")

        -- open new split on right
        vim.cmd("vertical new")
        vim.cmd("call termopen('" .. get_command_string(cmd) .. "', {'cwd':'" ..
                    cwd .. "'})")
        vim.api.nvim_buf_set_name(0, buf_name)
    end

    -- swap back to previous window which is left
    vim.cmd("wincmd h")
end

local test_file = function()
    local cwd = vim.fn.expand("%:p:h")
    local file_name = vim.fn.expand("%:t")

    local cmd = get_test_command(file_name)

    local buf_name = get_buffer_name(vim.fn.expand("%"))
    run_in_term(buf_name, cmd, cwd)
end

local node_is_test_function = function(node, buf)
    local target_text = {"test", "it", "describe"}

    return node:type() == "identifier" and
               vim.tbl_contains(target_text,
                                vim.treesitter.get_node_text(node, buf))
end

local function find_in_children(node, buf, target_fn)
    for child_node in node:iter_children() do
        if target_fn(child_node, buf) then return child_node end

        local ret = find_in_children(child_node, buf, target_fn)
        if ret ~= nil then return ret end
    end

    return nil
end

local node_is_target = function(node, buf, target_fn)
    if node:type() ~= "call_expression" then return end

    return find_in_children(node, buf, target_fn)
end

local get_pattern_from_test_node = function(buf, node)
    local str_node = find_in_children(node, buf, function(child_node)
        return child_node:type() == "string"
    end)

    return str_node and vim.treesitter.get_node_text(str_node:child(1), buf) or
               nil
end

local function find_test_node(buf, root, node)
    if root == node then return nil end

    if node_is_target(node, buf, node_is_test_function) then return node end

    return find_test_node(buf, root, node:parent())
end

local get_test_node_from_cursor = function(buf, cursor)
    local line = cursor[1] - 1
    local col = cursor[2]

    local parser = vim.treesitter.get_parser(buf)
    local ret
    parser:for_each_tree(function(tree)
        if ret then return end
        local root = tree:root()
        if root then
            local node = root:descendant_for_range(line, col, line, col)
            ret = find_test_node(buf, root, node)
        end
    end)
    return ret
end

local get_nearest_pattern = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(vim.fn.win_getid())
    local test_node = get_test_node_from_cursor(bufnr, cursor)

    if test_node == nil then return nil end

    return get_pattern_from_test_node(bufnr, test_node)
end

local test_nearest = function()
    local cwd = vim.fn.expand("%:p:h")
    local file_name = vim.fn.expand("%:t")

    local pattern = get_nearest_pattern()
    print("pattern", pattern)
    local cmd = get_test_command(file_name, pattern)

    if pattern == nil then
        print("couldn't find pattern")
        return
    end

    local buf_name = get_buffer_name(vim.fn.expand("%"))
    run_in_term(buf_name, cmd, cwd, pattern)
end

nnoremap('t<C-f>', test_file)
nnoremap('t<C-n>', test_nearest)
