-- Language server and external tool installer
return {
  'williamboman/mason.nvim',
  cmd = 'Mason',
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
  },
  opts = {},
}
