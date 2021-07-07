local lsp_utils = require('tap.lsp.utils')

local log = require 'vim.lsp.log'
local util = require 'vim.lsp.util'
local api = vim.api

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

local function location_handler(_, method, result)
    if result == nil or vim.tbl_isempty(result) then
        local _ = log.info() and log.info(method, 'No location found')
        return nil
    end

    -- textDocument/definition can return Location or Location[]
    -- https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_definition

    print(vim.inspect(result))

    if vim.tbl_islist(result) then
        util.jump_to_location(result[1])

        if #result > 1 then
            util.set_qflist(util.locations_to_items(result))
            api.nvim_command("copen")
            api.nvim_command("wincmd p")
        end
    else
        util.jump_to_location(result)
    end
end

function module.setup()
    local config = require'lspconfig/configs'.typescript.document_config

    lsp_utils.lspconfig_server_setup(server_name, {
        handlers = {
            ["textDocument/publishDiagnostics"] = lsp_utils.on_publish_diagnostics(
                "[" .. server_name .. "] "),
            ["textDocument/definition"] = function(_, method, result)
                local patched_paths = vim.tbl_map(function(entry)
                    local uri = entry.uri:gsub("%%3A%%3A", "::"):gsub("%%40",
                                                                      "@")

                    return vim.tbl_extend("force", entry, {uri = uri})
                end, result)
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
            config.default_config.cmd,
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
