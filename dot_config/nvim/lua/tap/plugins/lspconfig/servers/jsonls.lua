local lsp_utils = require 'tap.utils.lsp'

local module = {}

function module.setup(lsp_server)
  lsp_server:setup(lsp_utils.merge_with_default_config {
    init_options = { provideFormatter = false },
    settings = { json = { schemas = require('schemastore').json.schemas() } },
  })
end

return module
