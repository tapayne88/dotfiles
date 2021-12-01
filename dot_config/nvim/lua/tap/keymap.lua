local nnoremap = require("tap.utils").nnoremap
local vnoremap = require("tap.utils").vnoremap
local tnoremap = require("tap.utils").tnoremap

-- Makes up/down on line wrapped lines work better (more intuitive)
nnoremap('j', 'gj')
nnoremap('k', 'gk')

-- Keep text selected after indentation
vnoremap('<', '<gv')
vnoremap('>', '>gv')

-- search for current visual selection
vnoremap('//', "y/\\V<C-R>=escape(@\",'/\')<CR><CR>")

-- quickfix mappings
nnoremap('<c-q>', ":copen<CR>")
nnoremap('<LocalLeader>q', ":lopen<CR>")

nnoremap('<leader>fp', ":echo @%<CR>")
nnoremap('<leader>cm', ":!chezmoi apply -v<CR>")
nnoremap('<leader>ex', ":Ex<CR>")

-- vimrc sourcing
nnoremap('<leader>evv', ":vsplit " .. vim.g.chezmoi_source_dir ..
             "/dot_config/nvim/init.lua<CR>")
nnoremap('<leader>ev', ":split " .. vim.g.chezmoi_source_dir ..
             "/dot_config/nvim/init.lua<CR>")
nnoremap('<leader>sv', ":luafile $MYVIMRC<CR>:echom 'Reloaded '. $MYVIMRC<CR>")

-- Esc (C-[) to escape terminal insert mode
tnoremap('<Esc>', [[<C-\><C-n>]])
tnoremap('<A-[>', '<Esc>')
