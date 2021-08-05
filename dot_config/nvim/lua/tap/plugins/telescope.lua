local actions = require('telescope.actions')
local nnoremap = require('tap.utils').nnoremap
local highlight = require('tap.utils').highlight
local color = require('tap.utils').color
local augroup = require("tap.utils").augroup
local command = require("tap.utils").command

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
        sort_mru = true,
        show_all_buffers = true,
        selection_strategy = "closest"
    }
end, {name = "List buffers"})
nnoremap("<leader>gf", function()
    require('telescope.builtin').git_files {use_git_root = false}
end, {name = "Relative git file"})
nnoremap("<leader>gF", function() require('telescope.builtin').git_files() end,
         {name = "All git files"})
nnoremap("<leader>rf", function()
    require('telescope.builtin').git_files {
        use_git_root = false,
        cwd = vim.fn.expand('%:p:h')
    }
end, {name = "Git files relative to current file"})
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
nnoremap("<leader>gh", function() require('telescope.builtin').help_tags() end,
         {name = "Help Tags"})
nnoremap("<leader>fg", function() require('telescope.builtin').live_grep() end,
         {name = "Live Grep"})
nnoremap("<leader>fw", function()
    require('telescope.builtin').grep_string {
        prompt_title = "Grep: " .. vim.fn.expand("<cword>")
    }
end, {name = "Find Word"})
nnoremap("<leader>ch",
         function() require('telescope.builtin').command_history() end,
         {name = "Command History"})

local function apply_user_highlights()
    highlight("TelescopeBorder", {guifg = color("dark3")})
    highlight("TelescopePromptBorder", {guifg = color("blue3")})
    highlight("TelescopeMatching", {guifg = color("yellow")})
end

augroup("TelescopeHighlights", {
    {
        events = {"VimEnter", "ColorScheme"},
        targets = {"*"},
        command = apply_user_highlights
    }
})

command({
    "Fw",
    function(word, ...)
        local search_dirs = {...}
        local args = #search_dirs > 0 and {search_dirs = search_dirs} or {}

        args.search = word
        args.prompt_title = string.format("Grep: %s", word)

        require('telescope.builtin').grep_string(args)
    end,
    nargs = "+",
    extra = "-complete=dir"
})

apply_user_highlights()
