local M = {}

M.ensure_installed = { 'lua_ls' }

function M.setup()
  vim.lsp.config('lua_ls', {
    settings = {
      Lua = {
        -- Prevent annoying 'Do you need to configure your work environment as `X`?' prompts
        -- According to https://github.com/LuaLS/lua-language-server/issues/679
        -- neovim can't persist these settings so just gets annoying
        ['runtime.version'] = 'LuaJIT',
        ['workspace.checkThirdParty'] = false,
        ['hint.enable'] = true,
      },
    },
  })

  vim.lsp.enable 'lua_ls'
end

return M
