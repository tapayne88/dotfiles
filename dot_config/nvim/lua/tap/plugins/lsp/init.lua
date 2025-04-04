-- native neovim LSP support
return {
  {
    'neovim/nvim-lspconfig', -- LSP server config
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      {
        'folke/lazydev.nvim',
        ft = 'lua', -- only load on lua files
        opts = {
          library = {
            vim.g.chezmoi_source_dir .. '/dot_config/nvim/lua',
            -- Load luvit types when the `vim.uv` word is found
            { path = 'luvit-meta/library', words = { 'vim%.uv' } },
          },
        },
      },
      { 'Bilal2453/luvit-meta', lazy = true }, -- optional `vim.uv` typings
      { -- optional completion source for require statements and module annotations
        'hrsh7th/nvim-cmp',
        opts = function(_, opts)
          opts.sources = opts.sources or {}
          table.insert(opts.sources, {
            name = 'lazydev',
            group_index = 0, -- set group index to 0 to skip loading LuaLS completions
          })
        end,
      },
      'b0o/schemastore.nvim', -- jsonls schemas
      'tapayne88/lsp-format.nvim',
      'j-hui/fidget.nvim',
      'rcarriga/nvim-notify',
      'rmagatti/goto-preview',
      'williamboman/mason.nvim',
      'saecki/live-rename.nvim',
    },
    config = function()
      if require('tap.utils.lsp').lsp_debug_enabled() then
        vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)
        vim.notify('LSP debug log: ' .. vim.lsp.get_log_path(), vim.log.levels.DEBUG, { title = 'lspconfig' })
      end

      local servers = require 'tap.plugins.lsp.servers'

      local ensure_installed = vim
        .iter(vim.tbl_map(function(server)
          return server.ensure_installed
        end, servers))
        :flatten()
        :totable()

      require('mason-lspconfig').setup {
        ensure_installed = ensure_installed,
        automatic_installation = true,
      }

      for _, server in pairs(servers) do
        server.setup()
      end
    end,
  },

  {
    'nvimtools/none-ls.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'tapayne88/lsp-format.nvim',
      'j-hui/fidget.nvim',
      'rmagatti/goto-preview',
      'williamboman/mason.nvim',
      'gbprod/none-ls-shellcheck.nvim',
    },
    config = function()
      require('plenary.async').run(function()
        local null_ls = require 'null-ls'
        local path = require 'mason-core.path'
        local lsp_utils = require 'tap.utils.lsp'

        local asdf_nodejs_global_version = require('tap.utils.async').get_asdf_global_version 'nodejs'

        lsp_utils.ensure_installed {
          'hadolint',
          'markdownlint',
          'prettierd',
          'sqlfluff',
          'stylua',
        }

        require('null-ls').register(require 'none-ls-shellcheck.diagnostics')
        require('null-ls').register(require 'none-ls-shellcheck.code_actions')

        vim.schedule(function()
          null_ls.setup(lsp_utils.merge_with_default_config {
            debug = lsp_utils.lsp_debug_enabled(),
            sources = {
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
              null_ls.builtins.diagnostics.sqlfluff.with {
                extra_args = { '--dialect', 'mysql' },
                filetypes = { 'mysql', 'sql' },
              },

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
              null_ls.builtins.formatting.sqlfluff.with {
                extra_args = { '--dialect', 'mysql' },
                filetypes = { 'mysql', 'sql' },
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
      end, require('tap.utils').noop)
    end,
  },

  -- async formatting
  {
    {
      'stevearc/conform.nvim',
      opts = function()
        local js_ts_formatters = {
          'prettierd',
          'prettier',
          stop_after_first = true,
        }

        require('tap.utils.lsp').on_attach(function(_, bufnr)
          require('tap.utils').keymap({ 'n', 'v' }, '<space>f', function()
            require('conform').format { bufnr = bufnr }
          end, { buffer = bufnr, desc = '[LSP] Run formatter' })
        end)

        -- local asdf_nodejs_global_version = require('tap.utils.async').get_asdf_global_version 'nodejs'
        return {
          formatters = {
            sqlfluff = {
              args = { 'format', '--dialect', 'mysql', '-' },
              cwd = require('conform.util').root_file { '.editorconfig', 'package.json' },
            },
            prettierd = {
              env = {
                CWD = vim.fn.stdpath 'data',
              },
            },
          },

          formatters_by_ft = {
            javascript = js_ts_formatters,
            javascriptreact = js_ts_formatters,
            lua = { 'stylua' },
            mysql = { 'sqlfluff' },
            sql = { 'sqlfluff' },
            typescript = js_ts_formatters,
            typescriptreact = js_ts_formatters,
          },

          format_after_save = {
            -- timeout_ms = 500,
            async = true,
            lsp_format = 'fallback',
          },
        }
      end,
    },
  },
  {
    -- My own fork lukas-reineke/lsp-format.nvim
    -- Has a number of changes like range formatting
    'tapayne88/lsp-format.nvim',
    lazy = true,
    config = function()
      require('lsp-format').setup {
        exclude = {
          'cucumber_language_server',
          'lua_ls', -- use stylua with null-ls for lua
          'ts_ls',
        },
      }

      local function toggle_format()
        local filetype = vim.bo.filetype
        local disabled = require('lsp-format').disabled_filetypes[filetype]

        if disabled then
          require('lsp-format').enable { args = filetype }
          vim.notify('enabled formatting for ' .. filetype, vim.log.levels.INFO, { title = 'LSP Utils' })
        else
          require('lsp-format').disable { args = filetype }
          vim.notify('disabled formatting for ' .. filetype, vim.log.levels.WARN, { title = 'LSP Utils' })
        end
      end

      local format = function(options)
        -- Don't do disabled checking, here we're forcing formatting
        ---@diagnostic disable-next-line: undefined-field
        if vim.b.format_saving then
          return
        end

        local clients = vim.tbl_values(vim.lsp.get_clients())
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
        end, vim.lsp.get_clients())

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
        vim.api.nvim_buf_create_user_command(bufnr, 'FormatInRange', format_in_range, {
          range = true,
          nargs = '*',
          bar = true,
          force = true,
          desc = '[LSP] Run formatter for range',
        })

        -- Keymaps
        require('tap.utils').keymap('n', '<leader>tf', toggle_format, {
          buffer = bufnr,
          desc = '[LSP] Toggle formatting on save',
        })
        require('tap.utils').keymap('n', '<space>f', format, { buffer = bufnr, desc = '[LSP] Run formatter' })
        require('tap.utils').keymap(
          'v',
          '<space>f',
          format_in_range,
          { buffer = bufnr, desc = '[LSP] Run formatter for range' }
        )
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

  -- virtual text in bottom right to show server activity
  {
    'j-hui/fidget.nvim',
    lazy = true,
    tag = 'legacy',
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
      require('tap.utils').apply_user_highlights('FidgetNvim', function(highlight)
        highlight('FidgetTitle', { link = 'Title' })
        highlight('FidgetTask', { link = 'Comment' })
      end)
    end,
  },

  -- panel to view the logs from your LSP servers.
  {
    'mhanberg/output-panel.nvim',
    event = 'VeryLazy',
    opts = true,
  },
}
