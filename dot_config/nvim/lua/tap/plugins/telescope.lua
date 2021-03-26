local actions = require('telescope.actions')
local nnoremap = require('tap.utils').nnoremap
local highlight = require('tap.utils').highlight

require('telescope').setup{
  defaults = {
    -- prompt_prefix = "❯", -- this currently causes a neovim bug (see https://github.com/nvim-telescope/telescope.nvim/issues/567)
    prompt_prefix = "", -- can't use above and default cause bug too
    use_less = false,
    layout_strategy = "flex", -- let telescope figure out what to do given the space
    mappings = {
      i = {
        ["<c-s>"] = actions.select_horizontal,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
      }
    }
  }
}

nnoremap("<leader>l",   "<cmd>lua require('telescope.builtin').buffers{ sort_lastused = true }<cr>")
nnoremap("<leader>gf",  "<cmd>lua require('telescope.builtin').git_files{ use_git_root = false }<cr>")
nnoremap("<leader>gF",  "<cmd>lua require('telescope.builtin').git_files()<cr>")
nnoremap("<leader>ff",  "<cmd>lua require('telescope.builtin').find_files()<cr>")
nnoremap("<leader>fb",  "<cmd>lua require('telescope.builtin').file_browser{ cwd = vim.fn.expand('%:p:h') }<cr>")
nnoremap("<leader>fB",  "<cmd>lua require('telescope.builtin').file_browser()<cr>")
nnoremap("<leader>fh",  "<cmd>lua require('telescope.builtin').file_browser{ cwd = '~', hidden = true }<cr>")
nnoremap("<leader>fg",  "<cmd>lua require('telescope.builtin').live_grep()<cr>")
nnoremap("<leader>fw",  "<cmd>lua require('telescope.builtin').grep_string()<cr>")
nnoremap("<leader>ch",  "<cmd>lua require('telescope.builtin').command_history()<cr>")

highlight("TelescopeBorder",        {guifg = "#4C566A"})
highlight("TelescopePromptBorder",  {guifg = "#5E81AC"})
highlight("TelescopeMatching",      {guifg = "#EBCB8B"})
