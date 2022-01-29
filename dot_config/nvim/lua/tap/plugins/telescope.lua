local actions = require('telescope.actions')
local nnoremap = require('tap.utils').nnoremap
local highlight = require('tap.utils').highlight
local color = require('tap.utils').color
local augroup = require("tap.utils").augroup
local command = require("tap.utils").command

require('telescope').setup {
    defaults = {
        prompt_prefix = "❯ ",
        layout_strategy = "flex", -- let telescope figure out what to do given the space
        layout_config = {height = {padding = 10}},
        mappings = {
            i = {
                ["<c-s>"] = actions.select_horizontal,
                ["<C-k>"] = actions.move_selection_previous,
                ["<C-j>"] = actions.move_selection_next
            }
        },
        borderchars = {
            prompt = {'█', '▌', '▀', '▐', '▐', '▌', '▘', '▝'},
            results = {"─", "│", "─", "│", '┌', '┐', "┘", "└"},
            preview = {'─', '│', '─', '│', '┌', '┐', '┘', '└'}
        },
        path_display = {"truncate"}
    }
}

require("telescope").load_extension "file_browser"

nnoremap("<leader>ts", ":Telescope<CR>", {name = "Give me Telescope!"})
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
    require('telescope').extensions.file_browser.file_browser {
        cwd = vim.fn.expand('%:p:h'),
        hidden = true
    }
end, {name = "Relative File Browser"})
nnoremap("<leader>fB", function()
    require('telescope').extensions.file_browser.file_browser {hidden = true}
end, {name = "CWD File Browser"})
nnoremap("<leader>fh", function()
    require('telescope').extensions.file_browser.file_browser {
        cwd = '~',
        hidden = true
    }
end, {name = "Home Files"})
nnoremap("<leader>gh", function() require('telescope.builtin').help_tags() end,
         {name = "Help Tags"})
nnoremap("<leader>fg", function()
    require("telescope").extensions.live_grep_raw.live_grep_raw()
end, {name = "Live Grep"})
nnoremap("<leader>fG", function() require('telescope.builtin').live_grep() end,
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
    local border_colors = {dark = "nord2_gui", light = "blue0"}

    highlight("TelescopeBorder", {guifg = color(border_colors)})
    highlight("TelescopePromptBorder", {
        guifg = color(border_colors),
        guibg = color({dark = "nord0_gui", light = "none"})
    })
    highlight("TelescopePreviewBorder", {guifg = color(border_colors)})
    highlight("TelescopeResultsBorder", {guifg = color(border_colors)})

    highlight("TelescopePromptTitle", {
        guifg = color({dark = "nord2_gui", light = "bg"}),
        guibg = color({dark = "nord11_gui", light = "red"})
    })
    highlight("TelescopePromptNormal", {
        guifg = color({dark = "nord4_gui", light = "fg"}),
        guibg = color(border_colors)
    })
    highlight("TelescopePromptCounter", {
        guifg = color({dark = "nord5_gui", light = "fg"}),
        guibg = color(border_colors)
    })

    highlight("TelescopePreviewTitle", {
        guifg = color({dark = "nord2_gui", light = "bg"}),
        guibg = color({dark = "nord14_gui", light = "green"})
    })
    highlight("TelescopeResultsTitle", {
        guifg = color({dark = "nord4_gui", light = "fg"}),
        guibg = color({dark = "nord3_gui", light = "blue0"})
    })

    highlight("TelescopeMatching",
              {guifg = color({dark = "nord13_gui", light = "yellow"})})
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
    function(args)
        local word = table.remove(args, 1)
        local search_dirs = args

        local search_args = #search_dirs > 0 and {search_dirs = search_dirs} or
                                {}

        require('telescope.builtin').grep_string(
            vim.tbl_extend("error", search_args, {
                search = word,
                prompt_title = string.format("Grep: %s", word),
                use_regex = true
            }))
    end,
    nargs = "+",
    extra = "-complete=dir"
})

apply_user_highlights()
