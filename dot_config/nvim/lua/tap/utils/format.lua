local lsp_format = require 'lsp-format'
local root_pattern = require('tap.utils').root_pattern

local M = {}

-- Used to handle autocommand formatting - Format command (from lsp-format) will
-- ignore buffer disabling
local format = function(options)
  if
    lsp_format.buffers[options.buf]
    and lsp_format.buffers[options.buf].should_format
  then
    lsp_format.format(options)
  else
    vim.notify(
      'Formatting disabled for buffer due to missing config',
      vim.log.levels.INFO,
      { title = 'lsp-format' }
    )
  end
end

local should_format = function()
  -- TODO: Expand below to use filetype to detect correct root pattern
  return root_pattern(vim.tbl_flatten {
    {
      'package.json',
      '.prettierrc',
      '.prettierrc.json',
      '.prettierrc.toml',
      '.prettierrc.json',
      '.prettierrc.yml',
      '.prettierrc.yaml',
      '.prettierrc.json5',
      '.prettierrc.js',
      '.prettierrc.cjs',
      'prettier.config.js',
      'prettier.config.cjs',
    },
    { 'stylua.toml', '.stylua.toml' },
  })(vim.fn.expand '%:p:h') ~= nil
end

-- Copy of lsp-format's on_attach function to allow overriding of `format` function
-- https://github.com/lukas-reineke/lsp-format.nvim/blob/b611bd6cea82ccc127cf8fd781a1cb784b0d6d3c/lua/lsp-format/init.lua#L122-L153
---@param client Client
---@return nil
M.lsp_format_on_attach = function(client)
  if not client.supports_method 'textDocument/formatting' then
    vim.lsp.log.warn(
      string.format(
        '"textDocument/formatting" is not supported for %s, not attaching lsp-format',
        client.name
      )
    )
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()

  if lsp_format.buffers[bufnr] == nil then
    -- Below line has had logic updated to capture if the format config file is present
    lsp_format.buffers[bufnr] = { should_format = should_format() }
  end

  table.insert(lsp_format.buffers[bufnr], client.id)

  local format_options = lsp_format.format_options[vim.bo.filetype] or {}

  local event = 'BufWritePost'
  if format_options.sync then
    event = 'BufWritePre'
  end

  local group = vim.api.nvim_create_augroup('Format', { clear = false })

  vim.api.nvim_clear_autocmds {
    buffer = bufnr,
    group = group,
  }

  vim.api.nvim_create_autocmd(event, {
    group = group,
    desc = 'format on save',
    pattern = '<buffer>',
    callback = format,
  })
end

return M
