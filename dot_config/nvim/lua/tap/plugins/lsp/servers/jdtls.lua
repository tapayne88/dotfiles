local M = {}

M.ensure_installed = { 'jdtls' }

--- Get config filename for OS
---@return string | nil
local get_os_config_filename = function()
  if vim.fn.has 'mac' == 1 then
    return 'config_mac'
  elseif vim.fn.has 'unix' == 1 then
    return 'config_linux'
  elseif vim.fn.has 'win32' == 1 then
    return 'config_win'
  end
end

--- Get eclipse jdtls launcher jar from mason install receipt
---@param receipt table
---@return string | nil
local get_launcher_jar = function(receipt)
  assert(type(receipt) == 'table')
  assert(type(receipt._value) == 'table')
  assert(type(receipt._value.links) == 'table')
  assert(type(receipt._value.links.share) == 'table')

  local share_files = receipt._value.links.share

  for _, value in pairs(share_files) do
    if string.match(value, 'org.eclipse.equinox.launcher_') then
      return value
    end
  end
  return nil
end

function M.setup()
  local jdtls = require('mason-registry').get_package 'jdtls'
  local jdtls_launcher = get_launcher_jar(jdtls:get_receipt())
  local config_name = get_os_config_filename()
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
      jdtls:get_install_path() .. '/' .. config_name,
      '-data',
      vim.fn.stdpath 'cache' .. '/jdtls/workspace-root/' .. project_name,
    },
  }
end

return M
