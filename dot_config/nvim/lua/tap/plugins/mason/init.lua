-- Language server and external tool installer
return {
  'williamboman/mason.nvim',
  cmd = 'Mason',
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
    'jay-babu/mason-nvim-dap.nvim',
  },
  config = function()
    require('mason').setup()

    require 'tap.plugins.mason.registry'

    require('mason-nvim-dap').setup {
      ensure_installed = { 'node2' },
      automatic_setup = true,
    }
    require('mason-nvim-dap').setup_handlers {}
  end,
}
