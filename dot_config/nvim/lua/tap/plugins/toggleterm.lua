local tmap = require("tap.utils").tmap

require("toggleterm").setup {
    open_mapping = [[<leader>tt]],
    shade_terminals = false
}

-- Utilise tmux.nvim's bindings for changing windows
tmap('<C-h>', [[<C-\><C-n><C-h>]])
tmap('<C-j>', [[<C-\><C-n><C-j>]])
tmap('<C-k>', [[<C-\><C-n><C-k>]])
tmap('<C-l>', [[<C-\><C-n><C-l>]])