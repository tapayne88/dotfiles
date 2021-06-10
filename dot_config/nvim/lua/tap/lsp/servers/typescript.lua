local lspconfig_util = require('lspconfig.util')
local utils = require('tap.utils')
local lsp_utils = require('tap.lsp.utils')

-- Stolen from lspconfig/tsserver, would have been nice to be able to import
local get_ts_root_dir = function(fname)
    return lspconfig_util.root_pattern("tsconfig.json")(fname) or
               lspconfig_util.root_pattern("package.json", "jsconfig.json",
                                           ".git")(fname);
end

local yarn_v2_settings = function()
    local ts_root_dir = get_ts_root_dir(vim.fn.getcwd())
    local coc_settings = ts_root_dir and ts_root_dir ..
                             "/.vim/coc-settings.json" or ""

    return lspconfig_util.path.exists(coc_settings) and coc_settings or nil
end

-- Make tsserver work with yarn v2
local get_tsserver_exec = function(fn)
    local coc_settings = yarn_v2_settings()

    if coc_settings == nil then
        return lsp_utils.get_bin_path("tsserver", fn)
    else
        local file = io.open(coc_settings):read("*a")
        local coc_json = vim.fn.json_decode(file)
        local ts_key = "tsserver.tsdk"
        return fn(coc_json[ts_key] .. "/tsserver.js")
    end
end

local get_tsc_version = function(fn)
    if yarn_v2_settings() ~= nil then return end

    lsp_utils.get_bin_path("tsc", function(path)
        if path == nil then return fn(nil) end

        utils.get_os_command_output_async({path, "--version"},
                                          function(result, code, signal)
            if code ~= 0 then return fn(nil) end
            local version = string.match(result[1], "^Version (.*)$")

            if version == nil then
                print("failed to parse tsc version from [" .. result[1] .. "]")
                return fn(nil)
            end

            return fn(version)
        end)
    end)
end

local set_tsc_version = function(client_id)
    if vim.g.tsc_version == nil then vim.g.tsc_version = {} end

    local client_key = "client_" .. client_id

    if vim.g.tsc_version[client_key] == nil then
        get_tsc_version(function(version)
            if version ~= nil then
                -- Very convoluted way to update global map
                local tsc_version = vim.g.tsc_version
                tsc_version[client_key] = version
                vim.g.tsc_version = tsc_version
            end
        end)
    end
end

local module = {}

local server_name = "typescript"
local lspconfig_name = "tsserver"

function module.setup()
    -- Grab patched command following require('lspinstall').setup {}
    local config = require'lspconfig/configs'.typescript.document_config

    lsp_utils.lspconfig_server_setup(server_name, {
        handlers = {
            ["textDocument/publishDiagnostics"] = lsp_utils.on_publish_diagnostics(
                "[" .. server_name .. "] ")
        },
        cmd = vim.tbl_flatten({
            config.default_config.cmd,
            {
                "--tsserver-log-file",
                vim.env.XDG_CACHE_HOME .. "/nvim/tsserver.log"
            }, {"--tsserver-log-verbosity", "verbose"}
        }),
        on_attach = function(client, bufnr)
            set_tsc_version(client.id)

            client.resolved_capabilities.document_formatting = false
            lsp_utils.on_attach(client, bufnr)
        end
    })
end

return module
