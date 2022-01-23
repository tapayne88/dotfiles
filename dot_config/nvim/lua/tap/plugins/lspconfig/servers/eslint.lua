local lsp_utils = require "tap.lsp.utils"

local module = {}

function module.setup(lsp_server)
    lsp_server:setup(lsp_utils.merge_with_default_config({
        handlers = {
            -- Prevent eslint popup prompt when language server throws an error
            ['window/showMessageRequest'] = function(_, result)
                return result
            end
        },
        settings = {packageManager = 'yarn'}
    }))
end

return module
