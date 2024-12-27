return {
  'hrsh7th/nvim-cmp',
  opts = function(_, opts)
    local cmp = require 'cmp'

    opts.completion.completeopt = 'menuone,noselect'
    opts.preselect = cmp.PreselectMode.None
    opts.mapping = vim.tbl_extend('force', opts.mapping, {
      ['<C-u>'] = cmp.mapping.scroll_docs(-4),
      ['<C-d>'] = cmp.mapping.scroll_docs(4),
    })
  end,
}
