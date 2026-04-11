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
      lsp_styles = {
        underlines = {
          errors = { 'undercurl' },
          hints = { 'undercurl' },
          warnings = { 'undercurl' },
          information = { 'undercurl' },
          ok = { 'undercurl' },
        },
      },
      integrations = {
        cmp = true,
        dap = true,
        dap_ui = true,
        gitsigns = true,
        illuminate = true,
        lualine = {
          all = function(colors)
            -- Override default bg so it matches background
            local transparent_bg = colors.base

            ---@type CtpIntegrationLualineOverride
            return {
              normal = {
                c = { bg = transparent_bg },
              },
              inactive = {
                a = { bg = transparent_bg },
                b = { bg = transparent_bg },
                c = { bg = transparent_bg },
              },
            }
          end,
        },
        lsp_trouble = true,
        neotree = true,
        neotest = true,
        navic = {
          enabled = true,
        },
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
