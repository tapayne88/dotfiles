local cmp = require('cmp')
local lspkind = require('lspkind')

-- Avoid showing message extra message when using completion
vim.opt.shortmess:append("c")

-- Set completeopt to have a better completion experience
vim.opt.completeopt = {"menuone", "noselect"}

cmp.setup {
    mapping = {
        ['<C-f>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<C-j>'] = cmp.mapping.select_next_item({
            behavior = cmp.SelectBehavior.Insert
        }),
        ['<C-k>'] = cmp.mapping.select_prev_item({
            behavior = cmp.SelectBehavior.Insert
        })
    },

    snippet = {
        expand = function(args) require('luasnip').lsp_expand(args.body) end
    },

    sources = {
        {name = 'nvim_lsp'}, {name = "nvim_lua"}, {name = "path"},
        {name = 'buffer'}, {name = 'luasnip'}
    },

    formatting = {format = lspkind.cmp_format()},

    experimental = {ghost_text = true}
}
