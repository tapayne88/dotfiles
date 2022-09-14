local utils = require 'tap.utils'
local apply_user_highlights = require('tap.utils').apply_user_highlights
local nnoremap = require('tap.utils').nnoremap

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

local show_cursor_diagnositcs = function()
  vim.diagnostic.open_float { scope = 'cursor' }
end
local show_line_diagnositcs = function()
  vim.diagnostic.open_float { scope = 'line' }
end

-------------
-- Keymaps --
-------------
nnoremap(
  '<leader>cc',
  show_cursor_diagnositcs,
  { description = 'Show cursor diagnostics' }
)
nnoremap(
  '<space>e',
  show_line_diagnositcs,
  { description = 'Show line diagnostics' }
)
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
    guisp = utils.lsp_colors 'error',
  })
  utils.highlight('DiagnosticUnderlineWarn', {
    guifg = 'none',
    gui = 'undercurl',
    guisp = utils.lsp_colors 'warning',
  })
  utils.highlight('DiagnosticUnderlineInfo', {
    guifg = 'none',
    gui = 'undercurl',
    guisp = utils.lsp_colors 'info',
  })
  utils.highlight('DiagnosticUnderlineHint', {
    guifg = 'none',
    gui = 'undercurl',
    guisp = utils.lsp_colors 'hint',
  })

  local signs = {
    Error = {
      guifg = utils.lsp_colors 'error',
      icon = utils.lsp_symbols['error'],
    },
    Warn = {
      guifg = utils.lsp_colors 'warning',
      icon = utils.lsp_symbols['warning'],
    },
    Hint = {
      guifg = utils.lsp_colors 'hint',
      icon = utils.lsp_symbols['hint'],
    },
    Info = {
      guifg = utils.lsp_colors 'info',
      icon = utils.lsp_symbols['info'],
    },
  }

  for type, config in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    utils.highlight(hl, { guifg = config.guifg })
    vim.fn.sign_define(hl, { text = config.icon, texthl = hl, numhl = '' })
  end
end

apply_user_highlights('UtilsLsp', user_highlights, { force = true })
