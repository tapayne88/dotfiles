local saga = require('lspsaga')
local utils = require("tap.utils")

local module = {}

module.init = function()
  saga.init_lsp_saga({
    error_sign = utils.lsp_symbols["error"],
    warn_sign = utils.lsp_symbols["warning"],
    infor_sign = utils.lsp_symbols["info"],
    hint_sign = utils.lsp_symbols["hint"],
    border_style = "round",
    code_action_prompt = {
      enable = false
    }
  })
end

module.on_attach = function()
  vim.api.nvim_command('autocmd CursorHold <buffer> lua require("lspsaga.diagnostic").show_cursor_diagnostics()')
end

return module
