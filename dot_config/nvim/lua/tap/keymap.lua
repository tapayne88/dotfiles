local nnoremap = require("tap.utils").nnoremap
local vnoremap = require("tap.utils").vnoremap
local tnoremap = require("tap.utils").tnoremap
local xnoremap = require("tap.utils").xnoremap

-- Makes up/down on line wrapped lines work better (more intuitive)
nnoremap('j', 'gj')
nnoremap('k', 'gk')

-- Keep text selected after indentation
vnoremap('<', '<gv')
vnoremap('>', '>gv')

-- search for current visual selection
vnoremap('//', "y/\\V<C-R>=escape(@\",'/\')<CR><CR>")

nnoremap('<leader>x', ":cclose<CR>")
nnoremap('<leader>h', ":set hlsearch!<CR>")
nnoremap('<leader>n', ":set number!<CR>")
nnoremap('<leader>fp', ":echo @%<CR>")
nnoremap('<leader>cm', ":!chezmoi apply -v<CR>")
-- nnoremap('<leader>ff', ":Ex<CR>") -- Replacing with Telescope file_browser (though borrowing shortcut for find_files)

-- vimrc sourcing
nnoremap('<leader>evv', ":vsplit " .. vim.g.chezmoi_source_dir ..
             "/dot_config/nvim/init.lua<CR>")
nnoremap('<leader>ev', ":split " .. vim.g.chezmoi_source_dir ..
             "/dot_config/nvim/init.lua<CR>")
nnoremap('<leader>sv', ":luafile $MYVIMRC<CR>:echom 'Reloaded '. $MYVIMRC<CR>")

-- Esc (C-[) to escape terminal insert mode
tnoremap('<Esc>', [[<C-\><C-n>]])
tnoremap('<A-[>', '<Esc>')

nnoremap('<leader>gp', ":lua require('tap.git-web-url').get_line_url()<CR>")
xnoremap('<leader>gp',
         ":<c-u>lua require('tap.git-web-url').get_block_url()<CR>")