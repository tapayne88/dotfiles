return {
  -- better vim.notify()
  {
    'rcarriga/nvim-notify',
    config = function()
      local lsp_symbols = require('tap.utils.lsp').symbols
      local nnoremap = require('tap.utils').nnoremap
      local lsp_debug_enabled = require('tap.utils.lsp').lsp_debug_enabled

      vim.notify = require 'notify'

      require('notify').setup {
        icons = {
          ERROR = lsp_symbols 'error',
          WARN = lsp_symbols 'warning',
          INFO = lsp_symbols 'info',
          DEBUG = '',
          TRACE = '✎',
        },
        level = lsp_debug_enabled() and vim.log.levels.DEBUG
          or vim.log.levels.INFO,
      }

      nnoremap(
        '<leader>nc',
        ":lua require('notify').dismiss()<CR>",
        { description = 'Clear notifications' }
      )

      require('tap.utils').apply_user_highlights(
        'NvimNotify',
        function(highlight, color)
          -- stylua: ignore start
          highlight("NotifyERRORBorder", {guifg = color({dark = "nord11_gui", light = "red"})})
          highlight("NotifyWARNBorder", {guifg = color({dark = "nord13_gui", light = "yellow"})})
          highlight("NotifyINFOBorder", {guifg = color({dark = "nord10_gui", light = "blue2"})})
          highlight("NotifyDEBUGBorder", {guifg = color({dark = "nord7_gui", light = "cyan"})})
          highlight("NotifyTRACEBorder", {guifg = color({dark="nord15_gui", light="purple"})})

          highlight("NotifyERRORIcon", {guifg = color({dark = "nord11_gui", light = "red"})})
          highlight("NotifyWARNIcon", {guifg = color({dark = "nord13_gui", light = "yellow"})})
          highlight("NotifyINFOIcon", {guifg = color({dark = "nord10_gui", light = "blue2"})})
          highlight("NotifyDEBUGIcon", {guifg = color({dark = "nord7_gui", light = "cyan"})})
          highlight("NotifyTRACEIcon", {guifg = color({dark="nord15_gui", light="purple"})})

          highlight("NotifyERRORTitle", {guifg = color({dark = "nord11_gui", light = "red"})})
          highlight("NotifyWARNTitle", {guifg = color({dark = "nord13_gui", light = "yellow"})})
          highlight("NotifyINFOTitle", {guifg = color({dark = "nord10_gui", light = "blue2"})})
          highlight("NotifyDEBUGTitle", {guifg = color({dark = "nord7_gui", light = "cyan"})})
          highlight("NotifyTRACETitle", {guifg = color({dark="nord15_gui", light="purple"})})
          -- stylua: ignore end

          highlight('NotifyERRORBody', { link = 'Normal' })
          highlight('NotifyWARNBody', { link = 'Normal' })
          highlight('NotifyINFOBody', { link = 'Normal' })
          highlight('NotifyDEBUGBody', { link = 'Normal' })
          highlight('NotifyTRACEBody', { link = 'Normal' })
        end
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
        pattern = {
          'help',
          'alpha',
          'neo-tree',
          'Trouble',
          'lazy',
          'mason',
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
    init = function()
      local lsp_colors = require('tap.utils.lsp').colors

      require('tap.utils').apply_user_highlights(
        'NvimScrollbar',
        function(_, color)
          require('scrollbar').setup {
            handle = {
              color = color { dark = 'nord1_gui', light = 'bg_highlight' },
            },
            marks = {
              Search = { color = color { dark = 'nord0_gui', light = 'bg' } },
              Error = { color = lsp_colors 'error' },
              Warn = { color = lsp_colors 'warning' },
              Info = { color = lsp_colors 'info' },
              Hint = { color = lsp_colors 'hint' },
              Misc = { color = color { dark = 'nord15_gui', light = 'purple' } },
            },
          }
        end
      )
    end,
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
          'r',
          ' ' .. ' Recent files',
          ':Telescope oldfiles <CR>'
        ),
        dashboard.button(
          'n',
          ' ' .. ' New file',
          ':ene <BAR> startinsert <CR>'
        ),
        dashboard.button('f', ' ' .. ' Find file', ':norm ,ff <CR>'),
        dashboard.button('g', ' ' .. ' Git file', ':norm ,gf <CR>'),
        dashboard.button('s', ' ' .. ' Find text', ':norm ,fg <CR>'),
        dashboard.button('l', '鈴' .. ' Lazy', ':Lazy<CR>'),
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
