local augroup = require('tap.utils').augroup
local termcodes = require('tap.utils').termcodes
local test_visible_buffers = require('tap.utils').test_visible_buffers

-- Automatically resize vim splits on resize
augroup('TapWinResize', {
  {
    events = { 'VimResized' },
    pattern = { '*' },
    callback = function()
      local is_dap_ui_running = test_visible_buffers(function(window_info)
        local buffer_filetype =
          vim.api.nvim_get_option_value('filetype', { buf = window_info.bufnr })
        return vim.tbl_contains(
          require('tap.utils').dap_filetypes,
          buffer_filetype
        )
      end)

      -- Don't attempt to resize if we're running dap-ui
      if not is_dap_ui_running then
        vim.api.nvim_exec2(
          'execute "normal! ' .. termcodes '<c-w>' .. '="',
          { output = false }
        )
      end
    end,
  },
})

-- Save and load vim views - remembers scroll position & folds
augroup('TapMkViews', {
  {
    events = { 'BufWinLeave' },
    pattern = { '*.*' },
    command = 'silent! mkview',
  },
  {
    events = { 'BufWinEnter' },
    pattern = { '*.*' },
    command = 'silent! loadview',
  },
})

-- Only show colorcolumn for certain filetypes
augroup('TapColorColumn', {
  {
    events = { 'FileType' },
    pattern = { '*' },
    callback = function()
      local ft_excluded_colorcolumn = {
        'dap-repl',
        'fugitive',
        'git',
        'mason',
        'oil',
        'qf',
        'rgflow',
        'trouble',
        'TelescopeResults',
      }

      if vim.tbl_contains(ft_excluded_colorcolumn, vim.bo.filetype) then
        vim.opt_local.colorcolumn = ''
      else
        vim.opt_local.colorcolumn = '80'
      end
    end,
  },
})

-- Automatically disable search highlight done searching
local function toggle_hlsearch(char)
  if vim.fn.mode() == 'n' then
    local keys = { '<CR>', 'n', 'N', '*', '#', '?', '/' }
    local new_hlsearch = vim.tbl_contains(keys, vim.fn.keytrans(char))

    if vim.opt.hlsearch:get() ~= new_hlsearch then
      vim.opt.hlsearch = new_hlsearch
    end
  end
end

vim.on_key(toggle_hlsearch, vim.api.nvim_create_namespace 'toggle_hlsearch')
