local nnoremap = require("tap.utils").nnoremap

vim.cmd 'let g:fugitive_dynamic_colors = 0'

-- Stops fugitive files being left in buffer by removing all but currently visible
vim.cmd 'autocmd BufReadPost fugitive://* set bufhidden=delete'

nnoremap('<leader>ga', ':Git add %:p<CR><CR>')
nnoremap('<leader>gs', ':Gstatus<CR>')
nnoremap('<leader>gc', ':Git commit -v -q<CR>')
nnoremap('<leader>gt', ':Git commit -v -q %:p<CR>')
nnoremap('<leader>gd', ':Gvdiff<CR>')
nnoremap('<leader>ge', ':Gedit<CR>')
nnoremap('<leader>gr', ':Gread<CR>')
nnoremap('<leader>gw', ':Gwrite<CR><CR>')
nnoremap('<leader>gl', ':silent! Glog<CR>:bot copen<CR>')
nnoremap('<leader>gm', ':GitMessenger<CR>')
nnoremap('<leader>gb', ':Git branch<Space>')
nnoremap('<leader>go', ':Git checkout<Space>')
nnoremap('<leader>gps', ':Dispatch! git push<CR>')
nnoremap('<leader>gpl', ':Dispatch! git pull<CR>')