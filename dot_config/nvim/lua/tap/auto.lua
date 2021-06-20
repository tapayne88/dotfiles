vim.cmd [[
" Automatically resize vim splits on resize
autocmd VimResized * execute "normal! \<c-w>="

" Save and load vim views - remembers scroll position & folds
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent! loadview
]]
