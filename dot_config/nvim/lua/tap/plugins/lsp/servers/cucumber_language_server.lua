local M = {}

M.ensure_installed = { 'cucumber_language_server' }

function M.setup()
  vim.lsp.config('cucumber_language_server', {
    cmd_env = {
      -- requires same node version as shipped with vscode, currently that's v18
      -- https://github.com/cucumber/language-server/issues/102#issuecomment-2026719010
      ASDF_NODEJS_VERSION = '18.16.0',
    },
    -- use package.json as root_dir indicator to work with monorepos
    root_dir = require('lspconfig.util').find_package_json_ancestor,
    cmd_cwd = nil,
  })

  vim.lsp.enable 'cucumber_language_server'
end

return M
