local lsp_utils = require "tap.lsp.utils"

local module = {}

function module.setup()
    require'lspconfig'.rnix.setup {on_attach = lsp_utils.on_attach}
end

return module
