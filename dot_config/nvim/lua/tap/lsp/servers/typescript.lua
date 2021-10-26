local lsp_utils = require('tap.lsp.utils')

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

function module.setup()
    local config = require'lspconfig/configs'.typescript.document_config

    lsp_utils.lspconfig_server_setup(server_name, {
        handlers = {
            ["window/logMessage"] = function(_, result, header)
                if result == nil or result.message == nil then
                    return
                end

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

                set_tsc_version(header.client_id, body.payload.version)
            end
        },
        cmd = vim.tbl_flatten({
            config.default_config.cmd, {"--log-level", "4"},
            {
                "--tsserver-log-file",
                vim.env.XDG_CACHE_HOME .. "/nvim/tsserver.log"
            },
            vim.env.LSP_DEBUG and {"--tsserver-log-verbosity", "verbose"} or {}
        }),
        on_attach = function(client, bufnr)
            client.resolved_capabilities.document_formatting = false
            lsp_utils.on_attach(client, bufnr)
        end
    })
end

return module
