return {
  'folke/trouble.nvim',
  dependencies = 'kyazdani42/nvim-web-devicons',
  config = function()
    local nnoremap = require('tap.utils').nnoremap
    local lsp_symbols = require('tap.utils.lsp').symbols

    require('trouble').setup {
      signs = {
        error = lsp_symbols 'error',
        warning = lsp_symbols 'warning',
        hint = lsp_symbols 'hint',
        information = lsp_symbols 'info',
        other = lsp_symbols 'ok',
      },
    }

    nnoremap(
      '<leader>xx',
      '<cmd>TroubleToggle<cr>',
      { description = '[Trouble] Toggle list' }
    )
    nnoremap(
      '<leader>xw',
      '<cmd>TroubleToggle workspace_diagnostics<cr>',
      { description = '[Trouble] LSP workspace diagnostics' }
    )
    nnoremap(
      '<leader>xd',
      '<cmd>TroubleToggle document_diagnostics<cr>',
      { description = '[Trouble] LSP document diagnostics' }
    )
    nnoremap(
      '<leader>xq',
      '<cmd>TroubleToggle quickfix<cr>',
      { description = '[Trouble] Quickfix list' }
    )
    nnoremap(
      '<leader>xl',
      '<cmd>TroubleToggle loclist<cr>',
      { description = '[Trouble] Location list' }
    )
    nnoremap(
      'gR',
      '<cmd>TroubleToggle lsp_references<cr>',
      { description = '[Trouble] LSP references' }
    )
  end,
}
