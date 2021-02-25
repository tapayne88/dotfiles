local actions = require('telescope.actions')
require('telescope').setup{
  defaults = {
    prompt_prefix = "❯",
    use_less = false,
    mappings = {
      i = {
        ["<c-s>"] = actions.select_horizontal,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
      }
    }
  }
}
