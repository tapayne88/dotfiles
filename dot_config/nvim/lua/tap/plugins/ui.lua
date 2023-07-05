return {
  -- better vim.notify()
  {
    'rcarriga/nvim-notify',
    config = function()
      local nnoremap = require('tap.utils').nnoremap

      local debug_enabled = require('tap.utils').debug_enabled()
        or require('tap.utils.lsp').lsp_debug_enabled()

      vim.notify = require 'notify'

      require('notify').setup {
        icons = {
          ERROR = '󰅚',
          WARN = '󰀪',
          INFO = '',
          DEBUG = '',
          TRACE = '󱡴',
        },
        level = debug_enabled and vim.log.levels.DEBUG or vim.log.levels.INFO,
      }

      nnoremap(
        '<leader>nc',
        ":lua require('notify').dismiss()<CR>",
        { desc = 'Clear notifications' }
      )
    end,
  },

  {
    'stevearc/dressing.nvim',
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require('lazy').load { plugins = { 'dressing.nvim' } }
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require('lazy').load { plugins = { 'dressing.nvim' } }
        return vim.ui.input(...)
      end
    end,
    config = function()
      require('dressing').setup {
        input = {
          -- Default prompt string
          default_prompt = '❯ ',
          -- When true, <Esc> will close the modal
          insert_only = true,
          -- These are passed to nvim_open_win
          anchor = 'SW',
          relative = 'cursor',
          border = 'rounded',
          -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
          prefer_width = 40,
          max_width = nil,
          min_width = 20,
          win_options = {
            -- Window transparency (0-100)
            winblend = 0,
            -- Change default highlight groups (see :help winhl)
            winhighlight = '',
          },
          -- see :help dressing_get_config
          get_config = nil,
        },
        select = {
          -- Priority list of preferred vim.select implementations
          backend = { 'telescope' },
          -- Options for telescope selector
          telescope = require('telescope.themes').get_dropdown(),
          -- Used to override format_item. See :help dressing-format
          format_item_override = {},
          -- see :help dressing_get_config
          get_config = nil,
        },
      }
    end,
  },

  -- active indent guide and indent text objects
  {
    'echasnovski/mini.indentscope',
    event = 'BufReadPre',
    opts = {
      symbol = '│',
      options = { try_as_border = true },
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = vim.tbl_flatten {
          'alpha',
          'help',
          'lazy',
          'mason',
          'neo-tree',
          'oil_preview',
          'terminal',
          'Trouble',
          require('tap.utils').dap_filetypes,
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
      require('mini.indentscope').setup(opts)
    end,
  },

  {
    'petertriho/nvim-scrollbar',
    opts = {
      excluded_filetypes = {
        '',
        'lazy',
        'mason',
        'oil_preview',
        'TelescopePrompt',
      },
    },
  },

  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    opts = function()
      local dashboard = require 'alpha.themes.dashboard'
      dashboard.section.header.val = {
        '',
        '',
        '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
        '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
        '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
        '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
        '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
        '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
        '',
      }

      dashboard.section.buttons.val = {
        dashboard.button(
          'p',
          ' ' .. ' Restore last session',
          ':lua require("persistence").load()<CR>'
        ),
        dashboard.button(
          'r',
          '󰄉 ' .. ' Recent files',
          ':lua require("telescope.builtin").oldfiles{ cwd_only = true }<CR>'
        ),
        dashboard.button(
          'n',
          ' ' .. ' New file',
          ':ene <BAR> startinsert <CR>'
        ),
        dashboard.button('f', ' ' .. ' Find file', ':norm ,ff <CR>'),
        dashboard.button('g', '󰊢 ' .. ' Git file', ':norm ,gf <CR>'),
        dashboard.button('s', ' ' .. ' Find text', ':norm ,fg <CR>'),
        dashboard.button('l', '󰒲 ' .. ' Lazy', ':Lazy<CR>'),
        dashboard.button('m', '◍ ' .. ' Mason', ':Mason<CR>'),
        dashboard.button('q', ' ' .. ' Quit', ':qa<CR>'),
      }

      return dashboard
    end,
    config = function(_, dashboard)
      -- vim.b.miniindentscope_disable = true

      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == 'lazy' then
        vim.cmd.close()
        vim.api.nvim_create_autocmd('User', {
          pattern = 'AlphaReady',
          callback = function()
            require('lazy').show()
          end,
        })
      end

      require('alpha').setup(dashboard.opts)

      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyVimStarted',
        callback = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = '⚡ Neovim loaded '
            .. stats.count
            .. ' plugins in '
            .. ms
            .. 'ms'
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
}
