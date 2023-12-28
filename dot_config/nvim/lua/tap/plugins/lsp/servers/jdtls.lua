local M = {}

M.ensure_installed = { 'jdtls' }

---@param receipt table
---@return string | nil
local get_launcher_jar = function(receipt)
  if receipt._value == nil then
    return nil
  end

  local share_files = receipt._value.links.share

  for key, value in pairs(share_files) do
    if string.match(key, 'org.eclipse.equinox.launcher_') then
      print(key, value)
      return value
    end
  end
  return nil
end

function M.setup()
  local jdtls = require('mason-registry').get_package 'jdtls'
  local jdtls_launcher = get_launcher_jar(jdtls:get_receipt())
  local os_name = string.lower(vim.loop.os_uname().sysname)
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

  require('jdtls').start_or_attach {
    cmd = {
      'java',
      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      '-Xmx1g',
      '--add-modules=ALL-SYSTEM',
      '--add-opens',
      'java.base/java.util=ALL-UNNAMED',
      '--add-opens',
      'java.base/java.lang=ALL-UNNAMED',
      '-jar',
      jdtls:get_install_path() .. '/' .. jdtls_launcher,
      '-configuration',
      jdtls:get_install_path() .. '/config_' .. os_name,
      '-data',
      vim.fn.stdpath 'cache' .. '/jdtls/workspace-root/' .. project_name,
    },
  }
end

return M
