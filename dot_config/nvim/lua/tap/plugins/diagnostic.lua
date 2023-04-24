return {
  'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  event = 'BufReadPre',
  config = function()
    local lsp_symbol = require('tap.utils.lsp').symbol
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
    end, { desc = 'Show cursor diagnostics' })
    nnoremap('<space>e', function()
      vim.diagnostic.open_float { scope = 'line' }
    end, { desc = 'Show line diagnostics' })
    nnoremap(
      '<space>q',
      '<cmd>lua vim.diagnostic.setloclist()<CR>',
      { desc = 'Open buffer diagnostics in local list' }
    )
    nnoremap(
      '<leader>d',
      require('lsp_lines').toggle,
      { desc = 'Toggle diagnostic lines' }
    )

    -- float = false, CursorHold will show diagnostic
    nnoremap('[d', function()
      vim.diagnostic.goto_prev { float = false }
    end, { desc = 'Jump to previous diagnostic' })
    nnoremap(']d', function()
      vim.diagnostic.goto_next { float = false }
    end, { desc = 'Jump to next diagnostic' })

    -----------
    -- Signs --
    -----------
    local signs = {
      Error = {
        icon = lsp_symbol 'error',
      },
      Warn = {
        icon = lsp_symbol 'warning',
      },
      Hint = {
        icon = lsp_symbol 'hint',
      },
      Info = {
        icon = lsp_symbol 'info',
      },
    }

    for type, config in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, { text = config.icon, texthl = hl, numhl = '' })
    end
  end,
}
