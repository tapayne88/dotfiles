local M = {}

M.ensure_installed = { 'terraformls' }

function M.setup()
  vim.lsp.enable 'terraformls'
end

return M
