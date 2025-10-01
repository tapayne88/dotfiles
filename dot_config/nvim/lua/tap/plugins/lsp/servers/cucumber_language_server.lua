local M = {}

M.ensure_installed = { 'cucumber_language_server' }

-- New setup funciton using new LSP config API - doesn't work because cmd_cwd
-- defaults to cwd and not root_dir
function M.setup()
  local root_markers = { 'package.json', '.git' }
  vim.lsp.config('cucumber_language_server', {
    cmd_env = {
      -- requires same node version as shipped with vscode, currently that's v18
      -- https://github.com/cucumber/language-server/issues/102#issuecomment-2026719010
      ASDF_NODEJS_VERSION = '18.16.0',
    },
    root_markers = root_markers,

    cmd_cwd = vim.fs.root(0, root_markers),
    reuse_client = function(client, config)
      config.cmd_cwd = config.root_dir
      return client.config.cmd_cwd == config.cmd_cwd
    end,
  })

  vim.lsp.enable 'cucumber_language_server'
end

return M
