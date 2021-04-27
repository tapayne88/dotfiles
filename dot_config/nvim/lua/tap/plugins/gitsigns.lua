local nnoremap = require('tap.utils').nnoremap
local highlight = require('tap.utils').highlight

require('gitsigns').setup()

nnoremap("gh", "<cmd>lua require('gitsigns').next_hunk()<CR>")
nnoremap("gH", "<cmd>lua require('gitsigns').prev_hunk()<CR>")

highlight("DiffAdd", {guibg = "NONE", guifg = "#A3BE8C"})
highlight("DiffChange", {guibg = "NONE", guifg = "#EBCB8B"})
highlight("DiffDelete", {guibg = "NONE", guifg = "#BF616A"})
