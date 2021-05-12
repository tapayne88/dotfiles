local nnoremap = require('tap.utils').nnoremap
local highlight = require('tap.utils').highlight
local nord_colors = require("tap.utils").nord_colors

require('gitsigns').setup()

nnoremap("gh", "<cmd>lua require('gitsigns').next_hunk()<CR>")
nnoremap("gH", "<cmd>lua require('gitsigns').prev_hunk()<CR>")

highlight("DiffAdd", {guibg = "NONE", guifg = nord_colors.nord14})
highlight("DiffChange", {guibg = "NONE", guifg = nord_colors.nord13})
highlight("DiffDelete", {guibg = "NONE", guifg = nord_colors.nord11})
