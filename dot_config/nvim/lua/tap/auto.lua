local augroup = require('tap.utils').augroup
local termcodes = require('tap.utils').termcodes

-- Automatically resize vim splits on resize
augroup('TapWinResize', {
  {
    events = { 'VimResized' },
    targets = { '*' },
    command = 'execute "normal! ' .. termcodes '<c-w>' .. '="',
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
