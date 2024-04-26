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
    root_dir = require('lspconfig.util').find_package_json_ancestor,
  }

  -- unset cwd, needs to use root_dir so feature files can be resolved
  config['cmd_cwd'] = nil

  require('lspconfig').cucumber_language_server.setup(config)
end

return M
