local lsp_utils = require "tap.lsp.utils"

local module = {}

function module.setup(lsp_server)
    local luadev = require("lua-dev").setup {}

    lsp_server:setup(lsp_utils.merge_with_default_config(luadev))
end

return module
