local lsp_utils = require 'tap.utils.lsp'

local M = {}

M.ensure_installed = { 'jsonnet_ls' }

function M.setup()
  require('lspconfig').jsonnet_ls.setup(lsp_utils.merge_with_default_config())
end

return M
