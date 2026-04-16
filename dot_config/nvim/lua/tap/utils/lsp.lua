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
  -- Mappings.
  local with_opts = function(desc)
    return { buffer = bufnr, desc = '[LSP] ' .. desc }
  end

  vim.keymap.set('n', 'grn', require('live-rename').rename, with_opts 'Rename')

  -- other mappings, not sure about these
  vim.keymap.set('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', with_opts 'Add workspace folder')
  vim.keymap.set(
    'n',
    '<space>wr',
    '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',
    with_opts 'Remove workspace folder'
  )
  vim.keymap.set(
    'n',
    '<space>wl',
    '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
    with_opts 'List workspace folders'
  )
  vim.keymap.set('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', with_opts 'Go to type definition')

  if vim.lsp.inlay_hint then
    vim.keymap.set('n', '<leader>ih', function()
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

-- Merge passed config with default config for consistent lsp.setup calls, preserve
-- passed config
---@param config table|nil
---@return table
function M.merge_with_default_config(config)
  local base_config = {
    on_attach = on_attach,
  }
  return vim.tbl_deep_extend('force', base_config, config or {})
end

-- Get active LSP clients for buffer
---@return table[]
function M.get_lsp_clients()
  return vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() }
end

--- Check if we're running in LSP debug mode
---@return boolean
function M.lsp_debug_enabled()
  return require('tap.utils').getenv_bool 'LSP_DEBUG'
end

return M
