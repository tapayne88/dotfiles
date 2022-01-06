local nnoremap = require("tap.utils").nnoremap
local xnoremap = require("tap.utils").xnoremap

vim.g.fugitive_dynamic_colors = 0
vim.g.github_enterprise_urls = {'https://github.anaplan.com'}

-- Stops fugitive files being left in buffer by removing all but currently visible
vim.cmd 'autocmd BufReadPost fugitive://* set bufhidden=delete'

nnoremap('<leader>ga', ':Git add %:p<CR><CR>')
nnoremap('<leader>gs', ':Git<CR>')
nnoremap('<leader>gc', ':Git commit -v -q<CR>')
nnoremap('<leader>gt', ':Git commit -v -q %:p<CR>')
nnoremap('<leader>gd', ':Gvdiff<CR>')
nnoremap('<leader>ge', ':Gedit<CR>')
nnoremap('<leader>gr', ':Gread<CR>')
nnoremap('<leader>gw', ':Gwrite<CR><CR>')
nnoremap('<leader>gl', ':silent! Glog<CR>:bot copen<CR>')
nnoremap('<leader>gb', ':Git blame<CR>')
nnoremap('<leader>go', ':Git checkout<Space>')
nnoremap('<leader>gps', ':Dispatch! git push<CR>')
nnoremap('<leader>gpl', ':Dispatch! git pull<CR>')
nnoremap('<leader>gp', ":GBrowse<CR>")
xnoremap('<leader>gp', ":'<,'>GBrowse<CR>")
