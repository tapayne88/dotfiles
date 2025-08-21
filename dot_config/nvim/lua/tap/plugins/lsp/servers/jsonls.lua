local M = {}

M.ensure_installed = { 'jsonls' }

function M.setup()
  vim.lsp.config('jsonls', {
    init_options = { provideFormatter = false },
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  })

  vim.lsp.enable 'jsonls'
end

return M
