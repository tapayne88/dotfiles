local servers = require 'nvim-lsp-installer.servers'
local server = require 'nvim-lsp-installer.server'
local npm = require 'nvim-lsp-installer.core.managers.npm'
local cargo = require 'nvim-lsp-installer.core.managers.cargo'
local null_ls = require 'null-ls'

local M = {}

function M.patch_install()
  local server_name = 'null-ls'
  local root_dir = server.get_server_root_path(server_name)
  local installer = function()
    npm.install {
      '@fsouza/prettierd',
      'markdownlint-cli',
    }
    cargo.install 'stylua'
  end

  local null_ls_server = server.Server:new {
    name = server_name,
    root_dir = root_dir,
    async = true,
    installer = installer,
  }

  servers.register(null_ls_server)
end

function M.setup() end

return M
