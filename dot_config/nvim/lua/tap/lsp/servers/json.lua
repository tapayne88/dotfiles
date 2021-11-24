local lsp_utils = require('tap.lsp.utils')

local module = {}

function module.setup()
    lsp_utils.lspconfig_server_setup("json", {
        on_attach = lsp_utils.on_attach,
        init_options = {provideFormatter = false},
        settings = {json = {schemas = require('schemastore').json.schemas()}}
    })
end

return module
