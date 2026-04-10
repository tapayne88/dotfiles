local M = {}

function M.setup()
  vim.lsp.config('yamlls', {
    init_options = { provideFormatter = false },
    settings = {
      yaml = {
        schemas = require('schemastore').yaml.schemas(),
        format = { enable = true },
      },
    },
  })

  vim.lsp.enable 'yamlls'
end

return M
