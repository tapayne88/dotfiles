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
    'mfussenegger/nvim-dap',
    lazy = true,
    dependencies = {
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
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },

    init = function()
      require('tap.utils.lsp').ensure_installed { 'js-debug-adapter' }

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
      local dap = require 'dap'

      vim.fn.sign_define('DapStopped', {
        text = '󰁕 ',
        texthl = 'DiagnosticWarn',
        linehl = 'DapStoppedLine',
        numhl = '',
      })
      vim.fn.sign_define('DapBreakpoint', {
        text = ' ',
        texthl = 'DapBreakpoint',
        linehl = '',
        numhl = '',
      })
      vim.fn.sign_define('DapBreakpointCondition', {
        text = ' ',
        texthl = 'DapBreakpointCondition',
        linehl = '',
        numhl = '',
      })
      vim.fn.sign_define('DapLogPoint', {
        text = '◆ ',
        texthl = 'DapLogPoint',
        linehl = '',
        numhl = '',
      })
      vim.fn.sign_define('DapBreakpointRejected', {
        text = ' ',
        texthl = 'DiagnosticError',
        linehl = '',
        numhl = '',
      })

      require('cmp').setup.filetype({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, {
        sources = {
          { name = 'dap' },
        },
      })

      -- setup dap config by VsCode launch.json file
      local vscode = require 'dap.ext.vscode'
      local json = require 'plenary.json'

      ---@diagnostic disable-next-line: duplicate-set-field
      vscode.json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end

      dap.listeners.before.attach.dapui_config = function()
        require('dapui').open()
      end
      dap.listeners.before.launch.dapui_config = function()
        require('dapui').open()
      end

      -- ╭──────────────────────────────────────────────────────────╮
      -- │ Adapters                                                 │
      -- ╰──────────────────────────────────────────────────────────╯
      for _, adapterType in ipairs { 'node', 'chrome', 'msedge' } do
        local pwaType = 'pwa-' .. adapterType

        if not dap.adapters[pwaType] then
          dap.adapters[pwaType] = {
            type = 'server',
            host = 'localhost',
            port = '${port}',
            executable = {
              command = 'js-debug-adapter',
              args = { '${port}' },
            },
          }
        end

        -- Define adapters without the "pwa-" prefix for VSCode compatibility
        if not dap.adapters[adapterType] then
          dap.adapters[adapterType] = function(cb, config)
            local nativeAdapter = dap.adapters[pwaType]

            config.type = pwaType

            if type(nativeAdapter) == 'function' then
              nativeAdapter(cb, config)
            else
              cb(nativeAdapter)
            end
          end
        end
      end

      -- ╭──────────────────────────────────────────────────────────╮
      -- │ Configurations                                           │
      -- ╰──────────────────────────────────────────────────────────╯
      local js_filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' }

      vscode.type_to_filetypes['node'] = js_filetypes
      vscode.type_to_filetypes['pwa-node'] = js_filetypes

      for _, language in ipairs(js_filetypes) do
        if not dap.configurations[language] then
          local runtimeExecutable = nil
          if language:find 'typescript' then
            runtimeExecutable = vim.fn.executable 'tsx' == 1 and 'tsx' or 'ts-node'
          end
          dap.configurations[language] = {
            {
              type = 'pwa-node',
              request = 'launch',
              name = 'Launch file',
              program = '${file}',
              cwd = '${workspaceFolder}',
              sourceMaps = true,
              runtimeExecutable = runtimeExecutable,
              skipFiles = {
                '<node_internals>/**',
                'node_modules/**',
              },
              resolveSourceMapLocations = {
                '${workspaceFolder}/**',
                '!**/node_modules/**',
              },
            },
            {
              type = 'pwa-node',
              request = 'attach',
              name = 'Attach',
              processId = require('dap.utils').pick_process,
              cwd = '${workspaceFolder}',
              sourceMaps = true,
              runtimeExecutable = runtimeExecutable,
              skipFiles = {
                '<node_internals>/**',
                'node_modules/**',
              },
              resolveSourceMapLocations = {
                '${workspaceFolder}/**',
                '!**/node_modules/**',
              },
            },
            -- Divider for the launch.json derived configs
            {
              name = '----- ↓ launch.json configs ↓ -----',
              type = '',
              request = 'launch',
            },
          }
        end
      end
    end,
  },
}
