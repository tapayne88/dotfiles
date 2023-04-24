-- native neovim LSP support
return {
  {
    'neovim/nvim-lspconfig', -- LSP server config
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'b0o/schemastore.nvim', -- jsonls schemas
      'folke/neodev.nvim', -- lua-dev setup
      'lukas-reineke/lsp-format.nvim',
      'j-hui/fidget.nvim',
      'rcarriga/nvim-notify',
      'rmagatti/goto-preview',
      'williamboman/mason.nvim',
    },
    config = function()
      if require('tap.utils.lsp').lsp_debug_enabled() then
        vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)
        vim.notify(
          'LSP debug log: ' .. vim.lsp.get_log_path(),
          vim.log.levels.DEBUG,
          { title = 'lspconfig' }
        )
      end

      local servers = require 'tap.plugins.lsp.servers'

      local ensure_installed = vim.tbl_flatten(vim.tbl_map(function(server)
        return server.ensure_installed
      end, servers))

      require('mason-lspconfig').setup {
        ensure_installed = ensure_installed,
      }

      for _, server in pairs(servers) do
        server.setup()
      end
    end,
  },

  {
    'jose-elias-alvarez/null-ls.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'lukas-reineke/lsp-format.nvim',
      'j-hui/fidget.nvim',
      'rmagatti/goto-preview',
      'williamboman/mason.nvim',
    },
    config = function()
      local null_ls = require 'null-ls'
      local path = require 'mason-core.path'
      local lsp_utils = require 'tap.utils.lsp'

      lsp_utils.ensure_installed {
        'hadolint',
        'markdownlint',
        'prettierd',
        'stylua',
      }

      null_ls.setup(lsp_utils.merge_with_default_config {
        debug = lsp_utils.lsp_debug_enabled(),
        sources = {
          ------------------
          -- Code Actions --
          ------------------
          null_ls.builtins.code_actions.shellcheck,

          -----------------
          -- Diagnostics --
          -----------------
          null_ls.builtins.diagnostics.hadolint,
          null_ls.builtins.diagnostics.markdownlint.with {
            command = path.bin_prefix 'markdownlint',
            extra_args = {
              '--config',
              vim.fn.stdpath 'config' .. '/markdownlint.json',
            },
          },
          null_ls.builtins.diagnostics.shellcheck,

          ----------------
          -- Formatting --
          ----------------
          null_ls.builtins.formatting.prettierd.with {
            command = path.bin_prefix 'prettierd',
          },
          null_ls.builtins.formatting.stylua.with {
            command = path.bin_prefix 'stylua',
          },

          -----------
          -- Hover --
          -----------
          null_ls.builtins.hover.dictionary,
        },
      })
    end,
  },

  {
    'rmagatti/goto-preview',
    lazy = true,
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
          { buffer = bufnr, desc = '[LSP] Go to definition preview' }
        )
      end)
    end,
  },

  -- async formatting
  {
    'lukas-reineke/lsp-format.nvim',
    lazy = true,
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
        'lua_ls', -- use stylua with null-ls for lua
        'tsserver',
      }

      require('tap.utils.lsp').on_attach(function(client, bufnr)
        if not vim.tbl_contains(disabled_formatters, client.name) then
          require('lsp-format').on_attach(client)
        end

        -- Formatting
        require('tap.utils').nnoremap('<leader>tf', toggle_format, {
          buffer = bufnr,
          desc = '[LSP] Toggle formatting on save',
        })
        require('tap.utils').nnoremap(
          '<space>f',
          '<cmd>Format<CR>',
          { buffer = bufnr, desc = '[LSP] Run formatting' }
        )
      end)
    end,
  },

  {
    'j-hui/fidget.nvim',
    lazy = true,
    opts = function()
      return {
        text = {
          spinner = 'dots',
          done = require('tap.utils.lsp').symbol 'ok',
        },
        window = {
          blend = 0,
        },
      }
    end,
    init = function()
      require('tap.utils').apply_user_highlights(
        'FidgetNvim',
        function(highlight)
          highlight('FidgetTitle', { link = 'Title' })
          highlight('FidgetTask', { link = 'Comment' })
        end
      )
    end,
  },
}
