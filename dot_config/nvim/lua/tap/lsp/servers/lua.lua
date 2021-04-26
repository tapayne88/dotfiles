local lsp_utils = require('tap.lsp.utils')

local module = {}

function module.patch_install()
end

function module.setup()
  local settings = {
    Lua = {
      runtime = {
        -- LuaJIT in the case of Neovim
        version = 'LuaJIT',
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
      },
    }
  }

  lsp_utils.lspconfig_server_setup("lua", {
    handlers = {
      ["textDocument/publishDiagnostics"] = lsp_utils.on_publish_diagnostics("[lua] ")
    },
    on_attach = lsp_utils.on_attach,
    settings = settings
  })
end

return module
