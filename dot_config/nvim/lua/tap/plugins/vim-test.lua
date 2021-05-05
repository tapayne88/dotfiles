local nnoremap = require("tap.utils").nnoremap

vim.cmd [[
let g:test#runner_commands = ['Jest']
let g:test#strategy = "neovim"
let test#neovim#term_position = "vert botright"
]]

-- Below needed for tests inside spec folder
vim.cmd [[
let g:test#javascript#jest#file_pattern = '\v((__tests__|spec)/.*|(spec|test))\.(js|jsx|coffee|ts|tsx)$'
let g:test#javascript#jest#executable = "yarn jest --watch"
]]

nnoremap('t<C-n>', ':TestNearest<CR>')
nnoremap('t<C-f>', ':TestFile<CR>')
nnoremap('t<C-w>', ':Jest --watch<CR>')
