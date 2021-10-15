local lsp_utils = require('tap.lsp.utils')

local module = {}

local server_name = "lua"
local lspconfig_name = "sumneko_lua"

function module.setup()
    local runtime_path = vim.split(package.path, ';')
    table.insert(runtime_path, "lua/?.lua")
    table.insert(runtime_path, "lua/?/init.lua")

    local settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Setup your lua path
                path = runtime_path
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim'}
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true)
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {enable = false}
        }
    }

    lsp_utils.lspconfig_server_setup(server_name, {
        handlers = {
            ["textDocument/publishDiagnostics"] = lsp_utils.on_publish_diagnostics
        },
        on_attach = lsp_utils.on_attach,
        settings = settings
    })
end

return module
