local lsp_utils = require 'tap.utils.lsp'

local module = {}

function module.setup()
  local luadev = require('lua-dev').setup {}

  require('lspconfig').sumneko_lua.setup(
    lsp_utils.merge_with_default_config(luadev)
  )
end

return module
