local diagnostic_toggle_map = {
  virtual_text = {
    {
      current_line = 'hide',
    },
    false,
  },
  virtual_lines = {
    { current_line = true },
    false,
  },
}

return {
  'luozhiya/lsp-virtual-improved.nvim',
  event = 'BufReadPost',
  config = function()
    local lsp_symbol = require('tap.utils.lsp').symbol
    local nnoremap = require('tap.utils').nnoremap

    local diagnostic_toggle_index = 1

    require('lsp-virtual-improved').setup()

    vim.diagnostic.config {
      underline = true,
      update_in_insert = false,
      virtual_text = false,
      virtual_improved = diagnostic_toggle_map.virtual_text[diagnostic_toggle_index],
      virtual_lines = diagnostic_toggle_map.virtual_lines[diagnostic_toggle_index],
      signs = {
        -- Make priority higher than vim-signify
        priority = 100,
      },
      severity_sort = true,
      float = {
        show_header = false,
        source = true,
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
      diagnostic_toggle_index = diagnostic_toggle_index == 1 and 2 or 1

      vim.diagnostic.config {
        virtual_improved = diagnostic_toggle_map.virtual_text[diagnostic_toggle_index],
        virtual_lines = diagnostic_toggle_map.virtual_lines[diagnostic_toggle_index],
      }

      local msg = diagnostic_toggle_index == 2 and 'Hide diagnostic output' or 'Show diagnostic output'
      vim.notify(msg, vim.log.levels.INFO, { title = 'Diagnostic' })
    end, { desc = 'Toggle diagnostic display' })

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
