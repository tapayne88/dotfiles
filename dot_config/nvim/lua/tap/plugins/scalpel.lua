local nnoremap = require("tap.utils").nnoremap

vim.cmd "let g:ScalpelCommand = 'S'"
nnoremap('<leader>e', '<Plug>(Scalpel)')
