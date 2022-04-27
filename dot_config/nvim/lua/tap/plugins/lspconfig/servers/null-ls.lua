local servers = require 'nvim-lsp-installer.servers'
local server = require 'nvim-lsp-installer.server'
local npm = require 'nvim-lsp-installer.core.managers.npm'
local cargo = require 'nvim-lsp-installer.core.managers.cargo'
local null_ls = require 'null-ls'
local lsp_utils = require 'tap.utils.lsp'

local M = {}
local server_name = 'null-ls'

function M.patch_install()
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

function M.setup()
  local root_dir = server.get_server_root_path(server_name)
  null_ls.setup(lsp_utils.merge_with_default_config {
    sources = {
      null_ls.builtins.formatting.stylua.with {
        command = root_dir .. '/bin/stylua',
        condition = function(utils)
          return utils.root_has_file { 'stylua.toml', '.stylua.toml' }
        end,
      },
      null_ls.builtins.formatting.prettierd.with {
        command = root_dir .. '/node_modules/.bin/prettierd',
        condition = function(utils)
          return utils.root_has_file {
            'package.json',
            '.prettierrc',
            '.prettierrc.json',
            '.prettierrc.toml',
            '.prettierrc.json',
            '.prettierrc.yml',
            '.prettierrc.yaml',
            '.prettierrc.json5',
            '.prettierrc.js',
            '.prettierrc.cjs',
            'prettier.config.js',
            'prettier.config.cjs',
          }
        end,
      },
    },
  })
end

return M
