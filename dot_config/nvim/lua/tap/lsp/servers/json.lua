local lsp_utils = require('tap.lsp.utils')

local module = {}

function module.setup()
    lsp_utils.lspconfig_server_setup("jsonls", {
        handlers = {
            ["textDocument/publishDiagnostics"] = lsp_utils.on_publish_diagnostics(
                "[jsonls] ")
        },
            cmd = {
                "node", lsp_utils.install_path("json") .. "/vscode-json/json-language-features/server/dist/node/jsonServerMain.js", "--stdio"
            },
        on_attach = lsp_utils.on_attach
    })
end

return module
