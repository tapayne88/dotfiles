local actions = require('telescope.actions')
local nnoremap = require('tap.utils').nnoremap
local highlight = require('tap.utils').highlight
local nord_colors = require('tap.utils').nord_colors

require('telescope').setup {
    defaults = {
        prompt_prefix = "❯ ", -- this currently causes a neovim bug (see https://github.com/nvim-telescope/telescope.nvim/issues/567)
        layout_strategy = "flex", -- let telescope figure out what to do given the space
        mappings = {
            i = {
                ["<c-s>"] = actions.select_horizontal,
                ["<C-k>"] = actions.move_selection_previous,
                ["<C-j>"] = actions.move_selection_next
            }
        }
    }
}

nnoremap("<leader>l", function()
    require('telescope.builtin').buffers {
        sort_lastused = true,
        show_all_buffers = true,
        selection_strategy = "closest"
    }
end)
nnoremap("<leader>gf", function()
    require('telescope.builtin').git_files {use_git_root = false}
end)
nnoremap("<leader>gF", function() require('telescope.builtin').git_files() end)
nnoremap("<leader>ff",
         function() require('telescope.builtin').find_files {hidden = true} end)
nnoremap("<leader>fb", function()
    require('telescope.builtin').file_browser {
        cwd = vim.fn.expand('%:p:h'),
        hidden = true
    }
end)
nnoremap("<leader>fB", function()
    require('telescope.builtin').file_browser {hidden = true}
end)
nnoremap("<leader>fh", function()
    require('telescope.builtin').file_browser {cwd = '~', hidden = true}
end)
nnoremap("<leader>fg", function() require('telescope.builtin').live_grep() end)
nnoremap("<leader>fw", function() require('telescope.builtin').grep_string() end)
nnoremap("<leader>ch",
         function() require('telescope.builtin').command_history() end)

highlight("TelescopeBorder", {guifg = nord_colors.nord3})
highlight("TelescopePromptBorder", {guifg = nord_colors.nord10})
highlight("TelescopeMatching", {guifg = nord_colors.nord13})
