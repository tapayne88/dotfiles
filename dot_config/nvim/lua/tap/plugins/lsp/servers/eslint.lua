local lsp_utils = require 'tap.utils.lsp'

local M = {}

M.ensure_installed = { 'eslint' }

function M.setup()
  require('lspconfig').eslint.setup(lsp_utils.merge_with_default_config {
    handlers = {
      -- Prevent eslint popup prompt when language server throws an error
      ['window/showMessageRequest'] = function(_, result)
        return result
      end,
    },
    settings = { packageManager = 'yarn' },
  })
end

return M
