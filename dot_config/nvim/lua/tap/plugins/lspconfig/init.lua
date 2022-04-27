local lsp_installer = require 'nvim-lsp-installer'
local lsp_installer_servers = require 'nvim-lsp-installer.servers'
local lsp_utils = require 'tap.utils.lsp'

if vim.env.LSP_DEBUG then
  vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)
  print('LSP debug log: ' .. vim.lsp.get_log_path())
end

local servers = {
  -- servers installed with williamboman/nvim-lsp-installer
  ['nvim-lsp-installer'] = {
    'bashls',
    'diagnosticls',
    'eslint',
    'jsonls',
    'null-ls',
    'sumneko_lua@v2.5.6',
    'tsserver',
  },
  -- globally installed servers likely through nix
  ['global-servers'] = { 'rnix' },
}

local function before()
  require('lsp-format').setup {}
end

local function require_server(server_name)
  return require('tap.plugins.lspconfig.servers.' .. server_name)
end

local function init_servers()
  for _, server_identifier in pairs(servers['nvim-lsp-installer']) do
    local name, version = lsp_installer_servers.parse_server_identifier(
      server_identifier
    )

    local server_config = require_server(name)
    if server_config.patch_install then
      server_config.patch_install(version)
    end
  end
end

local function setup_servers(initialise)
  for _, server_identifier in pairs(servers['nvim-lsp-installer']) do
    -- parse server identifier, could be something like 'sumneko_lua@2.5.6'
    local name, version = lsp_installer_servers.parse_server_identifier(
      server_identifier
    )
    local ok, server = lsp_installer.get_server(name)

    -- Check that the server is supported in nvim-lsp-installer
    if ok then
      if not server:is_installed() then
        vim.notify(
          'Installing ' .. server_identifier,
          'info',
          { title = 'LSPInstall' }
        )
        server:install(version)
      end
      server:on_ready(function()
        require_server(name).setup(server)
      end)
    else
      vim.notify(
        'Attempted to setup server '
          .. server_identifier
          .. ' with nvim-lsp-installer but not supported',
        'warn',
        { title = 'LSPInstall' }
      )
    end
  end

  -- non-nvim-lsp-installer servers like rnix
  for _, name in pairs(servers['global-servers']) do
    require_server(name).setup()
  end

  initialise()
end

before()
init_servers()
setup_servers(function()
  lsp_utils.init_diagnositcs()
end)
