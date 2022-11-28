local lspconfig_tsserver = require 'lspconfig.server_configurations.tsserver'
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

local module = { get_tsc_version = get_tsc_version }

function module.setup()
  require('lspconfig').tsserver.setup(lsp_utils.merge_with_default_config {
    init_options = vim.tbl_deep_extend(
      'force',
      lspconfig_tsserver.default_config.init_options,
      {
        tsserver = { logDirectory = vim.env.XDG_CACHE_HOME .. '/nvim/tsserver' },
      },
      vim.env.LSP_DEBUG and { tsserver = { logVerbosity = 'verbose' } } or {}
    ),
    handlers = {
      ['window/logMessage'] = function(_, result, header)
        if result == nil or result.message == nil then
          return
        end

        local version =
          result.message:match '%[lspserver%] Using Typescript version %(.*%)? (%d+%.%d+%.%d+)'

        set_tsc_version(header.client_id, version)
      end,
    },
  })
end

return module
