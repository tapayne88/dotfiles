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
      'rcarriga/cmp-dap',
    },
    config = function()
      local cmp = require 'cmp'
      local lspkind = require 'lspkind'

      local WIDE_HEIGHT = 40

      -- Avoid showing extra message when using completion
      vim.opt.shortmess:append 'c'

      cmp.setup {
        enabled = function()
          return require 'cmp.config.default'().enabled()
            or require('cmp_dap').is_dap_buffer()
        end,
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
    'mfussenegger/nvim-dap',
    dependencies = {
      'williamboman/mason.nvim',
      {
        'mxsdev/nvim-dap-vscode-js',
        dependencies = {
          'microsoft/vscode-js-debug',
          commit = '581f6451f6b5ed187ffa579623df19ff82d1476f',
          pin = true,
          build = 'npm install --legacy-peer-deps && npm run compile',
        },
      },
      'hrsh7th/nvim-cmp',
    },
    config = function()
      require('dap-vscode-js').setup {
        -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
        debugger_path = require('lazy.core.config').options.root
          .. '/vscode-js-debug', -- Path to vscode-js-debug installation.
        -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
        adapters = {
          'pwa-node',
          -- 'pwa-chrome',
          -- 'pwa-msedge',
          -- 'node-terminal',
          -- 'pwa-extensionHost',
        }, -- which adapters to register in nvim-dap
        -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
        -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
        -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
      }

      require('cmp').setup.filetype(
        { 'dap-repl', 'dapui_watches', 'dapui_hover' },
        {
          sources = {
            { name = 'dap' },
          },
        }
      )
      -- require('dap').configurations.javascript = {
      --   {
      --     name = 'Launch',
      --     type = 'node2',
      --     request = 'launch',
      --     program = '${file}',
      --     cwd = vim.fn.getcwd(),
      --     sourceMaps = true,
      --     protocol = 'inspector',
      --     console = 'integratedTerminal',
      --   },
      --   {
      --     -- For this to work you need to make sure the node process is started with the `--inspect` flag.
      --     name = 'Attach to process',
      --     type = 'node2',
      --     request = 'attach',
      --     processId = require('dap.utils').pick_process,
      --   },
      -- }
    end,
  },

  {
    'David-Kunz/jester',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    config = function()
      require('jester').setup {
        cmd = "jest --config=jest.config.js -t '$result' -- $file", -- run command
        identifiers = { 'test', 'it' }, -- used to identify tests
        prepend = { 'describe' }, -- prepend describe blocks
        expressions = { 'call_expression' }, -- tree-sitter object used to scan for tests/describe blocks
        path_to_jest_run = '/Users/tom.payne/git/work/dashboards-and-visualisations/node_modules/.pnpm/jest@26.6.3/node_modules/jest/bin/jest.js', -- used to run tests
        path_to_jest_debug = '/Users/tom.payne/git/work/dashboards-and-visualisations/node_modules/.pnpm/jest@26.6.3/node_modules/jest/bin/jest.js', -- used for debugging
        terminal_cmd = ':vsplit | terminal', -- used to spawn a terminal for running tests, for debugging refer to nvim-dap's config
        -- dap = { -- debug adapter configuration
        --   type = 'node2',
        --   request = 'launch',
        --   cwd = '/Users/tom.payne/git/work/dashboards-and-visualisations/packages/formula-formatter',
        --   runtimeArgs = {
        --     '--inspect-brk',
        --     '$path_to_jest',
        --     '--no-coverage',
        --     '-t',
        --     '$result',
        --     '--',
        --     '$file',
        --   },
        --   args = { '--no-cache' },
        --   sourceMaps = false,
        --   protocol = 'inspector',
        --   skipFiles = { '<node_internals>/**/*.js' },
        --   console = 'integratedTerminal',
        --   port = 9229,
        --   disableOptimisticBPs = true,
        -- },
        dap = {
          type = 'pwa-node',
          request = 'launch',
          name = 'Debug Jest Tests',
          -- trace = true, -- include debugger info
          runtimeExecutable = 'node',
          runtimeArgs = {
            -- './node_modules/jest/bin/jest.js',
            '--inspect-brk',
            '$path_to_jest',
            '--runInBand',
            '--no-coverage',
            '-t',
            '$result',
            '--',
            '$file',
          },
          sourceMaps = true,
          args = { '--no-cache' },
          rootPath = '${workspaceFolder}',
          -- cwd = '${workspaceFolder}',
          cwd = '/Users/tom.payne/git/work/dashboards-and-visualisations/packages/formula-formatter',
          console = 'integratedTerminal',
          internalConsoleOptions = 'neverOpen',
        },
      }
    end,
  },
}
