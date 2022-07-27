local nnoremap = require('tap.utils').nnoremap
local nmap = require('tap.utils').nmap
local vnoremap = require('tap.utils').vnoremap
local tnoremap = require('tap.utils').tnoremap
local xnoremap = require('tap.utils').xnoremap
local termcodes = require('tap.utils').termcodes

nnoremap('j', 'gj', { description = 'Jump down one wrapped line' })
nnoremap('k', 'gk', { description = 'Jump up one wrapped line' })

vnoremap('<', '<gv', { description = 'Shift selected text left' })
vnoremap('>', '>gv', { description = 'Shift selected text right' })

vnoremap('J', ":m '>+1<CR>gv=gv", { description = 'Move selected text down' })
vnoremap('K', ":m '<-2<CR>gv=gv", { description = 'Move selected text up' })

vnoremap(
  '//',
  "y/\\V<C-R>=escape(@\",'/')<CR><CR>",
  { description = 'Search for current visual selection' }
)

nnoremap('<c-q>', ':copen<CR>', { description = 'Open quickfix list' })
nnoremap('<LocalLeader>q', ':lopen<CR>', { description = 'Open local list' })

nnoremap(
  '<leader>fp',
  ':echo @% | let @*=expand("%")<CR>',
  { description = 'Print and copy to system clipboard the filepath' }
)
vnoremap(
  '<leader>fp',
  ':<C-U>echo fnamemodify(expand("%"), ":~:.") . ":" . line(".") | let @*=fnamemodify(expand("%"), ":~:.") . ":" . line(".")<CR>',
  {
    description = 'Print and copy to system clipboard filepath with line number',
  }
)
nnoremap(
  '<leader>cm',
  ':!chezmoi apply -v<CR>',
  { description = 'Apply chezmoi changes' }
)
nnoremap('<leader>ex', ':Ex<CR>', { description = 'Open netrw' })

nnoremap(
  '<leader>evv',
  ':vsplit ' .. vim.g.chezmoi_source_dir .. '/dot_config/nvim/init.lua<CR>',
  { description = 'Open nvim/init.lua in vertical split' }
)
nnoremap(
  '<leader>ev',
  ':split ' .. vim.g.chezmoi_source_dir .. '/dot_config/nvim/init.lua<CR>',
  { description = 'Open nvim/init.lua in split' }
)
nnoremap('<leader>sv', function()
  require('plenary.reload').reload_module('tap', true)
  vim.cmd ':source $MYVIMRC'
  vim.notify(
    "Cleared 'tap.*' module cache and reloaded " .. vim.env.MYVIMRC,
    vim.log.levels.INFO,
    { title = 'Re-source init.vim' }
  )
end, { description = 'Source nvim/init.vim' })

tnoremap(
  '<Esc>',
  [[<C-\><C-n>]],
  { description = 'Escape terminal insert mode with <Esc>' }
)
tnoremap(
  '<A-[>',
  '<Esc>',
  { description = 'Alternate mapping to send esc to terminal' }
)

-- Multiple Cursors
-- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
-- https://github.com/akinsho/dotfiles/blob/45c4c17084d0aa572e52cc177ac5b9d6db1585ae/.config/nvim/plugin/mappings.lua#L298

-- 1. Position the cursor anywhere in the word you wish to change;
-- 2. Or, visually make a selection;
-- 3. Hit cn, type the new word, then go back to Normal mode;
-- 4. Hit `.` n-1 times, where n is the number of replacements.
nnoremap('cn', '*``cgn', { description = 'Multiple cursors' })
xnoremap(
  'cn',
  [[g:mc . "``cgn"]],
  { expr = true, description = 'Multiple cursors' }
)

nnoremap('cN', '*``cgN', { description = 'Multiple cursors (backwards)' })
xnoremap(
  'cN',
  [[g:mc . "``cgN"]],
  { expr = true, description = 'Multiple cursors (backwards)' }
)

-- 1. Position the cursor over a word; alternatively, make a selection.
-- 2. Hit cq to start recording the macro.
-- 3. Once you are done with the macro, go back to normal mode.
-- 4. Hit Enter to repeat the macro over search matches.
nnoremap(
  'cq',
  [[:lua tap.mappings.setup_mc()<CR>*``qz]],
  { description = 'Multiple cursors: Macros' }
)
xnoremap(
  'cq',
  [[":\<C-u>lua tap.mappings.setup_mc()\<CR>gv" . g:mc . "``qz"]],
  { expr = true, description = 'Multiple cursors: Macros' }
)

nnoremap(
  'cQ',
  [[:lua tap.mappings.setup_mc()<CR>#``qz]],
  { description = 'Multiple cursors: Macros (backwards)' }
)
xnoremap(
  'cQ',
  [[":\<C-u>lua tap.mappings.setup_CR()\<CR>gv" . substitute(g:mc, '/', '?', 'g') . "``qz"]],
  { expr = true, description = 'Multiple cursors: Macros (backwards)' }
)

-- Functions for multiple cursors
vim.g.mc = termcodes [[y/\V<C-r>=escape(@", '/')<CR><CR>]]

function tap.mappings.setup_mc()
  nmap(
    '<Enter>',
    [[:nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z]]
  )
end

-- Movement
-- Automatically save movements larger than 5 lines to the jumplist
-- Use Ctrl-o/Ctrl-i to navigate backwards and forwards through the jumplist
nnoremap(
  'j',
  "v:count ? (v:count > 5 ? \"m'\" . v:count : '') . 'j' : 'gj'",
  { expr = true }
)
nnoremap(
  'k',
  "v:count ? (v:count > 5 ? \"m'\" . v:count : '') . 'k' : 'gk'",
  { expr = true }
)
