local lsp_utils = require 'tap.utils.lsp'

local M = {}

M.ensure_installed = { 'lua_ls' }

function M.setup()
  require('neodev').setup {}
  require('lspconfig').lua_ls.setup(lsp_utils.merge_with_default_config {
    settings = {
      Lua = {
        -- Prevent annoying 'Do you need to configure your work environment as `X`?' prompts
        -- According to https://github.com/LuaLS/lua-language-server/issues/679
        -- neovim can't persist these settings so just gets annoying
        ['runtime.version'] = 'LuaJIT',
        ['workspace.checkThirdParty'] = false,
      },
    },
  })
end

return M
