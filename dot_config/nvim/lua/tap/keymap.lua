local termcodes = require('tap.utils').termcodes

vim.keymap.set('n', 'j', 'gj', { desc = 'Jump down one wrapped line' })
vim.keymap.set('n', 'k', 'gk', { desc = 'Jump up one wrapped line' })

vim.keymap.set('v', '<', '<gv', { desc = 'Shift selected text left' })
vim.keymap.set('v', '>', '>gv', { desc = 'Shift selected text right' })

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selected text down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selected text up' })

vim.keymap.set('v', '//', "y/\\V<C-R>=escape(@\",'/')<CR><CR>", { desc = 'Search for current visual selection' })

-- stylua: ignore start
vim.keymap.set('n', '<c-q>',          ':copen<CR>', { desc = 'Open quickfix list' })
vim.keymap.set('n', '<LocalLeader>q', ':lopen<CR>', { desc = 'Open local list' })
-- stylua: ignore end

vim.keymap.set(
  'n',
  '<leader>fp',
  ':echo @% | let @*=expand("%")<CR>',
  { desc = 'Print and copy to system clipboard the filepath' }
)
vim.keymap.set(
  'v',
  '<leader>fp',
  ':<C-U>echo fnamemodify(expand("%"), ":~:.") . ":" . line(".") | let @*=fnamemodify(expand("%"), ":~:.") . ":" . line(".")<CR>',
  {
    desc = 'Print and copy to system clipboard filepath with line number',
  }
)
vim.keymap.set('n', '<leader>cm', ':!chezmoi apply -v<CR>', { desc = 'Apply chezmoi changes' })

-- stylua: ignore start
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]],  { desc = 'Escape terminal insert mode with <Esc>' })
vim.keymap.set('t', '<A-[>', '<Esc>',         { desc = 'Alternate mapping to send esc to terminal' })
-- stylua: ignore end

-- Multiple Cursors
-- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
-- https://github.com/akinsho/dotfiles/blob/45c4c17084d0aa572e52cc177ac5b9d6db1585ae/.config/nvim/plugin/mappings.lua#L298

-- 1. Position the cursor anywhere in the word you wish to change;
-- 2. Or, visually make a selection;
-- 3. Hit cn, type the new word, then go back to Normal mode;
-- 4. Hit `.` n-1 times, where n is the number of replacements.
-- stylua: ignore start
vim.keymap.set('n', 'cn', '*``cgn',           { desc = 'Multiple cursors' })
vim.keymap.set('x', 'cn', [[g:mc . "``cgn"]], { expr = true, desc = 'Multiple cursors' })
vim.keymap.set('n', 'cN', '*``cgN',           { desc = 'Multiple cursors (backwards)' })
vim.keymap.set('x', 'cN', [[g:mc . "``cgN"]], { expr = true, desc = 'Multiple cursors (backwards)' })
-- stylua: ignore end

-- 1. Position the cursor over a word; alternatively, make a selection.
-- 2. Hit cq to start recording the macro.
-- 3. Once you are done with the macro, go back to normal mode.
-- 4. Hit Enter to repeat the macro over search matches.
-- stylua: ignore start
vim.keymap.set('n', 'cq', [[:lua tap.mappings.setup_mc()<CR>*``qz]],                        { desc = 'Multiple cursors: Macros' })
vim.keymap.set('x', 'cq', [[":\<C-u>lua tap.mappings.setup_mc()\<CR>gv" . g:mc . "``qz"]],  { expr = true, desc = 'Multiple cursors: Macros' })
-- stylua: ignore end

vim.keymap.set('n', 'cQ', [[:lua tap.mappings.setup_mc()<CR>#``qz]], { desc = 'Multiple cursors: Macros (backwards)' })
vim.keymap.set(
  'x',
  'cQ',
  [[":\<C-u>lua tap.mappings.setup_CR()\<CR>gv" . substitute(g:mc, '/', '?', 'g') . "``qz"]],
  { expr = true, desc = 'Multiple cursors: Macros (backwards)' }
)

-- Functions for multiple cursors
vim.g.mc = termcodes [[y/\V<C-r>=escape(@", '/')<CR><CR>]]

function tap.mappings.setup_mc()
  vim.keymap.set(
    'n',
    '<Enter>',
    [[:nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z]],
    { remap = true }
  )
end

-- Movement
-- Automatically save movements larger than 5 lines to the jumplist
-- Use Ctrl-o/Ctrl-i to navigate backwards and forwards through the jumplist
vim.keymap.set('n', 'j', "v:count ? (v:count > 5 ? \"m'\" . v:count : '') . 'j' : 'gj'", { expr = true })
vim.keymap.set('n', 'k', "v:count ? (v:count > 5 ? \"m'\" . v:count : '') . 'k' : 'gk'", { expr = true })

vim.keymap.set('v', '<leader>p', [["_dP]], { desc = 'Keep the yanked text when pasting in visual mode' })
