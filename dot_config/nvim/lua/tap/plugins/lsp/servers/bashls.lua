local M = {}

M.ensure_installed = { 'bashls' }

function M.setup()
  vim.lsp.enable 'bashls'
end

return M
