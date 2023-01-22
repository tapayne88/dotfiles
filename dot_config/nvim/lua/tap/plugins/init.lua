return {
  'nvim-lua/plenary.nvim', -- everything needs plenary
  'tpope/vim-sleuth', -- Detect indentation
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

  -- Filetype icon support with lua support
  -- { 'ryanoasis/vim-devicons', 'kyazdani42/nvim-web-devicons' },

  -- Syntax not supported by treesitter
  { 'plasticboy/vim-markdown' },
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
