local lsp_utils = require 'tap.utils.lsp'

local M = {}

M.ensure_installed = { 'cucumber_language_server' }

function M.setup()
  local config = lsp_utils.merge_with_default_config {
    cmd_env = {
      -- requires same node version as shipped with vscode, currently that's v18
      -- https://github.com/cucumber/language-server/issues/102#issuecomment-2026719010
      ASDF_NODEJS_VERSION = '18.16.0',
    },
    -- use package.json as root_dir indicator to work with monorepos
    root_dir = function(fname)
      return vim.fs.dirname(vim.fs.find({ 'package.json', '.git' }, { path = fname, upward = true })[1])
    end,
  }

  require('lspconfig').cucumber_language_server.setup(config)
end

-- New setup funciton using new LSP config API - doesn't work because cmd_cwd
-- defaults to cwd and not root_dir
function M._setup()
  vim.lsp.config('cucumber_language_server', {
    cmd_env = {
      -- requires same node version as shipped with vscode, currently that's v18
      -- https://github.com/cucumber/language-server/issues/102#issuecomment-2026719010
      ASDF_NODEJS_VERSION = '18.16.0',
    },
    root_markers = { 'package.json', '.git' },
    cmd_cwd = '???', -- TODO: needs to resolve to the root_dir but defaults to cwd
  })

  vim.lsp.enable 'cucumber_language_server'
end

return M
