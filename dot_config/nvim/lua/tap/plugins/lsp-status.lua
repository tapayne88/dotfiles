local lsp_status = require('lsp-status')
local utils = require("tap.utils")

local module = {}

module.init = function()
  lsp_status.register_progress()
  lsp_status.config({
    current_function = false,
    status_symbol = "",
    indicator_errors = utils.lsp_symbols["error"],
    indicator_warnings = utils.lsp_symbols["warning"],
    indicator_info = utils.lsp_symbols["info"],
    indicator_hint = utils.lsp_symbols["hint"],
    indicator_ok = utils.lsp_symbols["ok"]
  })
end

module.capabilities = lsp_status.capabilities
module.on_attach = lsp_status.on_attach

return module
