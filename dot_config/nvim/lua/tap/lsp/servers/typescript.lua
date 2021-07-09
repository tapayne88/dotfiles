local lsp_utils = require('tap.lsp.utils')

local log = require 'vim.lsp.log'
local util = require 'vim.lsp.util'
local api = vim.api
local uv = vim.loop

local set_tsc_version = function(client_id, version)
    if vim.g.tsc_version == nil then vim.g.tsc_version = {} end

    local client_key = "client_" .. client_id

    if vim.g.tsc_version[client_key] == nil then
        if version ~= nil then
            -- Very convoluted way to update global map
            local tsc_version = vim.g.tsc_version
            tsc_version[client_key] = version
            vim.g.tsc_version = tsc_version
        end
    end
end

local module = {}

local server_name = "typescript"
local lspconfig_name = "tsserver"

local function with_logger(name, fn)
    local print_in_context = function(msgs)
        msgs = type(msgs) == "table" and msgs or {msgs}
        vim.tbl_map(function(item) print("       ", item, "\n") end, msgs)
    end
    return function(...)
        print("[START] " .. name)
        local res = fn(print_in_context, ...)
        print("[ END ] " .. name)
        return res
    end
end

local function getBufs()
    return vim.tbl_map(function(bufnr)
        return "[" .. bufnr .. "] " .. vim.api.nvim_buf_get_name(bufnr)
    end, vim.api.nvim_list_bufs())
end

--- Return or create a buffer for a uri.
-- @param uri (string): The URI
-- @return bufnr.
-- @note Creates buffer but does not load it
local uri_to_bufnr = with_logger("uri_to_bufnr", function(print, uri)
    local scheme = assert(uri:match('^([a-zA-Z]+[a-zA-Z0-9+-.]*):.*'),
                          'URI must contain a scheme: ' .. uri)
    print("uri " .. uri)
    print({"bufs", unpack(getBufs())})
    if scheme == 'file' then
        local f = vim.fn.bufadd(vim.uri_to_fname(uri))
        print({"file bufs", unpack(getBufs())})
        return f
    else
        local f = vim.fn.bufadd(uri)
        print({"other bufs", unpack(getBufs())})
        return f
    end
end)

-- @private
local function sort_by_key(fn)
    return function(a, b)
        local ka, kb = fn(a), fn(b)
        assert(#ka == #kb)
        for i = 1, #ka do if ka[i] ~= kb[i] then return ka[i] < kb[i] end end
        -- every value must have been equal here, which means it's not less than.
        return false
    end
end
local position_sort = sort_by_key(function(v)
    return {v.start.line, v.start.character}
end)

-- Gets the zero-indexed lines from the given uri.
-- For non-file uris, we load the buffer and get the lines.
-- If a loaded buffer exists, then that is used.
-- Otherwise we get the lines using libuv which is a lot faster than loading the buffer.
-- @param uri string uri of the resource to get the lines from
-- @param rows number[] zero-indexed line numbers
-- @return table<number string> a table mapping rows to lines
local get_lines = with_logger("get_lines", function(print, uri, rows)
    rows = type(rows) == "table" and rows or {rows}

    local function buf_lines(bufnr)
        local lines = {}
        for _, row in pairs(rows) do
            lines[row] =
                (vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false) or {""})[1]
        end
        return lines
    end

    -- load the buffer if this is not a file uri
    -- Custom language server protocol extensions can result in servers sending URIs with custom schemes. Plugins are able to load these via `BufReadCmd` autocmds.
    if uri:sub(1, 4) ~= "file" then
        local bufnr = uri_to_bufnr(uri)
        vim.fn.bufload(bufnr)
        return buf_lines(bufnr)
    end

    local filename = vim.uri_to_fname(uri)

    -- use loaded buffers if available
    if vim.fn.bufloaded(filename) == 1 then
        local bufnr = vim.fn.bufnr(filename, false)
        return buf_lines(bufnr)
    end

    -- get the data from the file
    local fd = uv.fs_open(filename, "r", 438)
    if not fd then return "" end
    local stat = uv.fs_fstat(fd)
    local data = uv.fs_read(fd, stat.size, 0)
    uv.fs_close(fd)

    local lines = {} -- rows we need to retrieve
    local need = 0 -- keep track of how many unique rows we need
    for _, row in pairs(rows) do
        if not lines[row] then need = need + 1 end
        lines[row] = true
    end

    local found = 0
    local lnum = 0

    for line in string.gmatch(data, "([^\n]*)\n?") do
        if lines[lnum] == true then
            lines[lnum] = line
            found = found + 1
            if found == need then break end
        end
        lnum = lnum + 1
    end

    -- change any lines we didn't find to the empty string
    for i, line in pairs(lines) do if line == true then lines[i] = "" end end
    return lines
end)

