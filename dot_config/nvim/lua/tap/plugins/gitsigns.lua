local nnoremap = require('tap.utils').nnoremap
local highlight = require('tap.utils').highlight
local color = require("tap.utils").color
local augroup = require("tap.utils").augroup

require('gitsigns').setup()

nnoremap("gh", "<cmd>lua require('gitsigns').next_hunk()<CR>")
nnoremap("gH", "<cmd>lua require('gitsigns').prev_hunk()<CR>")

local function apply_user_highlights()
    highlight("DiffAdd", {guibg = "NONE", guifg = color("green")})
    highlight("DiffChange", {guibg = "NONE", guifg = color("yellow")})
    highlight("DiffDelete", {guibg = "NONE", guifg = color("red")})
end

augroup("GitSignsHighlights", {
    {
        events = {"VimEnter", "ColorScheme"},
        targets = {"*"},
        command = apply_user_highlights
    }
})

apply_user_highlights()
