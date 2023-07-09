local lsp_utils = require 'tap.utils.lsp'

local M = {}

function M.setup()
  require('typescript-tools').setup(lsp_utils.merge_with_default_config {})
end

return M
