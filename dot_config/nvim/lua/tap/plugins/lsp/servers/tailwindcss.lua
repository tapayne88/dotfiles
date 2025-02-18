local lsp_utils = require 'tap.utils.lsp'

local M = {}

M.ensure_installed = { 'tailwindcss' }

function M.setup()
  require('lspconfig').tailwindcss.setup(lsp_utils.merge_with_default_config())
end

return M
