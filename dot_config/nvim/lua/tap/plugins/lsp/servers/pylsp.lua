local M = {}

M.ensure_installed = { 'pylsp' }

function M.setup()
  vim.lsp.config('pylsp', {
    settings = {
      pylsp = {
        plugins = {
          pycodestyle = { enabled = false },
          -- pyflakes = { enabled = false },
          -- mccabe = { enabled = false },
        },
      },
    },
  })
  vim.lsp.enable 'pylsp'
end

return M
