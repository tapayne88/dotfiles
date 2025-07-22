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
      -- stylua: ignore start
      vim.keymap.set('n', 't<C-n>', function() require('neotest').run.run() end,                    { desc = '[neotest] Test nearest' })
      vim.keymap.set('n', 't<C-d>', function() require('neotest').run.run { strategy = 'dap' } end, { desc = '[neotest] Debug nearest' })
      vim.keymap.set('n', 't<C-f>', function() require('neotest').run.run(vim.fn.expand '%') end,   { desc = '[neotest] Test file' })
      vim.keymap.set('n', 't<C-a>', function() require("neotest").run.attach() end,                 { desc = '[neotest] Test attach' })
      vim.keymap.set('n', 't<C-o>', function() require("neotest").output_panel.toggle() end,        { desc = '[neotest] Output panel' })
      -- stylua: ignore end

      vim.keymap.set('n', '[n', '<cmd>lua require("neotest").jump.prev({ status = "failed" })<CR>', { silent = true })
      vim.keymap.set('n', ']n', '<cmd>lua require("neotest").jump.next({ status = "failed" })<CR>', { silent = true })
    end,
    config = function()
      require('neotest').setup {
        status = { virtual_text = true },
        output = { open_on_run = true },
        quickfix = {
          open = function()
            require('trouble').open { mode = 'quickfix', focus = false }
          end,
        },
        consumers = {
          -- Update trouble quickfix on test result
          trouble = function(client)
            client.listeners.results = function(adapter_id, results, partial)
              if partial then
                return
              end
              local tree = assert(client:get_position(nil, { adapter = adapter_id }))

              local failed = 0
              for pos_id, result in pairs(results) do
                if result.status == 'failed' and tree:get_key(pos_id) then
                  failed = failed + 1
                end
              end
              vim.schedule(function()
                local trouble = require 'trouble'
                if trouble.is_open() then
                  trouble.refresh()
                  if failed == 0 then
                    trouble.close()
                  end
                end
              end)
              return {}
            end
          end,
        },
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
