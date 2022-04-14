local nnoremap = require("tap.utils").nnoremap
local ts = require("tap.jest-nvim.treesitter")
local utils = require("tap.jest-nvim.utils")
local a = require("plenary.async")

-- TODO:
--  - send shift-g before running next test (if buf exists)
--  - fix tab closing when other test file run
--  - expand logging

---@class Node
---@field iter_children fun()
---@field parent fun()
---@field child fun(id: number)

--- Run command with jest --watch in neovim's terminal, send updates to the same terminal
---@param buf_name string
---@param cmd string[]
---@param cwd string
---@param pattern? string|nil
---@return nil
local jest_test = function(buf_name, cmd, cwd, pattern)
    -- close open test splits
    utils.close_all_test_windows()

    -- We can only reuse the test runner based on buf_name as we can't tell if
    -- any running jest processes support this file
    if vim.fn.bufexists(buf_name) ~= 0 then
        utils.logger.debug("buffer found")

        vim.cmd("vsplit " .. buf_name)

        utils.send_keys("t") -- select test pattern in jest
        utils.send_keys(pattern) -- send pattern
        utils.send_keys("\r") -- send enter key
    else
        -- open new split on right
        vim.cmd("vertical new")
        local command = utils.get_command_string(
                            utils.command_with_pattern(cmd, pattern))

        utils.logger.debug("creating term buffer with command `" .. command ..
                               "`")

        vim.fn.termopen(command, {cwd = cwd})
        vim.api.nvim_buf_set_name(0, buf_name)
    end

    utils.schedule(function()
        -- swap back to previous window which is left
        vim.cmd("wincmd h")
    end)
end

local file_pattern = utils.regex_escape(
                         "((__tests__|spec)/.*|(spec|test))\\.(js|jsx|coffee|ts|tsx)$")

--- Run jest test
---@param pattern? string|nil
---@return nil
local run_test = function(pattern)
    local file_path = vim.api.nvim_buf_get_name(0)
    local test_root = utils.resolve_package_json_parent(file_path)

    utils.logger.debug("file_path", file_path)
    utils.logger.debug("test_root", test_root)

    if test_root == nil then
        utils.notify("couldn't find test root for " .. file_path,
                     vim.log.levels.WARN)
        return
    end

    local test_file_path =
        utils.get_relative_test_filename(file_path, test_root)
    utils.logger.debug("test_file_path", test_file_path)

    if not vim.regex(file_pattern):match_str(test_file_path) then
        utils.notify("not a test file", vim.log.levels.INFO)
        return
    end

    local buf_name = utils.get_buffer_name(vim.fn.expand("%"))
    local cmd = utils.get_test_command(test_file_path)

    utils.logger.debug("buf_name", buf_name)
    utils.logger.debug("cmd", cmd)

    utils.logger.debug("pattern", pattern)
    a.run(function() jest_test(buf_name, cmd, test_root, pattern) end)
end

--- Run jest tests for the current file
local test_file = function()
    utils.logger.debug("test_file")
    run_test()
end

--- Run jest tests for the nearest test node
local test_nearest = function()
    utils.logger.debug("test_nearest")
    local pattern = ts.get_nearest_pattern()

    if pattern == nil then
        utils.notify("couldn't find pattern", vim.log.levels.WARN)
        return
    end

    run_test(pattern)
end

nnoremap('t<C-f>', test_file, {description = "[Jest.nvim] Test file"})
nnoremap('t<C-n>', test_nearest, {description = "[Jest.nvm] Test nearest"})
