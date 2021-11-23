local lsp_utils = require('tap.lsp.utils')

local module = {}

function module.setup()
    lsp_utils.lspconfig_server_setup("json", {
        on_attach = function(client, bufnr)
            -- Prevent document_formatting, that's diagnosticls' job
            client.resolved_capabilities.document_formatting = false
            lsp_utils.on_attach(client, bufnr)
        end,
        settings = {json = {schemas = require('schemastore').json.schemas()}}
    })
end

return module
