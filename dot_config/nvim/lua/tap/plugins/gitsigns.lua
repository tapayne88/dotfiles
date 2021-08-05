local nnoremap = require('tap.utils').nnoremap
local highlight = require('tap.utils').highlight
local color = require("tap.utils").color
local augroup = require("tap.utils").augroup

require('gitsigns').setup {
    keymaps = {
        -- Default keymap options
        noremap = true,

        ['n [h'] = '<cmd>lua require"gitsigns.actions".prev_hunk()<CR>',
        ['n ]h'] = '<cmd>lua require"gitsigns.actions".next_hunk()<CR>',

        ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
        ['v <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
        ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
        ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
        ['v <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
        ['n <leader>hR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
        ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
        ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',

        -- Text objects
        ['o ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
        ['x ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>'
    }
}

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
