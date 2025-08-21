local M = {}

M.ensure_installed = { 'tailwindcss' }

function M.setup()
  vim.lsp.enable 'tailwindcss'
end

return M
