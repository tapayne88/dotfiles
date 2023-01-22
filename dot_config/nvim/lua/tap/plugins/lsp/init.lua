-- native neovim LSP support
return {
  {
    'neovim/nvim-lspconfig', -- LSP server config
    dependencies = {
      'b0o/schemastore.nvim', -- jsonls schemas
      'folke/neodev.nvim', -- lua-dev setup
      'lukas-reineke/lsp-format.nvim', -- async formatting
      'jose-elias-alvarez/null-ls.nvim',
      'rcarriga/nvim-notify',
      'rmagatti/goto-preview',
      'williamboman/mason.nvim',
    },
    config = function()
      local utils = require 'tap.utils'
      local lsp_utils = require 'tap.utils.lsp'

      if lsp_utils.lsp_debug_enabled() then
        vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)
        vim.notify(
          'LSP debug log: ' .. vim.lsp.get_log_path(),
          vim.log.levels.DEBUG,
          { title = 'lspconfig' }
        )
      end

      local servers = {
        -- language servers installed with mason.nvim / mason-lspconfig.nvim
        ['mason-lspconfig'] = {
          'bashls',
          'eslint',
          'jsonls',
          'sumneko_lua',
          'tsserver',
        },
        -- custom installers that use mason.nvim
        ['mason'] = {
          'null-ls',
        },
        -- globally installed servers likely through nix
        ['global-servers'] = { 'rnix' },
      }

      local get_server_list = function(nested_servers)
        return vim.tbl_flatten(vim.tbl_values(nested_servers))
      end

      local function require_server(server_identifier)
        local server_name =
          require('mason-core.package').Parse(server_identifier)
        return require('tap.plugins.lsp.servers.' .. server_name)
      end

      utils.run {
        -------------
        -- Install --
        -------------
        function()
          for _, server_name in pairs(servers['mason']) do
            require_server(server_name).install()
          end
        end,

        -----------
        -- Setup --
        -----------
        function()
          -- Ensure desired servers are installed
          require('mason-lspconfig').setup {
            ensure_installed = servers['mason-lspconfig'],
          }
        end,

        -------------
        -- Require --
        -------------
        function()
          -- Setup servers
          for _, server_identifier in pairs(get_server_list(servers)) do
            require_server(server_identifier).setup()
          end
        end,
      }
    end,
  },

  {
    'rmagatti/goto-preview',
    config = function()
      require('goto-preview').setup {
        border = {
          '↖',
          '─',
          '╮',
          '│',
          '╯',
          '─',
          '╰',
          '│',
        },
      }

      require('tap.utils.lsp').on_attach(function(_, bufnr)
        require('tap.utils').nnoremap(
          'gd',
          '<cmd>lua require("goto-preview").goto_preview_definition()<CR>',
          { buffer = bufnr, description = '[LSP] Go to definition preview' }
        )
      end)
    end,
  },

  {
    'lukas-reineke/lsp-format.nvim', -- async formatting
    config = function()
      require('lsp-format').setup {}

      local function toggle_format()
        local filetype = vim.bo.filetype
        local disabled = require('lsp-format').disabled_filetypes[filetype]

        if disabled then
          require('lsp-format').enable { args = filetype }
          vim.notify(
            'enabled formatting for ' .. filetype,
            vim.log.levels.INFO,
            { title = 'LSP Utils' }
          )
        else
          require('lsp-format').disable { args = filetype }
          vim.notify(
            'disabled formatting for ' .. filetype,
            vim.log.levels.WARN,
            { title = 'LSP Utils' }
          )
        end
      end

      local disabled_formatters = {
        'sumneko_lua', -- use stylua with null-ls for lua
        'tsserver',
      }

      require('tap.utils.lsp').on_attach(function(client, bufnr)
        if not vim.tbl_contains(disabled_formatters, client.name) then
          require('lsp-format').on_attach(client)
        end

        -- Formatting
        require('tap.utils').nnoremap('<leader>tf', toggle_format, {
          buffer = bufnr,
          description = '[LSP] Toggle formatting on save',
        })
        require('tap.utils').nnoremap(
          '<space>f',
          '<cmd>Format<CR>',
          { buffer = bufnr, description = '[LSP] Run formatting' }
        )
      end)
    end,
  },
}
