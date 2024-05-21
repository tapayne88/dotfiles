local lsp_utils = require 'tap.utils.lsp'

local key_name = function(client_id)
  return 'client_' .. client_id
end

local set_tsc_version = function(client_id, version)
  if version == nil then
    return
  end

  if vim.g.tsc_version == nil then
    vim.g.tsc_version = {}
  end

  local client_key = key_name(client_id)

  if vim.g.tsc_version[client_key] == nil then
    -- Very convoluted way to update global map
    local tsc_version = vim.g.tsc_version
    tsc_version[client_key] = version
    vim.g.tsc_version = tsc_version
  end
end

local get_tsc_version = function()
  if vim.g.tsc_version == nil then
    return nil
  end

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

local M = { get_tsc_version = get_tsc_version }

--------------------------------------------------------------------------------
--
-- MacOS:
-- I've had some recurring issues with tsserver not observing file changes in
-- dependencies.
-- I _think_ this is because of a low file descriptor limit on macOS resulting
-- in watchman failing to find dependent files.
--
-- The solution was to up the file descriptor limit as per the watchman docs.
-- https://facebook.github.io/watchman/docs/install#macos-file-descriptor-limits
--
-- Update: increasing the file descriptor limit caused some very adverse affects
-- like system crashes. Instead I've installed watchman via homebrew and it
-- seems to be working better.
--
--------------------------------------------------------------------------------
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

function M.setup()
  require('lspconfig').tsserver.setup(lsp_utils.merge_with_default_config {
    init_options = vim.tbl_deep_extend(
      'force',
      require('lspconfig.server_configurations.tsserver').default_config.init_options,
      {
        preferences = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        tsserver = { logDirectory = vim.env.XDG_CACHE_HOME .. '/nvim/tsserver' },
      },
      lsp_utils.lsp_debug_enabled()
          and { tsserver = { logVerbosity = 'verbose' } }
        or {}
    ),
    handlers = {
      ['window/logMessage'] = function(_, result, header)
        -- Call any global handlers like output-panel.nvim
        pcall(vim.lsp.handlers['window/logMessage'], _, result, header)

        if result == nil or result.message == nil then
          return
        end

        handleLogFile(result.message)
      end,
      ['$/typescriptVersion'] = function(_, result, header)
        -- Call any global handlers like output-panel.nvim
        pcall(vim.lsp.handlers['$/typescriptVersion'], _, result, header)

        if result == nil then
          return
        end

        set_tsc_version(header.client_id, result.version)
      end,
    },
  })
end

return M
