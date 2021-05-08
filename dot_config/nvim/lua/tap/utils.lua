local api = vim.api
local Job = require('plenary.job')

local utils = {}

utils.lsp_symbols = {
    error = "",
    warning = "",
    info = "",
    hint = "",
    hint_alt = "",
    ok = " "
}

utils.lsp_colors = {
    error = "#BF616A",
    warning = "#EBCB8B",
    info = "#D8DEE9",
    hint = "#5E81AC"
}

function utils.get_os_command_output_async(cmd, fn, cwd)
    if type(cmd) ~= "table" then
        print('[get_os_command_output_async]: cmd has to be a table')
        return {}
    end
    local command = table.remove(cmd, 1)
    local job = Job:new({command = command, args = cmd, cwd = cwd})
    job:after(vim.schedule_wrap(function(j, code, signal)
        if code == 0 then return fn(j:result(), code, signal) end
        return fn(j:stderr_result(), code, signal)
    end))
    job:start()
    return job
end

function utils.get_os_command_output(cmd, cwd)
    if type(cmd) ~= "table" then
        print('[get_os_command_output]: cmd has to be a table')
        return {}
    end
    local command = table.remove(cmd, 1)
    local stderr = {}
    local stdout, ret = Job:new({
        command = command,
        args = cmd,
        cwd = cwd,
        on_stderr = function(_, data) table.insert(stderr, data) end
    }):sync()
    return stdout, ret, stderr
end

function utils.map_table_to_key(tbl, key)
    return vim.tbl_map(function(value) return value[key] end, tbl)
end

---check if a mapping already exists
---@param lhs string
---@param mode string
---@return boolean
local function has_map(lhs, mode)
    mode = mode or "n"
    return vim.fn.maparg(lhs, mode) ~= ""
end

local function validate_opts(opts)
    if not opts then return true end

    if type(opts) ~= "table" then return false, "opts should be a table" end

    if opts.buffer and type(opts.buffer) ~= "number" then
        return false, "The buffer key should be a number"
    end

    return true
end

local function validate_mappings(lhs, rhs, opts)
    vim.validate {
        lhs = {lhs, "string"},
        rhs = {
            rhs, function(a)
                local arg_type = type(a)
                return arg_type == "string" or arg_type == "function"
            end, "right hand side"
        },
        opts = {opts, validate_opts, "mapping options are incorrect"}
    }
end

-- Shamelessly stolen from akinsho/dotfiles
-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/lua/as/utils.lua
---create a mapping function factory
---@param mode string
---@param o table
---@return function
local function make_mapper(mode, o)
    -- copy the opts table as extends will mutate the opts table passed in otherwise
    local parent_opts = vim.deepcopy(o)
    ---Create a mapping
    ---@param lhs string
    ---@param rhs string|function
    ---@param opts table
    return function(lhs, rhs, opts)
        assert(lhs ~= mode, string.format(
                   "The lhs should not be the same as mode for %s", lhs))
        local _opts = opts and vim.deepcopy(opts) or {}

        validate_mappings(lhs, rhs, _opts)

        if _opts.check_existing and has_map(lhs) then
            return
        else
            -- don't pass this invalid key to set keymap
            _opts.check_existing = nil
        end

        -- add functions to a global table keyed by their index
        if type(rhs) == "function" then
            local fn_id = tap._create(rhs)
            rhs = string.format("<cmd>lua tap._execute(%s)<CR>", fn_id)
        end

        if _opts.bufnr then
            -- Remove the buffer from the args sent to the key map function
            local bufnr = _opts.bufnr
            _opts.bufnr = nil
            _opts = vim.tbl_extend("keep", _opts, parent_opts)
            api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, _opts)
        else
            api.nvim_set_keymap(mode, lhs, rhs,
                                vim.tbl_extend("keep", _opts, parent_opts))
        end
    end
end

local map_opts = {noremap = false, silent = true}
utils.nmap = make_mapper("n", map_opts)
utils.xmap = make_mapper("x", map_opts)
utils.imap = make_mapper("i", map_opts)
utils.vmap = make_mapper("v", map_opts)
utils.omap = make_mapper("o", map_opts)
utils.tmap = make_mapper("t", map_opts)
utils.smap = make_mapper("s", map_opts)
utils.cmap = make_mapper("c", {noremap = false, silent = false})

local noremap_opts = {noremap = true, silent = true}
utils.nnoremap = make_mapper("n", noremap_opts)
utils.xnoremap = make_mapper("x", noremap_opts)
utils.vnoremap = make_mapper("v", noremap_opts)
utils.inoremap = make_mapper("i", noremap_opts)
utils.onoremap = make_mapper("o", noremap_opts)
utils.tnoremap = make_mapper("t", noremap_opts)
utils.cnoremap = make_mapper("c", {noremap = true, silent = false})

-- Shamelessly stolen from akinsho/dotfiles
-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/lua/as/highlights.lua#L56
--- TODO eventually move to using `nvim_set_hl`
--- however for the time being that expects colors
--- to be specified as rgb not hex
---@param name string
---@param opts table
function utils.highlight(name, opts)
    local force = opts.force or false
    if name and vim.tbl_count(opts) > 0 then
        if opts.link and opts.link ~= "" then
            vim.cmd("highlight" .. (force and "!" or "") .. " link " .. name ..
                        " " .. opts.link)
        else
            local cmd = {"highlight", name}
            if opts.guifg and opts.guifg ~= "" then
                table.insert(cmd, "guifg=" .. opts.guifg)
            end
            if opts.guibg and opts.guibg ~= "" then
                table.insert(cmd, "guibg=" .. opts.guibg)
            end
            if opts.gui and opts.gui ~= "" then
                table.insert(cmd, "gui=" .. opts.gui)
            end
            if opts.guisp and opts.guisp ~= "" then
                table.insert(cmd, "guisp=" .. opts.guisp)
            end
            if opts.cterm and opts.cterm ~= "" then
                table.insert(cmd, "cterm=" .. opts.cterm)
            end
            vim.cmd(table.concat(cmd, " "))
        end
    end
end

-- Ditto above
function utils.augroup(name, commands)
    vim.cmd("augroup " .. name)
    vim.cmd("autocmd!")
    for _, c in ipairs(commands) do
        local command = c.command
        if type(command) == "function" then
            local fn_id = tap._create(command)
            command = string.format("lua tap._execute(%s)", fn_id)
        end
        vim.cmd(string.format("autocmd %s %s %s %s",
                              table.concat(c.events, ","),
                              table.concat(c.targets or {}, ","),
                              table.concat(c.modifiers or {}, " "), command))
    end
    vim.cmd("augroup END")
end

function utils.join(value, str, sep)
    sep = sep or ","
    str = str or ""
    value = type(value) == "table" and table.concat(value, sep) or value
    return str ~= "" and table.concat({value, str}, sep) or value
end

function utils.termcodes(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

return utils
