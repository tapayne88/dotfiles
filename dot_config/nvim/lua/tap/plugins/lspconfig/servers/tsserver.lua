local lspconfig_tsserver = require "lspconfig.server_configurations.tsserver"
local lsp_utils = require "tap.utils.lsp"

local key_name = function(client_id) return "client_" .. client_id end

local set_tsc_version = function(client_id, version)
    if vim.g.tsc_version == nil then vim.g.tsc_version = {} end

    local client_key = key_name(client_id)

    if vim.g.tsc_version[client_key] == nil then
        if version ~= nil then
            -- Very convoluted way to update global map
            local tsc_version = vim.g.tsc_version
            tsc_version[client_key] = version
            vim.g.tsc_version = tsc_version
        end
    end
end

local get_tsc_version = function()
    if vim.g.tsc_version ~= nil then
        local tsc_versions = vim.tbl_map(function(client)
            return vim.g.tsc_version[key_name(client.id)]
        end, lsp_utils.get_lsp_clients())

        local valid_versions = vim.tbl_filter(function(version)
            return version ~= nil
        end, tsc_versions)

        if #valid_versions > 0 then return valid_versions[1] end
    end
    return nil
end

local module = {get_tsc_version = get_tsc_version}

function module.setup(lsp_server)
    local default_options = lsp_server:get_default_options()

    lsp_server:setup(lsp_utils.merge_with_default_config({
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
            lspconfig_tsserver.default_config.cmd, {"--log-level", "4"},
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
    }))
end

return module
