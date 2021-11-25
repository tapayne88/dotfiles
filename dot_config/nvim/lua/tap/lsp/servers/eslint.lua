local lsp_utils = require "tap.lsp.utils"

local module = {}

function module.setup(lsp_server)
    lsp_server:setup(lsp_utils.get_default_config({
        settings = {packageManager = 'yarn'}
    }))
end

return module
