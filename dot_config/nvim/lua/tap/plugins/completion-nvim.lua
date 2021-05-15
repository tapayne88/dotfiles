local inoremap = require('tap.utils').inoremap
local termcodes = require('tap.utils').termcodes
local augroup = require('tap.utils').augroup

_G.completion_nvim = {}

function _G.completion_nvim.smart_pumvisible(vis_seq, not_vis_seq)
    return vim.fn.pumvisible() == 1 and termcodes(vis_seq) or
               termcodes(not_vis_seq)
end

-- Avoid showing message extra message when using completion
vim.o.shortmess = vim.o.shortmess .. "c"

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noinsert,noselect"

inoremap("<C-j>", "v:lua.completion_nvim.smart_pumvisible('<C-n>', '<C-j>')",
         {expr = true})
inoremap("<C-k>", "v:lua.completion_nvim.smart_pumvisible('<C-p>', '<C-k>')",
         {expr = true})

local function on_attach()
    -- ignore empty filetype buffers (telescope, etc.)
    if vim.bo.filetype ~= "" then
        require'completion'.on_attach {
            auto_change_source = 1,

            chain_complete_list = {
                {complete_items = {'lsp'}},
                {complete_items = {'ts', 'buffers', 'path'}}, {mode = '<c-p>'},
                {mode = '<c-n>'}
            }
        }
    end
end

augroup("CompletionNvim",
        {{events = {"BufEnter"}, targets = {"*"}, command = on_attach}})
