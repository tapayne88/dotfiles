local path = require 'mason-core.path'
local null_ls = require 'null-ls'
local lsp_utils = require 'tap.utils.lsp'

local M = {}

function M.install()
  lsp_utils.ensure_installed {
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
