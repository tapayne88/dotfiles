local Package = require 'mason-core.package'
local utils = require 'tap.utils'

if vim.env.LSP_DEBUG then
  vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)
  print('LSP debug log: ' .. vim.lsp.get_log_path())
end

local servers = {
  -- language servers installed with mason.nvim / mason-lspconfig.nvim
  ['mason-lspconfig'] = {
    'bashls',
    'eslint',
    'jsonls',
    'sumneko_lua',
    'tsserver',
  },
  -- custom installers that us mason.nvim
  ['mason'] = {
    'null-ls',
  },
  -- globally installed servers likely through nix
  ['global-servers'] = { 'rnix' },
}

local get_server_list = function(nested_servers)
  return vim.tbl_flatten(vim.tbl_values(nested_servers))
end

local function require_server(server_identifier)
  local server_name = Package.Parse(server_identifier)
  return require('tap.plugins.lspconfig.servers.' .. server_name)
end

utils.run {
  -------------
  -- Install --
  -------------
  function()
    for _, server_name in pairs(servers['mason']) do
      require_server(server_name).installer()
    end
  end,

  -----------
  -- Setup --
  -----------
  function()
    require('lsp-format').setup {}
    -- Ensure desired servers are installed
    require('mason-lspconfig').setup {
      ensure_installed = servers['mason-lspconfig'],
    }
  end,

  -------------
  -- Require --
  -------------
  function()
    -- Setup servers
    for _, server_identifier in pairs(get_server_list(servers)) do
      require_server(server_identifier).setup()
    end
  end,
}
