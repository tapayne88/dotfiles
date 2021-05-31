local nnoremap = require('tap.utils').nnoremap
local highlight = require('tap.utils').highlight
local color = require("tap.utils").color

require('gitsigns').setup()

nnoremap("gh", "<cmd>lua require('gitsigns').next_hunk()<CR>")
nnoremap("gH", "<cmd>lua require('gitsigns').prev_hunk()<CR>")

highlight("DiffAdd", {guibg = "NONE", guifg = color("green")})
highlight("DiffChange", {guibg = "NONE", guifg = color("yellow")})
highlight("DiffDelete", {guibg = "NONE", guifg = color("red")})
