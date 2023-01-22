-- treesitter colorschemes
return {
  'shaunsingh/nord.nvim',
  lazy = false,
  dependencies = {
    'folke/tokyonight.nvim', -- light theme
    'nvim-lua/plenary.nvim',
    'rktjmp/fwatch.nvim', -- Utility for watching files
  },
  config = function()
    local theme = require 'tap.utils.theme'
    local highlight = require('tap.utils').highlight
    local color = require('tap.utils').color
    local apply_user_highlights = require('tap.utils').apply_user_highlights

    theme.set_colorscheme(theme.get_term_theme, { announce = false })
    theme.setup_theme_watch()

    apply_user_highlights('Theme', function()
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

      -- Treesitter overrides
      highlight('TSInclude', { gui = 'italic', cterm = 'italic' })
      highlight('TSOperator', { gui = 'italic', cterm = 'italic' })
      highlight('TSKeyword', { gui = 'italic', cterm = 'italic' })
    end)
  end,
}
