return {
  -- TODO: Push fixes upstream
  -- 'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  'tapayne88/lsp_lines.nvim',
  event = 'BufReadPost',
  dependencies = {
    'luozhiya/lsp-virtual-improved.nvim',
  },
  config = function()
    local lsp_symbol = require('tap.utils.lsp').symbol
    local nnoremap = require('tap.utils').nnoremap

    local virtual_lines_curr = 1
    local virtual_lines = {
      { only_current_line = true },
      false,
    }
    local virtual_improved_curr = 1
    local virtual_improved = {
      {
        current_line = 'hide',
      },
      false,
    }

    require('lsp_lines').setup {
      only_current_line = {
        events = { 'CursorHold', 'DiagnosticChanged' },
      },
    }
    require('lsp-virtual-improved').setup()

    -- TODO: Create config module where this can live - duplicated in utils/lsp.lua
    local border_window_style = 'rounded'

    vim.diagnostic.config {
      underline = true,
      update_in_insert = false,
      virtual_text = false,
      virtual_improved = virtual_improved[virtual_improved_curr],
      virtual_lines = virtual_lines[virtual_lines_curr],
      signs = {
        -- Make priority higher than vim-signify
        priority = 100,
      },
      severity_sort = true,
      float = {
        show_header = false,
        source = true,
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
    nnoremap('<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', { desc = 'Open buffer diagnostics in local list' })
    nnoremap('<leader>dd', function()
      virtual_improved_curr = virtual_improved_curr < #virtual_improved and virtual_improved_curr + 1 or 1
      local new_virtual_improved = virtual_improved[virtual_improved_curr]

      virtual_lines_curr = virtual_lines_curr < #virtual_lines and virtual_lines_curr + 1 or 1
      local new_virtual_lines = virtual_lines[virtual_lines_curr]

      vim.diagnostic.config {
        virtual_improved = new_virtual_improved,
        virtual_lines = new_virtual_lines,
      }

      local msg = new_virtual_lines == false and 'Hide diagnostic output' or 'Show diagnostic output'
      vim.notify(msg, vim.log.levels.INFO, { title = 'Diagnostic' })
    end, { desc = 'Toggle diagnostic display' })

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
      Error = lsp_symbol 'error',
      Warn = lsp_symbol 'warning',
      Hint = lsp_symbol 'hint',
      Info = lsp_symbol 'info',
    }

    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
    end
  end,
}
