local lsp_utils = require('tap.lsp.utils')

local module = {}

function module.setup()
    lsp_utils.lspconfig_server_setup("json", {
        handlers = {
            ["textDocument/publishDiagnostics"] = lsp_utils.on_publish_diagnostics(
                "[jsonls] ")
        },
        on_attach = lsp_utils.on_attach
    })
end

return module
