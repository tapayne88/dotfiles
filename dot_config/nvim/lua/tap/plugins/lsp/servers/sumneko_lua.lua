local lsp_utils = require 'tap.utils.lsp'

local M = {}

M.ensure_installed = { 'sumneko_lua' }

function M.setup()
  require('neodev').setup {}
  require('lspconfig').sumneko_lua.setup(lsp_utils.merge_with_default_config())
end

return M
