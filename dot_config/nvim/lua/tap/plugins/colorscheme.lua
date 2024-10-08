-- treesitter colorschemes
return {
  'catppuccin/nvim',
  name = 'catppuccin',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'rktjmp/fwatch.nvim', -- Utility for watching files
  },
  config = function()
    require('catppuccin').setup {
      integrations = {
        cmp = true,
        dap = true,
        dap_ui = true,
        gitsigns = true,
        illuminate = true,
        lsp_trouble = true,
        mason = true,
        neotree = true,
        neotest = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
          },
          underlines = {
            errors = { 'undercurl' },
            hints = { 'undercurl' },
            warnings = { 'undercurl' },
            information = { 'undercurl' },
          },
        },
        -- Enabled manually in ./lualine.lua
        -- navic = {
        --   enabled = true,
        -- },
        notify = true,
        telescope = true,
        treesitter = true,
        which_key = true,
      },
    }

    local theme = require 'tap.utils.theme'

    theme.set_colorscheme(theme.get_term_theme, { announce = false })
    theme.setup_theme_watch()
  end,
}
