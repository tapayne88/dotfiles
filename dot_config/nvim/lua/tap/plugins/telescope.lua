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
end, {name = "List buffers"})
nnoremap("<leader>gf", function()
    require('telescope.builtin').git_files {use_git_root = false}
end, {name = "Relative git file"})
nnoremap("<leader>gF", function() require('telescope.builtin').git_files() end,
         {name = "All git files"})
nnoremap("<leader>ff", function()
    require('telescope.builtin').find_files {hidden = true}
end, {name = "Find File"})
nnoremap("<leader>fb", function()
    require('telescope.builtin').file_browser {
        cwd = vim.fn.expand('%:p:h'),
        hidden = true
    }
end, {name = "Relative File Browser"})
nnoremap("<leader>fB", function()
    require('telescope.builtin').file_browser {hidden = true}
end, {name = "CWD File Browser"})
nnoremap("<leader>fh", function()
    require('telescope.builtin').file_browser {cwd = '~', hidden = true}
end, {name = "Home Files"})
nnoremap("<leader>fg", function() require('telescope.builtin').live_grep() end,
         {name = "Live Grep"})
nnoremap("<leader>fw",
         function() require('telescope.builtin').grep_string() end,
         {name = "Find Word"})
nnoremap("<leader>ch",
         function() require('telescope.builtin').command_history() end,
         {name = "Command History"})

highlight("TelescopeBorder", {guifg = nord_colors.nord3})
highlight("TelescopePromptBorder", {guifg = nord_colors.nord10})
highlight("TelescopeMatching", {guifg = nord_colors.nord13})
