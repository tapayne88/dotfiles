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

local lsp_settings = {
  java = {
    -- jdt = {
    --   ls = {
    --     vmargs = "-XX:+UseParallelGC -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -Dsun.zip.disableMemoryMapping=true -Xmx1G -Xms100m"
    --   }
    -- },
    eclipse = {
      downloadSources = true,
    },
    configuration = {
      updateBuildConfiguration = 'interactive',
    },
    maven = {
      downloadSources = true,
    },
    implementationsCodeLens = {
      enabled = true,
    },
    referencesCodeLens = {
      enabled = true,
    },
    -- inlayHints = {
    --   parameterNames = {
    --     enabled = 'all' -- literals, all, none
    --   }
    -- },
    format = {
      enabled = true,
      -- settings = {
      --   profile = 'asdf'
      -- },
    },
  },
  signatureHelp = {
    enabled = true,
  },
  completion = {
    favoriteStaticMembers = {
      'org.hamcrest.MatcherAssert.assertThat',
      'org.hamcrest.Matchers.*',
      'org.hamcrest.CoreMatchers.*',
      'org.junit.jupiter.api.Assertions.*',
      'java.util.Objects.requireNonNull',
      'java.util.Objects.requireNonNullElse',
      'org.mockito.Mockito.*',
    },
  },
  contentProvider = {
    preferred = 'fernflower',
  },
  extendedClientCapabilities = { resolveAdditionalTextEditsSupport = true },
  sources = {
    organizeImports = {
      starThreshold = 9999,
      staticStarThreshold = 9999,
    },
  },
  codeGeneration = {
    toString = {
      template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
    },
    useBlocks = true,
  },
}

function M.setup()
  local jdtls = require('mason-registry').get_package 'jdtls'
  local jdtls_install = jdtls:get_install_path()
  local java_agent = jdtls_install .. '/lombok.jar'
  local jdtls_launcher = get_launcher_jar(jdtls:get_receipt())
  local config_name = get_os_config_filename()
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

  local jdtls_setup = function()
    require('jdtls').start_or_attach {
      cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-javaagent:' .. java_agent,
        '-Xmx1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',
        '-jar',
        jdtls_install .. '/' .. jdtls_launcher,
        '-configuration',
        jdtls_install .. '/' .. config_name,
        '-data',
        vim.fn.stdpath 'cache' .. '/jdtls/workspace-root/' .. project_name,
      },
      settings = lsp_settings,
    }
  end

  require('tap.utils').augroup('TapNvim-jdtls', {
    {
      events = { 'FileType' },
      pattern = { 'java', 'kotlin' },
      callback = jdtls_setup,
      desc = 'Setup jdtls',
    },
  })
end

return M
