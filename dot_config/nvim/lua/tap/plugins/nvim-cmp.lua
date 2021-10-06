local cmp = require('cmp')
local lspkind = require('lspkind')
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

cmp.setup {
    mapping = {
        ['<C-f>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm({select = true})
    },

    snippet = {
        expand = function(args) require('luasnip').lsp_expand(args.body) end
    },

    sources = {{name = 'nvim_lsp'}, {name = 'buffer'}, {name = 'luasnip'}},

    formatting = {format = lspkind.cmp_format()}
}
