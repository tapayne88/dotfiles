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
      'j-hui/fidget.nvim',
      'rmagatti/goto-preview',
      'williamboman/mason.nvim',
      'gbprod/none-ls-shellcheck.nvim',
    },
    config = function()
      local null_ls = require 'null-ls'
      local path = require 'mason-core.path'
      local lsp_utils = require 'tap.utils.lsp'

      lsp_utils.ensure_installed {
        'hadolint',
        'markdownlint',
        'prettierd',
        'sqlfluff',
        'stylua',
      }

      require('null-ls').register(require 'none-ls-shellcheck.diagnostics')
      require('null-ls').register(require 'none-ls-shellcheck.code_actions')

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

          -----------
          -- Hover --
          -----------
          null_ls.builtins.hover.dictionary,
        },
      })
    end,
  },

  -- async formatting
  {
    'stevearc/conform.nvim',
    dependencies = {
      'williamboman/mason.nvim',
    },
    init = function()
      local lsp_utils = require 'tap.utils.lsp'

      lsp_utils.ensure_installed {
        'prettierd',
        'sqlfluff',
        'stylua',
      }

      vim.api.nvim_create_user_command('FormatDisable', function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = '[Format] Disable autoformat-on-save',
        bang = true,
      })
      vim.api.nvim_create_user_command('FormatEnable', function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = '[Format] Re-enable autoformat-on-save',
      })

      local function toggle_format()
        local disabled = vim.b.disable_autoformat

        if disabled then
          vim.b.disable_autoformat = false
          vim.notify('enabled formatting for buffer', vim.log.levels.INFO, { title = 'Formatter' })
        else
          vim.b.disable_autoformat = true
          vim.notify('disabled formatting for buffer', vim.log.levels.WARN, { title = 'Formatter' })
        end
      end

      vim.keymap.set('n', '<leader>tf', toggle_format, {
        desc = '[Format] Toggle formatting on save',
      })
      vim.keymap.set({ 'n', 'v' }, '<space>f', require('conform').format, { desc = '[Format] Run formatter' })
    end,

    config = function()
      require('plenary.async').run(function()
        local js_ts_formatters = {
          'prettierd',
          'prettier',
          stop_after_first = true,
        }

        local asdf_nodejs_global_version = require('tap.utils.async').get_asdf_global_version 'nodejs'

        vim.schedule(function()
          require('conform').setup {
            formatters = {
              sqlfluff = {
                args = { 'format', '--dialect', 'mysql', '-' },
                cwd = require('conform.util').root_file { '.editorconfig', 'package.json' },
              },
              prettierd = {
                env = {
                  ASDF_NODEJS_VERSION = asdf_nodejs_global_version,
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

            format_after_save = function(bufnr)
              if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
              end
              return {
                async = true,
                lsp_format = 'fallback',
              }
            end,
          }
        end)
      end, require('tap.utils').noop)
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
