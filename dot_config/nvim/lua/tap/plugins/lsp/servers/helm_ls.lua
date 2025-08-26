local M = {}

M.ensure_installed = { 'helm_ls' }

function M.setup()
  vim.lsp.enable 'helm_ls'
end

return M
