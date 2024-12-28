local M = {}

---@class Client
---@field server_capabilities { documentSymbolProvider: boolean }

---@alias lsp_status 'error' | 'warning' | 'info' | 'hint' | 'ok'

---@param type lsp_status | 'hint_alt'
---@return string
M.symbol = function(type)
  local symbols = {
    error = '󰅚 ',
    warning = '󰀪 ',
    info = ' ',
    hint = '󰌶 ',
    hint_alt = '󰌵 ',
    ok = '󰄴 ',
  }

  return symbols[type]
end

---@param on_attach fun(client, buffer)
function M.on_attach(on_attach)
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

-- on_attach function for lsp.setup calls
---@param _ Client
---@param bufnr number
---@return nil
local function on_attach(_, bufnr)
  local nnoremap = require('tap.utils').nnoremap
  local keymap = require('tap.utils').keymap

  -- Mappings.
  local with_opts = function(desc)
    return { buffer = bufnr, desc = '[LSP] ' .. desc }
  end
  nnoremap('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', with_opts 'Go to implementation')
  nnoremap('<leader>ac', '<cmd>lua vim.lsp.buf.code_action()<CR>', with_opts 'Show code actions')
  nnoremap('<leader>rn', require('live-rename').rename, with_opts 'Rename')

  -- other mappings, not sure about these
  nnoremap('<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', with_opts 'Add workspace folder')
  nnoremap('<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', with_opts 'Remove workspace folder')
  nnoremap(
    '<space>wl',
    '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
    with_opts 'List workspace folders'
  )
  nnoremap('<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', with_opts 'Go to type definition')

  if vim.lsp.inlay_hint then
    keymap('n', '<leader>ih', function()
      local new_state = not vim.lsp.inlay_hint.is_enabled { bufnr = 0 }
      vim.lsp.inlay_hint.enable(new_state, { bufnr = 0 })
    end, with_opts 'Toggle Inlay Hints')
  end
end

-- Async function to find npm executable path
---@param cmd string
---@return string[]|nil
function M.get_bin_path(cmd)
  local result, code = require('tap.utils.async').get_os_command_output_async({ 'yarn', 'bin', cmd }, nil)

  if code ~= 0 then
    vim.notify('`yarn bin ' .. cmd .. '` failed', vim.log.levels.ERROR)
    return nil
  end

  return result[1]
end

-- TODO: Create config module where this can live - duplicated in diagnostic.lua
local border_window_style = 'rounded'

-- Merge passed config with default config for consistent lsp.setup calls, preserve
-- passed config
---@param config table|nil
---@return table
function M.merge_with_default_config(config)
  local mason_settings = require 'mason.settings'

  local base_config = {
    autostart = true,
    on_attach = on_attach,
    -- set cmd_cwd to mason install_root_dir to ensure node version consistency
    cmd_cwd = mason_settings.current.install_root_dir,
    handlers = {
      ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = border_window_style,
      }),
      ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = border_window_style,
      }),
    },
    capabilities = vim.tbl_deep_extend(
      'force',
      vim.lsp.protocol.make_client_capabilities(),
      require('cmp_nvim_lsp').default_capabilities()
    ),
  }
  return vim.tbl_deep_extend('force', base_config, config or {})
end

-- Get active LSP clients for buffer
---@return table[]
function M.get_lsp_clients()
  return vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() }
end

--- Install package at version
---@param p {} Package object from mason.nvim
---@param version string|nil Package version
---@return nil
local function do_install(p, version)
  local notify_opts = { title = 'mason.nvim' }
  if version ~= nil then
    vim.notify(string.format('%s: updating to %s', p.name, version), vim.log.levels.INFO, notify_opts)
  else
    vim.notify(string.format('%s: installing', p.name), vim.log.levels.INFO, notify_opts)
  end
  p:on('install:success', function()
    vim.notify(
      string.format('%s: successfully installed', p.name),
      vim.log.levels.INFO,
      vim.tbl_extend('error', notify_opts, { icon = M.symbols 'ok' })
    )
  end)
  p:on('install:failed', function()
    vim.notify(string.format('%s: failed to install', p.name), vim.log.levels.ERROR, notify_opts)
  end)
  p:install { version = version }
end

--- Install list of mason.nvim recognised packages and ensure they're the correct version
--- Largely copied from https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/blob/d72842d361d4f2b0504b8b88501411204b5be965/lua/mason-tool-installer/init.lua
---@param identifiers string[] Array of encoded name/version package identifiers e.g. {'stylua@0.14.1'}
---@return nil
function M.ensure_installed(identifiers)
  for _, identifier in pairs(identifiers) do
    local name, version = require('mason-core.package').Parse(identifier)
    local p = require('mason-registry').get_package(name)
    if p:is_installed() then
      if version ~= nil then
        p:get_installed_version(function(ok, installed_version)
          if ok and installed_version ~= version then
            do_install(p, version)
          end
        end)
      end
    else
      do_install(p, version)
    end
  end
end

--- Check if we're running in LSP debug mode
---@return boolean
function M.lsp_debug_enabled()
  return require('tap.utils').getenv_bool 'LSP_DEBUG'
end

return M
