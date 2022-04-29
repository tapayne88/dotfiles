local lsp_installer_servers = require 'nvim-lsp-installer.servers'
local utils = require 'tap.utils'
local lsp_utils = require 'tap.utils.lsp'

if vim.env.LSP_DEBUG then
  vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)
  print('LSP debug log: ' .. vim.lsp.get_log_path())
end

local servers = {
  -- servers installed with williamboman/nvim-lsp-installer
  ['nvim-lsp-installer'] = {
    'bashls',
    'eslint',
    'jsonls',
    'null-ls',
    'sumneko_lua@v2.5.6',
    'tsserver',
  },
  -- globally installed servers likely through nix
  ['global-servers'] = { 'rnix' },
}

local get_server_list = function(nested_servers)
  return vim.tbl_flatten(vim.tbl_values(nested_servers))
end

local function require_server(server_identifier)
  local server_name = lsp_installer_servers.parse_server_identifier(
    server_identifier
  )
  return require('tap.plugins.lspconfig.servers.' .. server_name)
end

utils.run {
  ----------------------
  -- Setup Installers --
  ----------------------
  function()
    for _, server_identifier in pairs(servers['nvim-lsp-installer']) do
      local _, version = lsp_installer_servers.parse_server_identifier(
        server_identifier
      )

      local server_config = require_server(server_identifier)
      if server_config.patch_install then
        server_config.patch_install(version)
      end
    end
  end,

  -----------
  -- Setup --
  -----------
  function()
    require('lsp-format').setup {}
    -- Ensure desired servers are installed
    require('nvim-lsp-installer').setup {
      ensure_installed = servers['nvim-lsp-installer'],
    }
  end,

  ----------------------
  -- Register Servers --
  ----------------------
  function()
    -- Setup servers
    for _, server_identifier in pairs(get_server_list(servers)) do
      require_server(server_identifier).setup()
    end
  end,

  -----------
  -- After --
  -----------
  function()
    lsp_utils.init_diagnositcs()
  end,
}
