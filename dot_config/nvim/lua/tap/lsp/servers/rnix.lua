local lsp_utils = require "tap.lsp.utils"

local module = {}

function module.setup()
    require'lspconfig'.rnix.setup {lsp_utils.merge_with_default_config()}
end

return module
