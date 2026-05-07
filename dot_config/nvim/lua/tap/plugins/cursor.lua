return {
  {
    dir = vim.fn.stdpath 'config',
    name = 'tap-cursor',
    lazy = false,
    opts = {},
    dependencies = {
      {
        -- `snacks.nvim` integration is recommended, but optional
        ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
        'folke/snacks.nvim',
        optional = true,
        opts = {
          input = {}, -- Enhances `ask()`
        },
      },
    },
    keys = {
      -- stylua: ignore start
      { '<leader>oa', '<cmd>CursorSend<CR>',        mode = 'n', desc = 'Ask Cursor about buffer' },
      { '<leader>oa', ":<C-u>'<,'>CursorSend<CR>",  mode = 'x', desc = 'Ask Cursor about selection' },
      { '<leader>oc', '<cmd>CursorMode<CR>',                    desc = 'Cycle Cursor mode' },
      -- stylua: ignore end
    },
    config = function(_, opts)
      require('tap.cursor').setup(opts)
    end,
  },
}
