local M = {}

M.ensure_installed = { 'ruff' }

function M.setup()
  vim.lsp.config('ruff', {
    -- Disable hover in favor of other LSPs (like pyright)
    on_attach = function(client)
      client.server_capabilities.hoverProvider = false
    end,
  })

  vim.lsp.enable 'ruff'
end

return M
