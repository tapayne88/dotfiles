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

    theme.set_colorscheme(theme.get_term_theme, { announce = false })
    theme.setup_theme_watch()
  end,
}
