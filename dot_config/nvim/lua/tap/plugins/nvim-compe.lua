local inoremap = require('tap.utils').inoremap
local termcodes = require('tap.utils').termcodes

-- Avoid showing message extra message when using completion
vim.opt.shortmess:append("c")

-- Set completeopt to have a better completion experience
vim.opt.completeopt = {"menuone", "noselect"}

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
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 1,
    preselect = 'enable',
    throttle_time = 80,
    source_timeout = 200,
    incomplete_delay = 400,
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = true,

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
        treesitter = {kind = "  "},
        emoji = {kind = " ﲃ  (Emoji)", filetypes = {"markdown", "text"}}
    }
}
