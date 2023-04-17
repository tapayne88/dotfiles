-- treesitter colorschemes
return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    opts = function()
      local telescopeBorderless = function(flavor)
        local cp = require('catppuccin.palettes').get_palette(flavor)

        return {
          TelescopeMatching = { fg = cp.peach },

          TelescopeSelectionCaret = { fg = cp.flamingo, bg = cp.surface1 },
          TelescopeSelection = { fg = cp.text, bg = cp.surface1 },
          TelescopeMultiSelection = { fg = cp.text, bg = cp.surface2 },

          TelescopeTitle = { fg = cp.crust, bg = cp.green },
          TelescopePromptTitle = { fg = cp.crust, bg = cp.mauve },
          TelescopePreviewTitle = { fg = cp.crust, bg = cp.red },

          TelescopePromptNormal = { fg = cp.flamingo, bg = cp.surface0 },
          TelescopeResultsNormal = { bg = cp.mantle },

          TelescopePreviewBorder = { fg = cp.mantle, bg = cp.mantle },
          TelescopePromptBorder = { fg = cp.surface0, bg = cp.surface0 },
          TelescopeResultsBorder = { fg = cp.mantle, bg = cp.mantle },
        }
      end

      return {
        highlight_overrides = {
          latte = telescopeBorderless 'latte',
          frappe = telescopeBorderless 'frappe',
          macchiato = telescopeBorderless 'macchiato',
          mocha = telescopeBorderless 'mocha',
        },
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
              errors = { 'undercurl' },
              hints = { 'undercurl' },
              warnings = { 'undercurl' },
              information = { 'undercurl' },
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
      }
    end,
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
    end,
  },
}
