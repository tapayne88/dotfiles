local lsp_utils = require('tap.lsp.utils')

local npm_packages = [[
  ! test -f package.json && npm init -y --scope=lspinstall || true
  npm install vscode-langservers-extracted@latest
]]

local module = {}

local server_name = "eslint"
local lspconfig_name = "eslint"

function module.patch_install()
    local config = require"lspinstall/util".extract_config(lspconfig_name)
    config.default_config.cmd[1] =
        "./node_modules/.bin/vscode-eslint-language-server"

    require'lspinstall/servers'[server_name] =
        vim.tbl_extend('error', config, {install_script = npm_packages})
end

function module.setup()
    lsp_utils.lspconfig_server_setup(server_name, {
        handlers = {
            ["textDocument/publishDiagnostics"] = lsp_utils.on_publish_diagnostics
        },
        on_attach = lsp_utils.on_attach,
        settings = {packageManager = 'yarn'}
    })
end

return module
