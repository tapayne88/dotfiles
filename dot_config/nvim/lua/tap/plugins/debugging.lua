---@param config {type?:string, args?:string[]|fun():string[]?}
local function get_args(config)
  local args = type(config.args) == 'function' and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
  local args_str = type(args) == 'table' and table.concat(args, ' ') or args --[[@as string]]

  config = vim.deepcopy(config)
  ---@cast args string[]
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input('Run with args: ', args_str)) --[[@as string]]
    if config.type and config.type == 'java' then
      ---@diagnostic disable-next-line: return-type-mismatch
      return new_args
    end
    return require('dap.utils').splitstr(new_args)
  end
  return config
end

local function with_input(prompt, action)
  return function(prev)
    vim.ui.input({ prompt = prompt }, function(resp)
      if resp == nil then
        vim.notify('input required', vim.log.levels.WARN, { title = 'dap' })
        return
      end
      if prev then
        return action(vim.fn.extend({ prev }, { resp }))
      else
        return action(resp)
      end
    end)
  end
end

local breakpoint_condition_msg = 'Breakpoint condition: '
local log_point_msg = 'Log point message (interpolate with {foo}): '

return {
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'nvim-neotest/nvim-nio',
    },
    lazy = true,
    init = function()
      vim.api.nvim_create_user_command('DapUi', function()
        require('dapui').toggle { reset = true }
      end, { desc = 'Toggle Dap UI' })
    end,

    -- stylua: ignore
    keys = {
      { "<leader>du", function() require("dapui").toggle({ }) end,  desc = "Dap UI" },
      { "<leader>de", function() require("dapui").eval() end,       desc = "Eval", mode = {"n", "v"} },
    },

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
      tag = 'v1.96.0',
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
      require('tap.utils').notify_in_debug(log_file_path, vim.log.levels.DEBUG, { title = 'nvim-dap' })

      require('dap-vscode-js').setup {
        -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
        debugger_path = require('lazy.core.config').options.root .. '/vscode-js-debug', -- Path to vscode-js-debug installation.
        -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
        adapters = { 'pwa-node' }, -- which adapters to register in nvim-dap
        log_file_path = log_file_path, -- Path for file logging
        log_file_level = require('tap.utils').debug_enabled() and vim.log.levels.DEBUG or vim.log.levels.WARN, -- Logging level for output to file. Set to false to disable file logging.
      }
    end,
  },

  {
    'mfussenegger/nvim-dap',
    lazy = true,
    dependencies = {
      'mxsdev/nvim-dap-vscode-js',
      'rcarriga/nvim-dap-ui',
      { 'theHamsta/nvim-dap-virtual-text', config = true },
      'hrsh7th/nvim-cmp',
      'rcarriga/cmp-dap',
    },

    -- stylua: ignore
    keys = {
      { "<leader>dB", function() with_input(breakpoint_condition_msg, require("dap").set_breakpoint)() end, desc = "Breakpoint Condition" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
      { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },

    init = function()
      vim.api.nvim_create_user_command('DapToggleBreakpoint', function()
        require('dap').toggle_breakpoint()
      end, { desc = 'Toggle breakpoint' })

      vim.api.nvim_create_user_command('DapConditionalBreakpoint', function()
        with_input(breakpoint_condition_msg, require('dap').set_breakpoint)()
      end, { desc = 'Set conditional breakpoint' })

      vim.api.nvim_create_user_command('DapLogPoint', function()
        with_input(log_point_msg, function(resp)
          return require('dap').set_breakpoint(nil, nil, resp)
        end)()
      end, { desc = 'Set log point' })

      vim.api.nvim_create_user_command('DapConditionalLogPoint', function()
        with_input(
          breakpoint_condition_msg,
          with_input(log_point_msg, function(args)
            return require('dap').set_breakpoint(args[1], nil, args[2])
          end)
        )()
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
          return require 'cmp.config.default'().enabled() or require('cmp_dap').is_dap_buffer()
        end,
      }
      require('cmp').setup.filetype({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, {
        sources = {
          { name = 'dap' },
        },
      })

      require('dap').listeners.before.attach.dapui_config = function()
        require('dapui').open()
      end
      require('dap').listeners.before.launch.dapui_config = function()
        require('dapui').open()
      end
    end,
  },
}
