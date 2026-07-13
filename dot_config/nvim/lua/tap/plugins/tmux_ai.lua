return {
  {
    dir = vim.fn.stdpath 'config',
    name = 'tap-tmux-ai',
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
      { '<leader>oa', '<cmd>TmuxAISend<CR>',        mode = 'n', desc = 'Ask TmuxAI about buffer' },
      { '<leader>oa', ":<C-u>'<,'>TmuxAISend<CR>",  mode = 'x', desc = 'Ask TmuxAI about selection' },
      { '<leader>oc', '<cmd>TmuxAIMode<CR>',                    desc = 'Cycle TmuxAI mode' },
      -- stylua: ignore end
    },
    config = function(_, opts)
      require('tap.tmux_ai').setup(opts)
    end,
  },
}
