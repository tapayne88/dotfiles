local lsp_utils = require "tap.lsp.utils"

local module = {}

function module.setup(lsp_server)
    lsp_server:setup(lsp_utils.get_default_config({
        on_attach = lsp_utils.on_attach,
        init_options = {provideFormatter = false},
        settings = {json = {schemas = require('schemastore').json.schemas()}}
    }))
end

return module
