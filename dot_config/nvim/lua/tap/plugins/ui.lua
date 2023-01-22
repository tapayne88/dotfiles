-- customise vim.ui appearance
return {
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
          'dashboard',
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
      local color = require('tap.utils').color
      local lsp_colors = require('tap.utils.lsp').colors
      local apply_user_highlights = require('tap.utils').apply_user_highlights

      apply_user_highlights('NvimScrollbar', function()
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
      end)
    end,
  },

  {
    'glepnir/dashboard-nvim',
    config = function()
      local db = require 'dashboard'

      db.custom_header = {
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
      db.custom_center = {
        {
          icon = '  ',
          desc = 'Recent files                                      ',
          action = 'Telescope oldfiles',
        },
        {
          icon = '  ',
          desc = 'Git file                                <leader>gf',
          action = 'norm ,gf',
        },
        {
          icon = '  ',
          desc = 'Find file                               <leader>ff',
          action = 'norm ,ff',
        },
        {
          icon = '  ',
          desc = 'New file                                          ',
          action = 'enew',
        },
        {
          icon = '  ',
          desc = 'File browser                            <leader>fb',
          action = 'norm ,fb',
        },
        {
          icon = '  ',
          desc = 'Find word                               <leader>fg',
          action = 'norm ,fg',
        },
        {
          icon = '  ',
          desc = 'Jump to bookmarks                                 ',
          action = 'Telescope marks',
        },
      }
    end,
  },
}
