local M = {}

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
