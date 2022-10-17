local lsp_utils = require 'tap.utils.lsp'

local module = {}

function module.setup()
  require('neodev').setup {}
  require('lspconfig').sumneko_lua.setup(lsp_utils.merge_with_default_config())
end

return module
