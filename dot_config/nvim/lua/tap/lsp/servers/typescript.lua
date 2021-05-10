local lspconfig_util = require('lspconfig.util')
local utils = require('tap.utils')
local lsp_utils = require('tap.lsp.utils')

-- Stolen from lspconfig/tsserver, would have been nice to be able to import
local get_ts_root_dir = function(fname)
    return lspconfig_util.root_pattern("tsconfig.json")(fname) or
               lspconfig_util.root_pattern("package.json", "jsconfig.json",
                                           ".git")(fname);
end

-- Make tsserver work with yarn v2
local get_tsserver_exec = function(fn)
    local ts_root_dir = get_ts_root_dir(vim.fn.getcwd())
    local coc_settings = ts_root_dir and ts_root_dir ..
                             "/.vim/coc-settings.json" or ""

    -- not yarn v2 project
    if lspconfig_util.path.exists(coc_settings) == false then
        return lsp_utils.get_bin_path("tsserver", fn)
    else
        local file = io.open(coc_settings):read("*a")
        local coc_json = vim.fn.json_decode(file)
        local ts_key = "tsserver.tsdk"
        return fn(coc_json[ts_key] .. "/tsserver.js")
    end
end

local get_tsc_version = function(fn)
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

local module = {}

local server_name = "typescript"
local lspconfig_name = "tsserver"

function module.patch_install()
    local config = require"lspinstall/util".extract_config(lspconfig_name)
    config.default_config.cmd[1] =
        "./node_modules/.bin/typescript-language-server"

    require'lspinstall/servers'[server_name] =
        vim.tbl_extend('error', config, {
            install_script = [=[
    ! test -f package.json && npm init -y --scope=lspinstall || true
    npm install typescript-language-server@latest
    ]=]
        })
end

function module.setup()
    get_tsserver_exec(function(tsserver_bin)
        if (tsserver_bin == nil) then return end

        -- Grab patched command following require('lspinstall').setup {}
        local config = require'lspconfig/configs'.typescript.document_config

        lsp_utils.lspconfig_server_setup(server_name, {
            handlers = {
                ["textDocument/publishDiagnostics"] = lsp_utils.on_publish_diagnostics(
                    "[" .. server_name .. "] ")
            },
            cmd = vim.tbl_flatten({
                config.default_config.cmd, {"--tsserver-path", tsserver_bin}
            }),
            on_attach = function(client, bufnr)
                client.resolved_capabilities.document_formatting = false
                lsp_utils.on_attach(client, bufnr)
            end
        })
    end)

    get_tsc_version(function(version)
        if version ~= nil then vim.b.tsc_version = version end
    end)
end

return module
