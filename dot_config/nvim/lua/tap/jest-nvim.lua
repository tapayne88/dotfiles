local timer = vim.loop.new_timer()
local nnoremap = require("tap.utils").nnoremap

local get_test_command = function(file_name, pattern)
    local cmd = {"yarn", "exec", "jest", file_name, "--", "--watch"}
    if pattern then
        return vim.tbl_flatten({cmd, {"--testNamePattern", pattern}})
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

local get_nearest_pattern = function() return "should render the app once" end

local test_nearest = function()
    local cwd = vim.fn.expand("%:p:h")
    local file_name = vim.fn.expand("%:t")

    local pattern = get_nearest_pattern()
    local cmd = get_test_command(file_name, pattern)

    local buf_name = get_buffer_name(vim.fn.expand("%"))
    run_in_term(buf_name, cmd, cwd, pattern)
end

nnoremap('t<C-f>', test_file)
nnoremap('t<C-n>', test_nearest)
