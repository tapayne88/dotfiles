local lsp_utils = require 'tap.utils.lsp'

local M = {}

M.ensure_installed = { 'helm_ls' }

function M.setup()
  require('lspconfig').helm_ls.setup(lsp_utils.merge_with_default_config())
end

return M
