local lsp_utils = require 'tap.utils.lsp'

M.ensure_installed = { 'vtsls' }

function M.setup()
  require('lspconfig').vtsls.setup(lsp_utils.merge_with_default_config {})
end

return M
