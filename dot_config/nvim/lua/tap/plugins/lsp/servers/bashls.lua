local lsp_utils = require 'tap.utils.lsp'

local M = {}

M.ensure_installed = { 'bashls' }

function M.setup()
  require('lspconfig').bashls.setup(lsp_utils.merge_with_default_config())
end

return M
