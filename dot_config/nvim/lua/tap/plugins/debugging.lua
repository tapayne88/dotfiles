return {
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    lazy = true,
    init = function()
      require('tap.utils').command {
        'DapUi',
        function()
          require('dapui').toggle()
        end,
      }
    end,
    opts = {
      icons = {
        collapsed = '',
        current_frame = '',
        expanded = '',
      },
    },
  },

  {
    'mxsdev/nvim-dap-vscode-js',
    lazy = true,
    dependencies = {
      'microsoft/vscode-js-debug',
      build = 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out',
    },
    config = function()
      local log_file_path = vim.fn.stdpath 'cache' .. '/dap_vscode_js.log' -- Path for file logging
      require('tap.utils').notify_in_debug(
        log_file_path,
        vim.log.levels.DEBUG,
        { title = 'nvim-dap' }
      )

      require('dap-vscode-js').setup {
        -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
        debugger_path = require('lazy.core.config').options.root
          .. '/vscode-js-debug', -- Path to vscode-js-debug installation.
        -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
        adapters = { 'pwa-node' }, -- which adapters to register in nvim-dap
        log_file_path = log_file_path, -- Path for file logging
        log_file_level = require('tap.utils').debug_enabled()
            and vim.log.levels.DEBUG
          or vim.log.levels.WARN, -- Logging level for output to file. Set to false to disable file logging.
      }
    end,
  },

  {
    'mfussenegger/nvim-dap',
    lazy = true,
    dependencies = {
      'mxsdev/nvim-dap-vscode-js',
      { 'theHamsta/nvim-dap-virtual-text', config = true },
      'hrsh7th/nvim-cmp',
      'rcarriga/cmp-dap',
    },
    init = function()
      require('tap.utils').command {
        'DapToggleBreakpoint',
        function()
          require('dap').toggle_breakpoint()
        end,
      }
      require('tap.utils').command {
        'DapConditionalBreakpoint',
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint Condition: ')
        end,
      }
      require('tap.utils').command {
        'DapLogPoint',
        function()
          require('dap').set_breakpoint(
            nil,
            nil,
            vim.fn.input 'Log point message: '
          )
        end,
      }
    end,
    config = function()
      vim.fn.sign_define('DapBreakpoint', {
        text = '⬤ ',
        texthl = 'DiagnosticSignError',
        linehl = '',
        numhl = '',
      })
      vim.fn.sign_define('DapBreakpointCondition', {
        text = '⬤ ',
        texthl = 'DiagnosticSignWarn',
        linehl = '',
        numhl = '',
      })
      vim.fn.sign_define('DapLogPoint', {
        text = '⬤ ',
        texthl = 'DiagnosticSignHint',
        linehl = '',
        numhl = '',
      })
      vim.fn.sign_define('DapBreakpointRejected', {
        text = '',
        texthl = 'DiagnosticSignError',
        linehl = '',
        numhl = '',
      })

      require('cmp').setup {
        enabled = function()
          return require 'cmp.config.default'().enabled()
            or require('cmp_dap').is_dap_buffer()
        end,
      }
      require('cmp').setup.filetype(
        { 'dap-repl', 'dapui_watches', 'dapui_hover' },
        {
          sources = {
            { name = 'dap' },
          },
        }
      )
    end,
  },
}
