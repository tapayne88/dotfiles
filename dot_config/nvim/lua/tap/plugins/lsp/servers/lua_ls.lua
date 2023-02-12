local lsp_utils = require 'tap.utils.lsp'

local M = {}

M.ensure_installed = { 'lua_ls' }

function M.setup()
  require('neodev').setup {}
  require('lspconfig').lua_ls.setup(lsp_utils.merge_with_default_config())
end

return M
