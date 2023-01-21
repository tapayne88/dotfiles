return {
  'tpope/vim-characterize', -- Adds 'ga' command to show character code
  'tpope/vim-commentary', -- Adds 'gc' & 'gcc' commands for commenting lines
  'tpope/vim-eunuch', -- Adds unix commands like ':Move' etc.
  'tpope/vim-scriptease', -- Vim plugin for making Vim plugins
  'tpope/vim-unimpaired', -- Complementary pairs of mappings for common actions
  'tpope/vim-vinegar', -- Nicer netrw defaults
  'tpope/vim-sleuth', -- Detect indentation
  'lervag/file-line', -- Handle filenames with line numbers i.e. :20
  'nvim-lua/plenary.nvim', -- Utility function used by plugins and my config
  'RRethy/vim-illuminate', -- Highlight same words
  'rktjmp/fwatch.nvim', -- Utility for watching files
  'dhruvasagar/vim-zoom', -- Toggle zoom in / out individual windows

  -- treesitter colorschemes
  {
    'shaunsingh/nord.nvim', -- dark theme
    'folke/tokyonight.nvim', -- light theme
  },

  -- Interactive neovim scratchpad for lua
  { 'rafcamlet/nvim-luapad', cmd = { 'Luapad', 'LuaRun' } },

  -- even better % navigation
  {
    'andymass/vim-matchup',
    config = function()
      vim.g.matchup_surround_enabled = 1
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    end,
  },

  -- Filetype icon support with lua support
  { 'ryanoasis/vim-devicons', 'kyazdani42/nvim-web-devicons' },

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
  { 'dstein64/vim-startuptime', cmd = 'StartupTime' },

  -- Simple plugin to easily resize windows
  {
    'simeji/winresizer',
    config = function()
      vim.g.winresizer_start_key = '<leader>w'
    end,
  },

  -- Language server and external tool installer
  {
    {
      'williamboman/mason.nvim',
      config = function()
        require('mason').setup()
        require 'tap.mason-registry'
      end,
    },
    'williamboman/mason-lspconfig.nvim',
  },

  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    config = function()
      require('lsp_lines').setup()
    end,
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
    'psliwka/vim-dirtytalk',
    build = ':DirtytalkUpdate',
    config = function()
      vim.opt.spelllang = { 'en', 'programming' }
      vim.opt.rtp:append(vim.fn.stdpath 'data' .. '/site')
    end,
  },

  {
    'kylechui/nvim-surround',
    config = function()
      require('nvim-surround').setup {}
    end,
  },

  -- The interactive scratchpad for hackers
  {
    'metakirby5/codi.vim',
    -- after = 'mason.nvim',
    config = function()
      require('tap.utils.lsp').ensure_installed {
        'tsun',
      }
    end,
  },
}
