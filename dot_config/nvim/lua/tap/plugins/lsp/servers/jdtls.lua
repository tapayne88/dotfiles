local M = {}

M.ensure_installed = { 'jdtls' }

function M.setup()
  local jdtls = require('mason-registry').get_package 'jdtls'
  -- local jdtls_version = jdtls:get_receipt()._value.share.links
  local jdtls_version = '1.6.600.v20231106-1826'
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
      jdtls:get_install_path()
        .. '/plugins/org.eclipse.equinox.launcher_'
        .. jdtls_version
        .. '.jar',
      '-configuration',
      jdtls:get_install_path() .. '/config_' .. os_name,
      '-data',
      vim.fn.stdpath 'cache' .. '/jdtls/workspace-root/' .. project_name,
    },
  }
end

return M
