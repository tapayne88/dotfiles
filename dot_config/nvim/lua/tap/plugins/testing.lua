return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',

      -- Adapters
      'marilari88/neotest-vitest',
    },
    lazy = true,
    init = function()
      vim.keymap.set('n', 't<C-n>', '<cmd>lua require("neotest").run.run()<cr>', { desc = '[neotest] Test nearest' })
      vim.keymap.set(
        'n',
        't<C-d>',
        '<cmd>lua require("neotest").run.run({ strategy = "dap" })<cr>',
        { desc = '[neotest] Debug nearest' }
      )
      vim.keymap.set(
        'n',
        't<C-f>',
        '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<cr>',
        { desc = '[neotest] Test file' }
      )
      vim.keymap.set('n', 't<C-a>', '<cmd>lua require("neotest").run.attach()<cr>', { desc = '[neotest] Test attach' })
      vim.keymap.set(
        'n',
        't<C-o>',
        '<cmd>lua require("neotest").output_panel.toggle()<cr>',
        { desc = '[neotest] Output panel' }
      )
      vim.keymap.set(
        'n',
        't<C-o>',
        '<cmd>lua require("neotest").output_panel.toggle()<cr>',
        { desc = '[neotest] Output panel' }
      )

      vim.keymap.set('n', '[n', '<cmd>lua require("neotest").jump.prev({ status = "failed" })<CR>', { silent = true })
      vim.keymap.set('n', ']n', '<cmd>lua require("neotest").jump.next({ status = "failed" })<CR>', { silent = true })
    end,
    config = function()
      require('neotest').setup {
        adapters = {
          require 'neotest-vitest' {
            cwd = function(testFilePath)
              return vim.fs.root(testFilePath, 'node_modules')
            end,
            filter_dir = function(name)
              return name ~= 'node_modules'
            end,
          },
        },
      }
    end,
  },
}
