local cmp = require('cmp')
local lspkind = require('lspkind')
local highlight = require('tap.utils').highlight
local apply_user_highlights = require"tap.utils".apply_user_highlights

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

    formatting = {
        format = lspkind.cmp_format({
            with_text = true,
            menu = {
                nvim_lsp = "[LSP]",
                nvim_lua = "[api]",
                path = "[path]",
                buffer = "[buf]",
                luasnip = "[snip]"
            }
        })
    },

    experimental = {ghost_text = true}
}

apply_user_highlights("NvimCmp", function()
    highlight("CmpItemAbbrDeprecated", {link = "Error", force = true})
    highlight("CmpItemKind", {link = "Special", force = true})
    highlight("CmpItemMenu", {link = "Comment", force = true})
end)


