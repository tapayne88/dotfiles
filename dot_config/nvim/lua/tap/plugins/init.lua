return {
  'nvim-lua/plenary.nvim', -- everything needs plenary
  'lervag/file-line', -- Handle filenames with line numbers i.e. :20

  'tpope/vim-unimpaired', -- Complementary pairs of mappings for common actions
  {
    'psliwka/vim-dirtytalk',
    build = ':DirtytalkUpdate',
    config = function()
      vim.opt.spelllang = { 'en', 'programming' }
      vim.opt.rtp:append(vim.fn.stdpath 'data' .. '/site')
    end,
    keys = {
      -- vim-unimpaired
      '[os',
      ']os',
      'yos',
    },
  },

  { 'tpope/vim-sleuth', event = 'BufReadPre' }, -- Detect indentation

  { 'tpope/vim-characterize', keys = 'ga' }, -- Adds 'ga' command to show character code
  {
    'tpope/vim-scriptease', -- Vim plugin for making Vim plugins
    cmd = {
      'PP',
      'Runtime',
      'Disarm',
      'Scriptnames',
      'Messages',
      'Verbose',
      'Time',
      'Breakadd',
      'Vedit',
    },
    keys = {
      'K', -- Look up the :help for the VimL construct under the cursor.
      'zS', -- Show the active syntax highlighting groups under the cursor.
      'g=', -- Eval a motion or selection as VimL and replace it with the result. This is handy for doing math, even outside of VimL
    },
  },
  {
    'tpope/vim-eunuch',
    cmd = {
      'Remove',
      'Rename',
      'Delete',
      'Move',
      'Chmod',
      'Mkdir',
      'Cfind',
      'Clocate',
      'Lfind',
      'Llocate',
      'Wall',
      'SudoWrite',
      'SudoEdit',
    },
  }, -- Adds unix commands like ':Move' etc.

  -- Added so I can find/replace the following in a single :%S/foo/bar/g
  --  foo -> bar
  --  Foo -> Bar
  --  FOO -> BAR
  {
    { 'tpope/vim-abolish', dependencies = { 'smjonas/live-command.nvim' } },
    {
      'smjonas/live-command.nvim',
      -- TODO: Revert this back to opts when live_command is fixed
      config = function()
        require('live-command').setup {
          defaults = {
            enable_highlighting = true,
            inline_highlighting = true,
            hl_groups = {
              insertion = 'Search',
              deletion = 'Search',
              change = 'Search',
            },
          },
          commands = {
            S = { cmd = 'Subvert' }, -- must be defined before we import vim-abolish
          },
        }
      end,
    },
  },

  -- Syntax not supported by treesitter
  { 'plasticboy/vim-markdown', ft = 'markdown' },
  -- Markdown previewing commands
  {
    'iamcco/markdown-preview.nvim',
    build = function()
      vim.fn['mkdp#util#install']()
    end,
    ft = 'markdown',
    cmd = 'MarkdownPreview',
  },

  -- easier vim startup time profiling
  {
    'dstein64/vim-startuptime',
    cmd = 'StartupTime',
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },
}
