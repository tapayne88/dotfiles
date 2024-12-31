return {
  -- better vim.notify()
  {
    'rcarriga/nvim-notify',
    config = function()
      local debug_enabled = require('tap.utils').debug_enabled() or require('tap.utils.lsp').lsp_debug_enabled()

      ---@diagnostic disable-next-line: duplicate-set-field
      vim.notify = function(msg, lvl, opts)
        local options = vim.tbl_extend('force', {
          on_open = function(win)
            local buf = vim.api.nvim_win_get_buf(win)
            vim.api.nvim_set_option_value('filetype', 'markdown', { buf = buf })
            require('render-markdown').enable()
          end,
        }, opts or {})

        return require 'notify'(msg, lvl, options)
      end

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

      vim.keymap.set('n', '<leader>nc', ":lua require('notify').dismiss()<CR>", { desc = 'Clear notifications' })
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
    opts = function()
      return {
        input = {
          -- Default prompt string
          default_prompt = '❯ ',
          -- When true, <Esc> will close the modal
          insert_only = true,
          -- These are passed to nvim_open_win
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
    event = 'BufReadPost',
    opts = {
      symbol = '│',
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = vim
          .iter({
            'help',
            'lazy',
            'mason',
            'neo-tree',
            'oil_preview',
            'snacks_dashboard',
            'terminal',
            'trouble',
            require('tap.utils').dap_filetypes,
          })
          :flatten()
          :totable(),
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

  {
    'petertriho/nvim-scrollbar',
    event = 'BufReadPost',
    opts = {
      hide_if_all_visible = true, -- Hides everything if all lines are visible
      excluded_filetypes = {
        -- Default config
        'cmp_docs',
        'cmp_menu',
        'noice',
        'prompt',
        'TelescopePrompt',

        'lazy',
        'mason',
        'oil_preview',
      },
    },
  },

  {
    'folke/snacks.nvim',
    priority = 1000,
    opts = {
      dashboard = {
        preset = {
          header = [[
          ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗          
          ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║          
          ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║          
          ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║          
          ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║          
          ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝          
   ]],
          -- stylua: ignore start
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = ' ', key = 'f', desc = 'Find File',       action = ':norm ,ff' },
            { icon = ' ', key = 'n', desc = 'New File',        action = ':ene | startinsert' },
            { icon = ' ', key = 'g', desc = 'Find Text',       action = ':norm ,/' },
            { icon = ' ', key = 'r', desc = 'Recent Files',    action = ':lua require("telescope.builtin").oldfiles{ cwd_only = true }' },
            { icon = ' ', key = 's', desc = 'Restore Session', action = ':lua require("persistence").load()' },
            { icon = '󰒲 ', key = 'l', desc = 'Lazy',            action = ':Lazy' },
            { icon = '◍ ', key = 'm', desc = 'Mason',           action = ':Mason' },
            { icon = ' ', key = 'q', desc = 'Quit',            action = ':qa' },
          },
          -- stylua: ignore end
        },
      },
      bigfile = {
        enabled = true,
        -- Enable or disable features when big file detected
        ---@param ctx {buf: number, ft:string}
        setup = function(ctx)
          vim.cmd [[NoMatchParen]]
          vim.cmd [[UfoDetach]]
          Snacks.util.wo(0, { foldmethod = 'manual', statuscolumn = '', conceallevel = 0 })
          vim.b.minianimate_disable = true
          vim.schedule(function()
            vim.bo[ctx.buf].syntax = ctx.ft
          end)
        end,
      },
    },
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    ft = { 'markdown', 'norg', 'rmd', 'org' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },

  {
    'OXY2DEV/helpview.nvim',
    lazy = false, -- Recommended
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
  },

  {
    'stevearc/quicker.nvim',
    event = 'FileType qf',
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {},
  },

  {
    'echasnovski/mini.animate',
    event = 'VeryLazy',
    opts = {
      cursor = { enable = false },
      scroll = { enable = true },
      resize = { enable = false },
      open = { enable = false },
      close = { enable = false },
    },
  },
}
