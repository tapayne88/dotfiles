local M = {}

M.ensure_installed = { 'eslint' }

function M.setup()
  vim.lsp.config('eslint', {
    handlers = {
      -- Prevent eslint popup prompt when language server throws an error
      ['window/showMessageRequest'] = function(_, result)
        return result
      end,
    },
    settings = { packageManager = 'yarn' },
  })

  vim.lsp.enable 'eslint'
end

return M
