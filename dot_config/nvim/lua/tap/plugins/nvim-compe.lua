local inoremap = require('tap.utils').inoremap
local termcodes = require('tap.utils').termcodes
local augroup = require('tap.utils').augroup

-- Avoid showing message extra message when using completion
vim.o.shortmess = vim.o.shortmess .. "c"

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

_G.completion_nvim = {}

function _G.completion_nvim.smart_pumvisible(vis_seq, not_vis_seq)
    return vim.fn.pumvisible() == 1 and termcodes(vis_seq) or
               termcodes(not_vis_seq)
end

inoremap("<C-j>", "v:lua.completion_nvim.smart_pumvisible('<C-n>', '<C-j>')",
         {expr = true})
inoremap("<C-k>", "v:lua.completion_nvim.smart_pumvisible('<C-p>', '<C-k>')",
         {expr = true})

require'compe'.setup {
    source = {
        path = {kind = "   (Path)"},
        buffer = {kind = "   (Buffer)"},
        calc = {kind = "   (Calc)"},
        vsnip = {kind = "   (Snippet)"},
        nvim_lsp = {kind = "   (LSP)"},
        nvim_lua = {kind = "  "},
        spell = {kind = "   (Spell)"},
        tags = false,
        -- snippets_nvim = {kind = "  "},
        -- ultisnips = {kind = "  "},
        -- treesitter = {kind = "  "},
        emoji = {kind = " ﲃ  (Emoji)", filetypes = {"markdown", "text"}}
    }
}
