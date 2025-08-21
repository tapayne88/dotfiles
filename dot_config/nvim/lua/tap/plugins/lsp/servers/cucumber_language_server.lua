local M = {}

M.ensure_installed = { 'cucumber_language_server' }

function M.setup()
  vim.lsp.config('cucumber_language_server', {
    cmd_env = {
      -- requires same node version as shipped with vscode, currently that's v18
      -- https://github.com/cucumber/language-server/issues/102#issuecomment-2026719010
      ASDF_NODEJS_VERSION = '18.16.0',
    },
    root_markers = { 'package.json' },
    cmd_cwd = nil,
  })

  vim.lsp.enable 'cucumber_language_server'
end

return M
