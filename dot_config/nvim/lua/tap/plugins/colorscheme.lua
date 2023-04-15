-- treesitter colorschemes
return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    opts = {
      integrations = {
        cmp = true,
        dap = {
          enabled = true,
          enable_ui = true,
        },
        gitsigns = true,
        illuminate = true,
        lsp_trouble = true,
        mason = true,
        neotree = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
          },
          underlines = {
            errors = { 'underline' },
            hints = { 'underline' },
            warnings = { 'underline' },
            information = { 'underline' },
          },
        },
        navic = {
          enabled = true,
          custom_bg = '#292c3c',
        },
        notify = true,
        telescope = true,
        treesitter = true,
        which_key = true,
      },
    },
  },

  {
    'shaunsingh/nord.nvim',
    lazy = false,
    dependencies = {
      'folke/tokyonight.nvim', -- light theme
      'nvim-lua/plenary.nvim',
      'rktjmp/fwatch.nvim', -- Utility for watching files
    },
    config = function()
      local theme = require 'tap.utils.theme'

      theme.set_colorscheme(theme.get_term_theme, { announce = false })
      theme.setup_theme_watch()

      require('tap.utils').apply_user_highlights(
        'Theme',
        function(highlight, color)
          highlight('Search', {
            guibg = color { dark = 'nord9_gui', light = 'blue2' },
            guifg = color { dark = 'nord0_gui', light = 'bg' },
            gui = 'NONE',
          })
          highlight('IncSearch', {
            guibg = color { dark = 'nord9_gui', light = 'blue2' },
            guifg = color { dark = 'nord0_gui', light = 'bg' },
            gui = 'NONE',
          })
          highlight('FloatBorder', {
            guifg = color { dark = 'nord9_gui', light = 'blue0' },
            guibg = color { dark = 'nord0_gui', light = 'none' },
          })
        end
      )
    end,
  },
}
