local nnoremap = require("tap.utils").nnoremap

local get_test_command = function(file_name)
    return {"yarn", "exec", "jest", file_name, "--", "--watch"}
end

local get_command_string = function(cmd) return table.concat(cmd, " ") end

local get_buffer_name = function(cmd, cwd)
    return string.format("term:%s:%s", cwd, get_command_string(cmd))
end

local run_in_term = function(cmd, cwd)
    local buffer_name = get_buffer_name(cmd, cwd)

    print("buffer_name", buffer_name, vim.fn.bufexists(buffer_name))

    if vim.fn.bufexists(buffer_name) ~= 0 then
        print("buf found")

        local term_bufnr = vim.fn.bufnr(buffer_name)
        local wins_with_buf = vim.fn.win_findbuf(term_bufnr)

        -- close all open splits
        vim.tbl_map(function(win) vim.api.nvim_win_close(win, true) end,
                    wins_with_buf)

        vim.cmd("vsplit " .. buffer_name)
    else
        print("buf not found")

        -- open new split on right
        vim.cmd("vertical new")
        vim.cmd("call termopen('" .. get_command_string(cmd) .. "', {'cwd':'" ..
                    cwd .. "'})")
        vim.api.nvim_buf_set_name(0, buffer_name)
    end

    -- swap back to previous window which is left
    vim.cmd("wincmd h")
end

local test_file = function()
    local cwd = vim.fn.expand("%:p:h")
    local file_name = vim.fn.expand("%:t")

    local cmd = get_test_command(file_name)

    run_in_term(cmd, cwd)
end

nnoremap('t<C-f>', test_file)
