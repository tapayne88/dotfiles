-- Language server and external tool installer
return {
  'williamboman/mason.nvim',
  cmd = 'Mason',
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
  },
  config = function()
    require('mason').setup()

    require 'tap.plugins.mason.registry'
  end,
}
