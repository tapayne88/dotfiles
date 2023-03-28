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
    'David-Kunz/jester',
    lazy = true,
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    init = function()
      -- Map of test executable to node_modules path which can be passed to node
      -- It also describes how arguments are passed to the script
      local script_name_map = {
        ['jest'] = {
          {
            executable = './node_modules/jest/bin/jest.js',
            args = { '--', '$file' },
          },
        },
        ['react-scripts'] = {
          {
            executable = './node_modules/react-scripts/bin/react-scripts.js',
            args = { '$file' },
          },
          {
            -- fork of react-scripts
            executable = './node_modules/@anaplan/react-scripts/bin/react-scripts.js',
            args = { '$file' },
          },
        },
      }

      -- Detect if token is an environment variable
      local is_env_var = function(token)
        if token:match '^[A-Z_]+=' then
          return true
        end
        return false
      end

      -- Detect if token is a command flag
      local is_flag = function(token)
        if token:match '^%-%-[%w-]+' then
          return true
        end
        return false
      end

      -- Attempt to get the node_modules script path for the token
      local get_executable_path = function(token, cwd)
        for script_name, script_paths in pairs(script_name_map) do
          if token == script_name then
            for _, script in ipairs(script_paths) do
              if vim.loop.fs_stat(cwd .. '/' .. script.executable) ~= nil then
                return script
              end
            end
          end
        end

        return nil
      end

      -- Parse the script's tokens into their different types
      -- i.e. env var, flag, executable, etc.
      local parse_test_script = function(pkg_script, cwd)
        local token_types = {
          env = {},
          script = {},
          command = {},
          flags = {},
          args = {},
        }

        -- Split script into tokens separated by spaces
        for token in pkg_script:gmatch '[^%s]+' do
          if is_env_var(token) then
            table.insert(token_types.env, token)
          elseif is_flag(token) then
            table.insert(token_types.flags, token)
          else
            local runtime = get_executable_path(token, cwd)

            if runtime ~= nil then
              table.insert(token_types.script, runtime.executable)
              table.insert(token_types.args, runtime.args)
            else
              table.insert(token_types.command, token)
            end
          end
        end

        -- If we haven't been able to match the script name to executable path
        -- then abort
        if #token_types.script == 0 then
          return nil
        end
        return token_types
      end

      local test_runner = function(jester_fn, additional_runtime_args)
        return function()
          require('plenary.async').run(function()
            -- 1. Find nearest package.json
            local file_dir = vim.fn.expand '%:p:h'
            local package_json_filename = 'package.json'
            local package_json_dir = require('tap.utils').root_pattern {
              package_json_filename,
            }(file_dir)

            if not package_json_dir then
              vim.notify(
                'Could not find package.json for file path ' .. file_dir,
                vim.log.levels.INFO,
                { title = 'jester' }
              )
              return
            end

            -- 2. Parse package.json
            local package_json_filepath = package_json_dir
              .. '/'
              .. package_json_filename
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
            local script_tokens =
              parse_test_script(test_script, package_json_dir)

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

            local runtime_args = vim.tbl_flatten {
              '--inspect-brk',
              script_tokens.script,
              script_tokens.command,
              script_tokens.flags,
              '--runInBand',
              '--no-coverage',
              '--no-cache',
              '--watchAll=false',
              unpack(additional_runtime_args),
              script_tokens.args,
            }

            require('tap.utils').logger.info(
              'Running jester.debug with runtimeArgs',
              runtime_args,
              'and env',
              script_tokens.env
            )

            -- 5. Run debugger with source file, env vars and args from script
            vim.schedule(function()
              require('jester')[jester_fn] {
                escape_regex = false,
                dap = {
                  type = 'pwa-node',
                  request = 'launch',
                  name = 'Debug Jest Tests',
                  -- trace = true, -- include debugger info
                  runtimeExecutable = 'node',
                  runtimeArgs = runtime_args,
                  args = {}, -- override default, causes issues with $file (last arg of runtimeArgs)
                  env = script_tokens.env,
                  sourceMaps = true,
                  rootPath = '${workspaceFolder}',
                  cwd = package_json_dir,
                  console = 'integratedTerminal',
                  internalConsoleOptions = 'neverOpen',
                },
              }
            end)
          end)
        end
      end

      local test_nearest =
        test_runner('debug', { '--testNamePattern', '$result' })
      local test_file = test_runner('debug_file', {})

      require('tap.utils').command {
        'JesterDebug',
        test_nearest,
      }
      require('tap.utils').command {
        'JesterDebugFile',
        test_file,
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
