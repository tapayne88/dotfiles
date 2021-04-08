local inoremap = require('tap.utils').inoremap
local termcodes = require('tap.utils').termcodes

_G.completion_nvim = {}

function _G.completion_nvim.smart_pumvisible(vis_seq, not_vis_seq)
  return vim.fn.pumvisible() == 1 and termcodes(vis_seq) or termcodes(not_vis_seq)
end

-- Avoid showing message extra message when using completion
vim.o.shortmess = vim.o.shortmess .. "c"

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noinsert,noselect"

inoremap("<C-j>", "v:lua.completion_nvim.smart_pumvisible('<C-n>', '<C-j>')", {expr = true})
inoremap("<C-k>", "v:lua.completion_nvim.smart_pumvisible('<C-p>', '<C-k>')", {expr = true})

-- function _G.smart_tab()
--     return vim.fn.pumvisible() == 1 and t'<C-n>' or t'<Tab>'
-- end

-- vim.api.nvim_set_keymap('i', '<Tab>', 'v:lua.smart_tab()', {expr = true, noremap = true})

vim.api.nvim_exec([==[
let g:completion_auto_change_source = 1

let g:completion_chain_complete_list = [{'complete_items': ['lsp']}, {'complete_items': ['ts', 'buffers', 'path']}, {'mode': '<c-p>'}, {'mode': '<c-n>'}]

autocmd BufEnter * lua require'completion'.on_attach()
]==], false)
