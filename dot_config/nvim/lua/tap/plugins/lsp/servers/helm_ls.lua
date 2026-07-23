local M = {}

-- Restart helm_ls so it re-indexes the freshly-vendored charts.
local function restart_helm_ls()
  local clients = vim.lsp.get_clients { name = 'helm_ls' }
  if vim.tbl_isempty(clients) then
    return
  end
  for _, client in ipairs(clients) do
    client:stop(true)
  end
  -- Reload the current buffer to retrigger attach once the client has stopped.
  vim.defer_fn(function()
    if vim.bo.filetype == 'helm' and not vim.bo.modified then
      pcall(vim.cmd.edit)
    end
  end, 500)
end

local function helm_dep_update()
  local root = vim.fs.root(0, 'Chart.yaml')
  if not root then
    vim.notify('No Chart.yaml found for the current file', vim.log.levels.ERROR, { title = 'helm' })
    return
  end

  vim.notify('helm dependency update: ' .. root, vim.log.levels.INFO, { title = 'helm' })
  vim.system({ 'helm', 'dependency', 'update', root }, { text = true }, function(out)
    vim.schedule(function()
      if out.code ~= 0 then
        vim.notify('helm dependency update failed:\n' .. (out.stderr or ''), vim.log.levels.ERROR, { title = 'helm' })
        return
      end
      vim.notify('helm deps updated', vim.log.levels.INFO, { title = 'helm' })
      restart_helm_ls()
    end)
  end)
end

function M.setup()
  vim.lsp.enable 'helm_ls'

  vim.api.nvim_create_user_command('HelmDepUpdate', helm_dep_update, {
    desc = 'Run `helm dependency update` for the current chart',
  })
end

return M
