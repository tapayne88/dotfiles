-- native neovim LSP support
return {
  {
    'neovim/nvim-lspconfig', -- LSP server config
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'b0o/schemastore.nvim', -- jsonls schemas
      'folke/neodev.nvim', -- lua-dev setup
      'tapayne88/lsp-format.nvim',
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
      'tapayne88/lsp-format.nvim',
      'j-hui/fidget.nvim',
      'rmagatti/goto-preview',
      'williamboman/mason.nvim',
    },
    config = function()
      require('plenary.async').run(function()
        local null_ls = require 'null-ls'
        local path = require 'mason-core.path'
        local lsp_utils = require 'tap.utils.lsp'

        local asdf_nodejs_global_version =
          require('tap.utils.async').get_asdf_global_version 'nodejs'

        lsp_utils.ensure_installed {
          'hadolint',
          'markdownlint',
          'prettierd',
          'stylua',
        }

        vim.schedule(function()
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
                env = {
                  ASDF_NODEJS_VERSION = asdf_nodejs_global_version,
                },
                -- cwd = function()
                --   return vim.fn.expand '$HOME'
                -- end,
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
        end)
      end)
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
    -- My own fork lukas-reineke/lsp-format.nvim
    -- Has a number of changes like range formatting
    'tapayne88/lsp-format.nvim',
    lazy = true,
    config = function()
      require('lsp-format').setup {
        exclude = {
          'lua_ls', -- use stylua with null-ls for lua
          'tsserver',
        },
      }

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

      local format = function(options)
        -- Don't do disabled checking, here we're forcing formatting
        ---@diagnostic disable-next-line: undefined-field
        if vim.b.format_saving then
          return
        end

        local clients = vim.tbl_values(vim.lsp.get_active_clients())
        require('lsp-format').trigger_format(clients, options or {})
      end

      local format_in_range = function(options)
        -- Don't do disabled checking, here we're forcing formatting
        ---@diagnostic disable-next-line: undefined-field
        if vim.b.format_saving then
          return
        end

        options = options or {}
        options.in_range = true

        local clients = vim.tbl_filter(function(client)
          return client.supports_method 'textDocument/rangeFormatting'
        end, vim.lsp.get_active_clients())

        require('lsp-format').trigger_format(clients, options)
      end

      require('tap.utils.lsp').on_attach(function(c, bufnr)
        require('lsp-format').on_attach(c)

        -- Commands
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', format, {
          nargs = '*',
          bar = true,
          force = true,
          desc = '[LSP] Run formatter',
        })
        vim.api.nvim_buf_create_user_command(
          bufnr,
          'FormatInRange',
          format_in_range,
          {
            range = true,
            nargs = '*',
            bar = true,
            force = true,
            desc = '[LSP] Run formatter for range',
          }
        )

        -- Keymaps
        require('tap.utils').keymap('n', '<leader>tf', toggle_format, {
          buffer = bufnr,
          desc = '[LSP] Toggle formatting on save',
        })
        require('tap.utils').keymap(
          'n',
          '<space>f',
          format,
          { buffer = bufnr, desc = '[LSP] Run formatter' }
        )
        require('tap.utils').keymap(
          'v',
          '<space>f',
          format_in_range,
          { buffer = bufnr, desc = '[LSP] Run formatter for range' }
        )
      end)
    end,
  },

  -- virtual text in bottom right to show server activity
  {
    'j-hui/fidget.nvim',
    lazy = true,
    opts = function()
      return {
        text = {
          spinner = 'dots',
          done = '󰄴',
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

  -- panel to view the logs from your LSP servers.
  {
    'mhanberg/output-panel.nvim',
    event = 'VeryLazy',
    -- opts = {},
    config = function()
      require('output_panel').setup()
    end,
  },
}
