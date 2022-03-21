local nnoremap = require("tap.utils").nnoremap
local vnoremap = require("tap.utils").vnoremap
local tnoremap = require("tap.utils").tnoremap

nnoremap('j', 'gj', {description = "Jump down one wrapped line"})
nnoremap('k', 'gk', {description = "Jump up one wrapped line"})

vnoremap('<', '<gv', {description = "Shift selected text left"})
vnoremap('>', '>gv', {description = "Shift selected text right"})

vnoremap('J', ":m '>+1<CR>gv=gv", {description = "Move selected text down"})
vnoremap('K', ":m '<-2<CR>gv=gv", {description = "Move selected text up"})

vnoremap('//', "y/\\V<C-R>=escape(@\",'/\')<CR><CR>",
         {description = "Search for current visual selection"})

nnoremap('<c-q>', ":copen<CR>", {description = "Open quickfix list"})
nnoremap('<LocalLeader>q', ":lopen<CR>", {description = "Open local list"})

nnoremap('<leader>fp', ":echo @%<CR>", {description = "Print filepath"})
nnoremap('<leader>cm', ":!chezmoi apply -v<CR>",
         {description = "Apply chezmoi changes"})
nnoremap('<leader>ex', ":Ex<CR>", {description = "Open netrw"})

nnoremap('<leader>evv', ":vsplit " .. vim.g.chezmoi_source_dir ..
             "/dot_config/nvim/init.lua<CR>",
         {description = "Open nvim/init.lua in vertical split"})
nnoremap('<leader>ev', ":split " .. vim.g.chezmoi_source_dir ..
             "/dot_config/nvim/init.lua<CR>",
         {description = "Open nvim/init.lua in split"})
nnoremap('<leader>sv', ":luafile $MYVIMRC<CR>:echom 'Reloaded '. $MYVIMRC<CR>",
         {description = "Source nvim/init.lua"})

tnoremap('<Esc>', [[<C-\><C-n>]],
         {description = "Escape terminal insert mode with <Esc>"})
tnoremap('<A-[>', '<Esc>',
         {description = "Alternate mapping to send esc to terminal"})
