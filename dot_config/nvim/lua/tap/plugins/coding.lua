return {
  -- Adds 'gc' & 'gcc' commands for commenting lines
  'tpope/vim-commentary',

  -- Validate jenkinsfiles against server
  {
    'ckipp01/nvim-jenkinsfile-linter',
    ft = 'groovy',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('tap.utils').augroup('JenkinsfileLinter', {
        {
          events = { 'BufWritePost' },
          targets = { 'Jenkinsfile', 'Jenkinsfile.*' },
          command = function()
            if require('jenkinsfile_linter').check_creds() then
              require('jenkinsfile_linter').validate()
            end
          end,
        },
      })
    end,
  },

  -- Auto completion plugin for nvim
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'onsails/lspkind-nvim',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'f3fora/cmp-spell',
    },
    config = function()
      local cmp = require 'cmp'
      local lspkind = require 'lspkind'

      local WIDE_HEIGHT = 40

      -- Avoid showing extra message when using completion
      vim.opt.shortmess:append 'c'

      cmp.setup {
        completion = {
          -- Set completeopt to have a better completion experience
          completeopt = 'menuone,noselect',
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.close(),
          ['<CR>'] = cmp.mapping.confirm(), -- needed to select snippets
        },

        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },

        sources = {
          { name = 'nvim_lsp' },
          { name = 'nvim_lua' },
          { name = 'path' },
          { name = 'buffer' },
          { name = 'luasnip' },
          { name = 'spell' },
        },

        formatting = {
          format = lspkind.cmp_format {
            with_text = true,
            menu = {
              nvim_lsp = '[LSP]',
              nvim_lua = '[api]',
              path = '[path]',
              buffer = '[buf]',
              luasnip = '[snip]',
              spell = '[spell]',
            },
          },
        },

        window = {
          documentation = {
            border = {
              '',
              '',
              '',
              ' ',
              ' ',
              ' ',
              ' ',
              ' ',
            },
            max_height = math.floor(WIDE_HEIGHT * (WIDE_HEIGHT / vim.o.lines)),
            max_width = math.floor(
              (WIDE_HEIGHT * 2) * (vim.o.columns / (WIDE_HEIGHT * 2 * 16 / 9))
            ),
            winhighlight = 'Normal:ColorColumn,FloatBorder:ColorColumn,CursorLine:PmenuSel,Search:None',
          },
        },

        experimental = { ghost_text = true },
      }

      require('tap.utils').apply_user_highlights('NvimCmp', function(highlight)
        highlight('CmpItemAbbrDeprecated', { link = 'Error', force = true })
        highlight('CmpItemKind', { link = 'Special', force = true })
        highlight('CmpItemMenu', { link = 'Comment', force = true })
      end)
    end,
  },

  -- even better % navigation
  {
    'andymass/vim-matchup',
    event = 'BufReadPost',
    config = function()
      vim.g.matchup_surround_enabled = 1
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    end,
  },

  -- Add/change/delete surrounding delimiter pairs with ease
  {
    'kylechui/nvim-surround',
    event = 'BufReadPost',
    config = function()
      require('nvim-surround').setup {}
    end,
  },

  -- Interactive neovim scratchpad for lua
  { 'rafcamlet/nvim-luapad', cmd = { 'Luapad', 'LuaRun' } },
  -- The interactive scratchpad for hackers
  {
    'metakirby5/codi.vim',
    config = function()
      require('tap.utils.lsp').ensure_installed {
        'tsun',
      }
    end,
    cmd = {
      'Codi',
      'CodiNew',
      'CodiSelect',
      'CodiExpand',
    },
  },

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
      -- Pinned to version as build step was refactored and output changed (also
      -- doesn't seem to work)
      commit = '581f6451f6b5ed187ffa579623df19ff82d1476f',
      build = 'npm install --legacy-peer-deps && npm run compile',
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

  {
    'David-Kunz/jester',
    lazy = true,
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    init = function()
      local script_name_map = {
        ['jest'] = { './node_modules/jest/bin/jest.js' },
        ['react-scripts'] = {
          './node_modules/react-scripts/bin/react-scripts.js',
          './node_modules/@anaplan/react-scripts/bin/react-scripts.js',
        },
      }

      local is_env_var = function(token)
        if token:match '^[A-Z_]+=' then
          return true
        end
        return false
      end

      local is_flag = function(token)
        if token:match '^%-%-[%w-]+' then
          return true
        end
        return false
      end

      local get_runtime = function(token, cwd)
        for script_name, script_paths in pairs(script_name_map) do
          if token == script_name then
            for _, script_path in ipairs(script_paths) do
              if vim.loop.fs_stat(cwd .. '/' .. script_path) ~= nil then
                return script_path
              end
            end
          end
        end

        return token
      end

      local get_runtime_args = function(pkg_script, cwd)
        local token_types = {
          env = {},
          script = {},
          flags = {},
        }

        for token in pkg_script:gmatch '[^%s]+' do
          if is_env_var(token) then
            table.insert(token_types.env, token)
          elseif is_flag(token) then
            table.insert(token_types.flags, token)
          else
            table.insert(token_types.script, get_runtime(token, cwd))
          end
        end

        if
          #token_types.env == 0
          and #token_types.script == 0
          and #token_types.flags == 0
        then
          return nil
        end
        return token_types
      end

      require('tap.utils').command {
        'JesterDebug',
        function()
          require('plenary.async').run(function()
            -- 1. Find nearest package.json
            local file_dir = vim.fn.expand '%:p:h'
            local package_json_filename = 'package.json'
            local cwd = require('tap.utils').root_pattern {
              package_json_filename,
            }(file_dir)

            if not cwd then
              vim.notify(
                'Could not find package.json for file path ' .. file_dir,
                vim.log.levels.INFO,
                { title = 'jester' }
              )
              return
            end

            -- 2. Parse package.json
            local package_json_filepath = cwd .. '/' .. package_json_filename
            local package_json_content =
              require('tap.utils').read_file(package_json_filepath)

            local package_json = vim.json.decode(package_json_content)

            -- 3. Look for test script
            if not package_json.scripts then
              vim.notify(
                'Could not find scripts in ' .. package_json_filepath,
                vim.log.levels.INFO,
                { title = 'jester' }
              )
              return
            end

            local test_script = package_json.scripts.jest
              or package_json.scripts.test

            if not test_script then
              vim.notify(
                'Could not find test script in ' .. package_json_filepath,
                vim.log.levels.INFO,
                { title = 'jester' }
              )
              return
            end

            require('tap.utils').logger.info(
              string.format('Found test script `%s`', test_script)
            )

            -- 4. Convert executable to .js source file
            local script_tokens = get_runtime_args(test_script, cwd)

            if script_tokens == nil then
              vim.notify(
                string.format(
                  'Could not determine test arguments for script `%s`',
                  test_script
                ),
                vim.log.levels.INFO,
                { title = 'jester' }
              )
              return
            end

            local runtimeArgs = vim.tbl_flatten {
              '--inspect-brk',
              script_tokens.script,
              script_tokens.flags,
              '--runInBand',
              '--no-coverage',
              '--no-cache',
              '--watchAll=false',
              '--testNamePattern',
              '$result',
              '--',
              '$file',
            }

            require('tap.utils').logger.info(
              'Running jester.debug with runtimeArgs',
              runtimeArgs,
              'and env',
              script_tokens.env
            )

            -- 5. Run debugger with source file, env vars and args from script
            vim.schedule(function()
              require('jester').debug {
                escape_regex = false,
                dap = {
                  type = 'pwa-node',
                  request = 'launch',
                  name = 'Debug Jest Tests',
                  -- trace = true, -- include debugger info
                  runtimeExecutable = 'node',
                  runtimeArgs = runtimeArgs,
                  args = {}, -- override default, causes issues with $file (last arg of runtimeArgs)
                  env = script_tokens.env,
                  sourceMaps = true,
                  rootPath = '${workspaceFolder}',
                  cwd = cwd,
                  console = 'integratedTerminal',
                  internalConsoleOptions = 'neverOpen',
                },
              }
            end)
          end)
        end,
      }
    end,
    config = function()
      require('jester').setup {
        cmd = "npm test -- $file --testNamePattern '$result'", -- run command
        identifiers = { 'test', 'it' }, -- used to identify tests
        prepend = { 'describe' }, -- prepend describe blocks
        expressions = { 'call_expression' }, -- tree-sitter object used to scan for tests/describe blocks
        path_to_jest_run = './node_modules/jest/bin/jest.js',
        path_to_jest_debug = './node_modules/jest/bin/jest.js',
        terminal_cmd = ':vsplit | terminal', -- used to spawn a terminal for running tests, for debugging refer to nvim-dap's config
      }
    end,
  },
}
