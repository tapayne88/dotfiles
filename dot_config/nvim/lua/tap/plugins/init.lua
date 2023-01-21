return {
  'nvim-lua/plenary.nvim', -- everything needs plenary
  'tpope/vim-sleuth', -- Detect indentation
  'lervag/file-line', -- Handle filenames with line numbers i.e. :20
  'RRethy/vim-illuminate', -- Highlight same words

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
  { 'tpope/vim-commentary', keys = { 'gc', 'gcc' } }, -- Adds 'gc' & 'gcc' commands for commenting lines
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
  { 'dhruvasagar/vim-zoom', keys = '<C-w>m' }, -- Toggle zoom in / out individual windows

  -- even better % navigation
  {
    'andymass/vim-matchup',
    config = function()
      vim.g.matchup_surround_enabled = 1
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    end,
  },

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

  -- Simple plugin to easily resize windows
  {
    'simeji/winresizer',
    config = function()
      vim.g.winresizer_start_key = '<leader>w'
    end,
    keys = '<leader>w',
  },

  -- keymap plugins
  {
    {
      'mrjones2014/legendary.nvim',
      config = function()
        require('legendary').setup {}
        require('tap.utils').nnoremap(
          '<leader>p',
          ':lua require("legendary").find("keymaps")<CR>',
          {
            description = 'Legendary keymaps',
          }
        )
      end,
    },
    {
      'folke/which-key.nvim',
      config = function()
        require('which-key').setup {}
      end,
    },
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('indent_blankline').setup {
        char = '',
        context_char = '│',
        space_char_blankline = ' ',
        show_current_context = true,
      }
    end,
  },

  {
    'kylechui/nvim-surround',
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
}
