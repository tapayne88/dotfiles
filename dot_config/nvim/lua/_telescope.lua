local actions = require('telescope.actions')
require('telescope').setup{
  defaults = {
    prompt_prefix = "❯",
    use_less = false,
    mappings = {
      i = {
        ["<c-s>"] = actions.goto_file_selection_split,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
      }
    }
  }
}
