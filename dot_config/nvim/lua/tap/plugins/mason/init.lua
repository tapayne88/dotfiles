-- Language server and external tool installer
return {
  'williamboman/mason.nvim',
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
  },
  config = function()
    require('mason').setup()
    require 'tap.plugins.mason.registry'
  end,
}
