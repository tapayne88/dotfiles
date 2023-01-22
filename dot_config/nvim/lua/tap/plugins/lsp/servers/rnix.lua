local lsp_utils = require 'tap.utils.lsp'

local M = {}

-- globally installed servers using nix
M.ensure_installed = {}

function M.setup()
  require('lspconfig').rnix.setup(lsp_utils.merge_with_default_config())
end

return M
