-- treesitter colorschemes
return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    opts = {
      integrations = {
        navic = {
          enabled = true,
          custom_bg = '#292c3c',
        },
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