--- Returns the items with the byte position calculated correctly and in sorted
--- order, for display in quickfix and location lists.
---
-- @param locations (table) list of `Location`s or `LocationLink`s
-- @returns (table) list of items
local locations_to_items = with_logger("locations_to_items",
                                       function(print, locations)
    local items = {}
    local grouped = setmetatable({}, {
        __index = function(t, k)
            local v = {}
            rawset(t, k, v)
            return v
        end
    })
    for _, d in ipairs(locations) do
        -- locations may be Location or LocationLink
        local uri = d.uri or d.targetUri
        local range = d.range or d.targetSelectionRange
        table.insert(grouped[uri], {start = range.start})
    end

    local keys = vim.tbl_keys(grouped)
    table.sort(keys)
    -- TODO(ashkan) I wish we could do this lazily.
    for _, uri in ipairs(keys) do
        local rows = grouped[uri]
        table.sort(rows, position_sort)
        local filename = vim.uri_to_fname(uri)

        -- list of row numbers
        local uri_rows = {}
        for _, temp in ipairs(rows) do
            local pos = temp.start
            local row = pos.line
            table.insert(uri_rows, row)
        end

        -- get all the lines for this uri
        local lines = get_lines(uri, uri_rows)

        for _, temp in ipairs(rows) do
            local pos = temp.start
            local row = pos.line
            local line = lines[row] or ""
            local col = pos.character
            table.insert(items, {
                filename = filename,
                lnum = row + 1,
                col = col + 1,
                text = line
            })
        end
    end
    return items
end)

--- Jumps to a location.
---
-- @param location (`Location`|`LocationLink`)
-- @returns `true` if the jump succeeded
local jump_to_location = with_logger("jump_to_location",
                                     function(print, location)
    -- location may be Location or LocationLink
    local uri = location.uri or location.targetUri
    if uri == nil then return end
    local bufnr = uri_to_bufnr(uri)
    -- Save position in jumplist
    vim.cmd "normal! m'"

    -- Push a new item into tagstack
    local from = {vim.fn.bufnr('%'), vim.fn.line('.'), vim.fn.col('.'), 0}
    local items = {{tagname = vim.fn.expand('<cword>'), from = from}}
    vim.fn.settagstack(vim.fn.win_getid(), {items = items}, 't')

    --- Jump to new location (adjusting for UTF-16 encoding of characters)
    api.nvim_set_current_buf(bufnr)
    api.nvim_buf_set_option(0, 'buflisted', true)
    local range = location.range or location.targetSelectionRange
    local row = range.start.line
    local col = util._get_line_byte_from_position(0, range.start)
    api.nvim_win_set_cursor(0, {row + 1, col})
    return true
end)

-- @private
--- Jumps to a location. Used as a handler for multiple LSP methods.
-- @param _ (not used)
-- @param method (string) LSP method name
-- @param result (table) result of LSP method; a location or a list of locations.
---(`textDocument/definition` can return `Location` or `Location[]`
local location_handler = with_logger("location_handler",
                                     function(print, _, method, result)
    if result == nil or vim.tbl_isempty(result) then
        local _ = log.info() and log.info(method, 'No location found')
        return nil
    end

    -- textDocument/definition can return Location or Location[]
    -- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_definition

    if vim.tbl_islist(result) then
        jump_to_location(result[1])

        if #result > 1 then
            util.set_qflist(locations_to_items(result))
            api.nvim_command("copen")
        end
    else
        jump_to_location(result)
    end
end)

function module.setup()
    local config = require'lspconfig/configs'.typescript.document_config

    lsp_utils.lspconfig_server_setup(server_name, {
        init_options = {hostInfo = "neovim", logVerbosity = "verbose"},
        handlers = {
            ["textDocument/publishDiagnostics"] = lsp_utils.on_publish_diagnostics(
                "[" .. server_name .. "] "),
            ["textDocument/definition"] = function(_, method, result)
                location_handler(_, method, result)
            end,
            ["window/logMessage"] = function(_, _, result, client_id)
                local msg = result.message:match(
                                "%[tsclient%] processMessage (.*)")

                if msg == nil then return end

                local parsed_msg = vim.fn.json_decode(msg)
                if parsed_msg.type ~= "event" or parsed_msg.event ~= "telemetry" then
                    return
                end

                local body = vim.tbl_extend("keep", parsed_msg.body or {},
                                            {payload = {version = nil}})

                if body.payload.version == nil then return end

                set_tsc_version(client_id, body.payload.version)
            end
        },
        cmd = vim.tbl_flatten({
            vim.env.HOME ..
                "/git/github.com/typescript-language-server/server/lib/cli.js",
            {"--stdio"},
            -- need verbose log level to get telemetry window/logMessage messages (needed above)
            {"--log-level", "4"},
            {
                "--tsserver-log-file",
                vim.env.XDG_CACHE_HOME .. "/nvim/tsserver.log"
            }, {"--tsserver-log-verbosity", "verbose"}
        }),
        on_attach = function(client, bufnr)
            client.resolved_capabilities.document_formatting = false
            lsp_utils.on_attach(client, bufnr)
        end
    })
end

return module
