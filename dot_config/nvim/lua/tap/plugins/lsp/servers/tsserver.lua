local lsp_utils = require 'tap.utils.lsp'

local key_name = function(client_id)
  return 'client_' .. client_id
end

local set_tsc_version = function(client_id, version)
  if vim.g.tsc_version == nil then
    vim.g.tsc_version = {}
  end

  local client_key = key_name(client_id)

  if vim.g.tsc_version[client_key] == nil then
    if version ~= nil then
      -- Very convoluted way to update global map
      local tsc_version = vim.g.tsc_version
      tsc_version[client_key] = version
      vim.g.tsc_version = tsc_version
    end
  end
end

local get_tsc_version = function()
  if vim.g.tsc_version ~= nil then
    local tsc_versions = vim.tbl_map(function(client)
      return vim.g.tsc_version[key_name(client.id)]
    end, lsp_utils.get_lsp_clients())

    local valid_versions = vim.tbl_filter(function(version)
      return version ~= nil
    end, tsc_versions)

    if #valid_versions > 0 then
      return valid_versions[1]
    end
  end
  return nil
end

local M = { get_tsc_version = get_tsc_version }

M.ensure_installed = { 'tsserver' }

local handleLogFile = function(message)
  local file_location = message:match 'Log file: (.*)'

  if file_location then
    vim.notify(
      'Log file: ' .. file_location,
      vim.log.levels.DEBUG,
      { title = 'tsserver' }
    )
  end
end

local handleTscVersion = function(message, header)
  local version =
    message:match 'Using Typescript version %(.*%)? (%d+%.%d+%.%d+)'

  set_tsc_version(header.client_id, version)
end

function M.setup()
  require('lspconfig').tsserver.setup(lsp_utils.merge_with_default_config {
    init_options = vim.tbl_deep_extend(
      'force',
      require('lspconfig.server_configurations.tsserver').default_config.init_options,
      {
        tsserver = { logDirectory = vim.env.XDG_CACHE_HOME .. '/nvim/tsserver' },
      },
      lsp_utils.lsp_debug_enabled()
          and { tsserver = { logVerbosity = 'verbose' } }
        or {}
    ),
    handlers = {
      ['window/logMessage'] = function(_, result, header)
        if result == nil or result.message == nil then
          return
        end

        handleLogFile(result.message)
        handleTscVersion(result.message, header)
      end,
    },
  })
end

return M
