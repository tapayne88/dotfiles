local augroup = require('tap.utils').augroup
local termcodes = require('tap.utils').termcodes
local test_visible_buffers = require('tap.utils').test_visible_buffers

-- Automatically resize vim splits on resize
augroup('TapWinResize', {
  {
    events = { 'VimResized' },
    targets = { '*' },
    command = function()
      local is_dap_ui_running = test_visible_buffers(function(window_info)
        local buffer_filetype =
          vim.api.nvim_buf_get_option(window_info.bufnr, 'filetype')
        return vim.tbl_contains({
          'dap-repl',
          'dapui_breakpoints',
          'dapui_console',
          'dapui_scopes',
          'dapui_stacks',
          'dapui_watches',
        }, buffer_filetype)
      end)

      -- Don't attempt to resize if we're running dap-ui
      if not is_dap_ui_running then
        vim.api.nvim_exec(
          'execute "normal! ' .. termcodes '<c-w>' .. '="',
          false
        )
      end
    end,
  },
})

-- Save and load vim views - remembers scroll position & folds
augroup('TapMkViews', {
  { events = { 'BufWinLeave' }, targets = { '*.*' }, command = 'mkview' },
  {
    events = { 'BufWinEnter' },
    targets = { '*.*' },
    command = 'silent! loadview',
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
