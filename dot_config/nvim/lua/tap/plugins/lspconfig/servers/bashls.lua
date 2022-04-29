local lsp_utils = require 'tap.utils.lsp'

local module = {}

function module.setup()
  require('lspconfig').bashls.setup(lsp_utils.merge_with_default_config {
    filetypes = { 'sh', 'sh.chezmoitmpl' },
  })
end

return module
