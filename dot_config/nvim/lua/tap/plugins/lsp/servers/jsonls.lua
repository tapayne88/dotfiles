local lsp_utils = require 'tap.utils.lsp'

local M = {}

M.ensure_installed = { 'jsonls' }

function M.setup()
  require('lspconfig').jsonls.setup(lsp_utils.merge_with_default_config {
    init_options = { provideFormatter = false },
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  })
end

return M
