return {
  'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  event = 'BufReadPre',
  config = function()
    local utils = require 'tap.utils'
    local lsp_colors = require('tap.utils.lsp').colors
    local lsp_symbols = require('tap.utils.lsp').symbols
    local apply_user_highlights = require('tap.utils').apply_user_highlights
    local nnoremap = require('tap.utils').nnoremap

    require('lsp_lines').setup()

    -- TODO: Create config module where this can live - duplicated in utils/lsp.lua
    local border_window_style = 'rounded'

    vim.diagnostic.config {
      underline = true,
      update_in_insert = false,
      virtual_text = false,
      signs = {
        -- Make priority higher than vim-signify
        priority = 100,
      },
      severity_sort = true,
      float = {
        show_header = false,
        source = 'always',
        border = border_window_style,
      },
    }

    -------------
    -- Keymaps --
    -------------
    nnoremap('<leader>cc', function()
      vim.diagnostic.open_float { scope = 'cursor' }
    end, { description = 'Show cursor diagnostics' })
    nnoremap('<space>e', function()
      vim.diagnostic.open_float { scope = 'line' }
    end, { description = 'Show line diagnostics' })
    nnoremap(
      '<space>q',
      '<cmd>lua vim.diagnostic.setloclist()<CR>',
      { description = 'Open buffer diagnostics in local list' }
    )
    nnoremap(
      '<leader>d',
      require('lsp_lines').toggle,
      { description = 'Toggle diagnostic lines' }
    )

    -- float = false, CursorHold will show diagnostic
    nnoremap('[d', function()
      vim.diagnostic.goto_prev { float = false }
    end, { description = 'Jump to previous diagnostic' })
    nnoremap(']d', function()
      vim.diagnostic.goto_next { float = false }
    end, { description = 'Jump to next diagnostic' })

    ----------------
    -- Highlights --
    ----------------
    local user_highlights = function()
      utils.highlight('DiagnosticUnderlineError', {
        guifg = 'none',
        gui = 'undercurl',
        guisp = lsp_colors 'error',
      })
      utils.highlight('DiagnosticUnderlineWarn', {
        guifg = 'none',
        gui = 'undercurl',
        guisp = lsp_colors 'warning',
      })
      utils.highlight('DiagnosticUnderlineInfo', {
        guifg = 'none',
        gui = 'undercurl',
        guisp = lsp_colors 'info',
      })
      utils.highlight('DiagnosticUnderlineHint', {
        guifg = 'none',
        gui = 'undercurl',
        guisp = lsp_colors 'hint',
      })

      local signs = {
        Error = {
          guifg = lsp_colors 'error',
          icon = lsp_symbols 'error',
        },
        Warn = {
          guifg = lsp_colors 'warning',
          icon = lsp_symbols 'warning',
        },
        Hint = {
          guifg = lsp_colors 'hint',
          icon = lsp_symbols 'hint',
        },
        Info = {
          guifg = lsp_colors 'info',
          icon = lsp_symbols 'info',
        },
      }

      for type, config in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        utils.highlight(hl, { guifg = config.guifg })
        vim.fn.sign_define(hl, { text = config.icon, texthl = hl, numhl = '' })
      end
    end

    apply_user_highlights('UtilsLsp', user_highlights, { force = true })
  end,
}
