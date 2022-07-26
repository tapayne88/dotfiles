local Package = require 'mason-core.package'
local mason_registry = require 'mason-registry'
local path = require 'mason-core.path'
local null_ls = require 'null-ls'
local lsp_utils = require 'tap.utils.lsp'

local M = {}
local server_name = 'null-ls'

local function do_install(p, version)
  if version ~= nil then
    vim.notify(
      string.format('%s: updating to %s', p.name, version),
      vim.log.levels.INFO
    )
  else
    vim.notify(string.format('%s: installing', p.name), vim.log.levels.INFO)
  end
  p:on('install:success', function()
    vim.notify(
      string.format('%s: successfully installed', p.name),
      vim.log.levels.DEBUG
    )
  end)
  p:on('install:failed', function()
    vim.notify(
      string.format('%s: failed to install', p.name),
      vim.log.levels.ERROR
    )
  end)
  p:install { version = version }
end

local function ensure_installed(identifiers)
  for _, identifier in pairs(identifiers) do
    local name, version = Package.Parse(identifier)
    local p = mason_registry.get_package(name)
    if p:is_installed() then
      if version ~= nil then
        p:get_installed_version(function(ok, installed_version)
          if ok and installed_version ~= version then
            do_install(p, version)
          end
        end)
      end
    else
      do_install(p, version)
    end
  end
end

function M.installer()
  ensure_installed {
    'prettierd',
    'markdownlint',
    'stylua',
  }
end

function M.setup()
  null_ls.setup(lsp_utils.merge_with_default_config {
    sources = {
      ------------------
      -- Code Actions --
      ------------------
      null_ls.builtins.code_actions.shellcheck,

      -----------------
      -- Diagnostics --
      -----------------
      null_ls.builtins.diagnostics.markdownlint.with {
        command = path.bin_prefix 'markdownlint',
        extra_args = {
          '--config',
          vim.fn.stdpath 'config' .. '/markdownlint.json',
        },
      },
      null_ls.builtins.diagnostics.shellcheck,

      ----------------
      -- Formatting --
      ----------------
      null_ls.builtins.formatting.stylua.with {
        command = path.bin_prefix 'stylua',
        condition = function(utils)
          return utils.root_has_file { 'stylua.toml', '.stylua.toml' }
        end,
      },
      null_ls.builtins.formatting.prettierd.with {
        command = path.bin_prefix 'prettierd',
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

      -----------
      -- Hover --
      -----------
      null_ls.builtins.hover.dictionary,
    },
  })
end

return M
