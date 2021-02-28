local actions = require('telescope.actions')
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
