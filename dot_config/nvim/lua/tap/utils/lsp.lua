local utils = require 'tap.utils'
local nnoremap = require('tap.utils').nnoremap

local function toggle_format()
  local filetype = vim.bo.filetype
  local disabled = require('lsp-format').disabled_filetypes[filetype]

  if disabled then
    require('lsp-format').enable { args = filetype }
    vim.notify(
      'enabled formatting for ' .. filetype,
      vim.log.levels.INFO,
      { title = 'LSP Utils' }
    )
  else
    require('lsp-format').disable { args = filetype }
    vim.notify(
      'disabled formatting for ' .. filetype,
      vim.log.levels.WARN,
      { title = 'LSP Utils' }
    )
  end
end

local module = {}

-- on_attach function for lsp.setup calls
---@param client Client
---@param bufnr number
---@return nil
function module.on_attach(client, bufnr)
  require('lsp-format').on_attach(client)

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local with_opts = function(description)
    return { buffer = bufnr, description = '[LSP] ' .. description }
  end
  nnoremap(
    'gD',
    '<cmd>Telescope lsp_definitions<CR>',
    with_opts 'Go to definition'
  )
  nnoremap(
    'gd',
    '<cmd>lua require("goto-preview").goto_preview_definition()<CR>',
    with_opts 'Go to definition preview'
  )
  nnoremap(
    'gi',
    '<cmd>lua vim.lsp.buf.implementation()<CR>',
    with_opts 'Go to implementation'
  )
  nnoremap(
    'gr',
    '<cmd>Telescope lsp_references<CR>',
    with_opts 'Get references'
  )
  nnoremap(
    'K',
    '<cmd>lua vim.lsp.buf.hover()<CR>',
    with_opts 'Show hover information'
  )
  nnoremap(
    '<leader>ac',
    '<cmd>lua vim.lsp.buf.code_action()<CR>',
    with_opts 'Show code actions'
  )
  nnoremap(
    '<leader>rn',
    '<cmd>lua vim.lsp.buf.rename()<CR>',
    with_opts 'Rename'
  )

  -- other mappings, not sure about these
  nnoremap(
    '<space>wa',
    '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',
    with_opts 'Add workspace folder'
  )
  nnoremap(
    '<space>wr',
    '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',
    with_opts 'Remove workspace folder'
  )
  nnoremap(
    '<space>wl',
    '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
    with_opts 'List workspace folders'
  )
  nnoremap(
    '<space>D',
    '<cmd>lua vim.lsp.buf.type_definition()<CR>',
    with_opts 'Go to type definition'
  )

  -- Formatting
  nnoremap('<leader>tf', toggle_format, with_opts 'Toggle formatting on save')
  nnoremap('<space>f', '<cmd>Format<CR>', with_opts 'Run formatting')
end

-- Async function to find npm executable path
---@param cmd string
---@return string[]|nil
function module.get_bin_path(cmd)
  local result, code = utils.get_os_command_output_async(
    { 'yarn', 'bin', cmd },
    nil
  )

  if code ~= 0 then
    vim.notify('`yarn bin ' .. cmd .. '` failed', 'error')
    return nil
  end

  return result[1]
end

local border_window_style = 'rounded'

-- Merge passed config with default config for consistent lsp.setup calls, preserve
-- passed config
---@param config Config
---@return Config
function module.merge_with_default_config(config)
  local lsp_settings = require 'nvim-lsp-installer.settings'

  local base_config = {
    autostart = true,
    on_attach = module.on_attach,
    -- set cmd_cwd to nvim-lsp-installer dir to ensure node version consistency
    cmd_cwd = lsp_settings.current.install_root_dir,
    handlers = {
      ['textDocument/signatureHelp'] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        {
          border = border_window_style,
        }
      ),
      ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = border_window_style,
      }),
    },
    capabilities = require('cmp_nvim_lsp').update_capabilities(
      vim.lsp.protocol.make_client_capabilities()
    ),
  }
  return vim.tbl_deep_extend('force', base_config, config or {})
end

-- Get active LSP clients
---@return table[]
function module.get_lsp_clients()
  if next(vim.lsp.buf_get_clients(0)) == nil then
    return {}
  end
  local active_clients = vim.lsp.get_active_clients()

  return active_clients
end

function module.setup(_)
end

return module
