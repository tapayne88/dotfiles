return {
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    lazy = true,
    init = function()
      vim.api.nvim_create_user_command('DapUi', function()
        require('dapui').toggle { reset = true }
      end, { desc = 'Toggle Dap UI' })
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
      build = table.concat({
        'npm install --legacy-peer-deps',
        'npx gulp vsDebugServerBundle',
        'rm -rf out/dist',
        'mv dist out',
        'git checkout package-lock.json',
      }, ' && '),
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
      vim.api.nvim_create_user_command('DapToggleBreakpoint', function()
        require('dap').toggle_breakpoint()
      end, { desc = 'Toggle breakpoint' })

      local vim_ui_input_async = require('plenary.async').wrap(vim.ui.input, 2)

      local breakpoint_condition_msg = 'Breakpoint condition: '
      local log_point_msg = 'Log point message (interpolate with {foo}): '

      vim.api.nvim_create_user_command('DapConditionalBreakpoint', function()
        require('plenary.async').run(function()
          local cond = vim_ui_input_async { prompt = breakpoint_condition_msg }
          if cond == nil then
            return
          end

          require('dap').set_breakpoint(cond)
        end)
      end, { desc = 'Set conditional breakpoint' })
      vim.api.nvim_create_user_command('DapLogPoint', function()
        require('plenary.async').run(function()
          local msg = vim_ui_input_async { prompt = log_point_msg }
          if msg == nil then
            return
          end

          require('dap').set_breakpoint(nil, nil, msg)
        end)
      end, { desc = 'Set log point' })
      vim.api.nvim_create_user_command('DapConditionalLogPoint', function()
        require('plenary.async').run(function()
          local cond = vim_ui_input_async { prompt = breakpoint_condition_msg }
          if cond == nil then
            return
          end

          local msg = vim_ui_input_async { prompt = log_point_msg }
          if msg == nil then
            return
          end

          require('dap').set_breakpoint(cond, nil, msg)
        end)
      end, { desc = 'Set conditional log point' })
    end,
    config = function()
      vim.fn.sign_define('DapBreakpoint', {
        text = '',
        texthl = 'DapBreakpoint',
        linehl = '',
        numhl = '',
      })
      vim.fn.sign_define('DapBreakpointCondition', {
        text = '',
        texthl = 'DapBreakpointCondition',
        linehl = '',
        numhl = '',
      })
      vim.fn.sign_define('DapLogPoint', {
        text = '◆',
        texthl = 'DapLogPoint',
        linehl = '',
        numhl = '',
      })
      vim.fn.sign_define('DapBreakpointRejected', {
        text = '',
        texthl = 'DapBreakpoint',
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
