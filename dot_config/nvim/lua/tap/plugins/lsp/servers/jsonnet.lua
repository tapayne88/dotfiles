local M = {}

M.ensure_installed = { 'jsonnet_ls' }

function M.setup()
  vim.lsp.enable 'jsonnet_ls'
end

return M
