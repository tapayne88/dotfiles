local inoremap = require('tap.utils').inoremap

-- Avoid showing message extra message when using completion
vim.o.shortmess = vim.o.shortmess .. "c"

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noinsert,noselect"

inoremap("<expr> <C-j>", "pumvisible() ? '<C-n>' : '<C-j>'")
inoremap("<expr> <C-k>", "pumvisible() ? '<C-p>' : '<C-k>'")

vim.api.nvim_exec([[
let g:completion_chain_complete_list = [{'complete_items': ['lsp', 'path', 'buffers']}, {'mode': '<c-p>'}, {'mode': '<c-n>'}]
]], false)
