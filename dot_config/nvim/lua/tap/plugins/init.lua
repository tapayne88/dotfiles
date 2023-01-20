local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ','
vim.g.maplocalleader = '\\'

return require('lazy').setup({
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

  {
    'ckipp01/nvim-jenkinsfile-linter',
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

  -- Interactive neovim scratchpad for lua
  { 'rafcamlet/nvim-luapad', cmd = { 'Luapad', 'LuaRun' } },

  -- Seemless vim <-> tmux navigation
  {
    'aserowy/tmux.nvim',
    config = function()
      require 'tap.plugins.tmux-nvim'
    end,
  },

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

  -- Git integration ':Gstatus' etc.
  {
    'tpope/vim-fugitive',
    config = function()
      require 'tap.plugins.fugitive'
    end,
    dependencies = {
      'tpope/vim-rhubarb', -- :GBrowse github
      'shumphrey/fugitive-gitlab.vim', -- :GBrowse gitlab
    },
  },

  {
    'beauwilliams/focus.nvim',
    config = function()
      require('focus').setup {
        signcolumn = false,
        excluded_filetypes = { 'fugitive', 'git' },
      }
      require('tap.utils').keymap('n', '<leader>ft', ':FocusToggle<CR>', {
        description = '[Focus] Toggle window focusing',
      })
    end,
  },

  -- Simple plugin to easily resize windows
  {
    'simeji/winresizer',
    config = function()
      vim.g.winresizer_start_key = '<leader>w'
    end,
  },

  -- better syntax highlighting
  {
    {
      'nvim-treesitter/nvim-treesitter',
      config = function()
        require 'tap.plugins.treesitter'
      end,
      build = ':TSUpdate',
      dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    },
    {
      'nvim-treesitter/playground',
      cmd = { 'TSPlayground', 'TSPlaygroundToggle' },
    }, -- playground for illustrating the AST treesitter builds
  },

  -- whizzy command-p launcher
  {
    'nvim-telescope/telescope.nvim',
    config = function()
      require 'tap.plugins.telescope'
    end,
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
      'nvim-telescope/telescope-live-grep-args.nvim',
      {
        'nvim-telescope/telescope-smart-history.nvim',
        dependencies = { 'tami5/sqlite.lua' },
      },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
  },

  -- customise vim.ui appearance
  {
    'stevearc/dressing.nvim',
    config = function()
      require 'tap.plugins.dressing'
    end,
  },

  -- + & - in column for changed lines
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require 'tap.plugins.gitsigns'
    end,
    dependencies = { 'nvim-lua/plenary.nvim' },
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

  -- native neovim LSP support
  {
    'neovim/nvim-lspconfig', -- LSP server config
    -- after = 'nvim-notify',
    config = function()
      require 'tap.plugins.lspconfig'
    end,
    dependencies = {
      'b0o/schemastore.nvim', -- jsonls schemas
      'folke/neodev.nvim', -- lua-dev setup
      'lukas-reineke/lsp-format.nvim', -- async formatting
      'jose-elias-alvarez/null-ls.nvim',
      {
        'rmagatti/goto-preview',
        config = function()
          require('goto-preview').setup {
            border = {
              '↖',
              '─',
              '╮',
              '│',
              '╯',
              '─',
              '╰',
              '│',
            },
          }
        end,
      },
    },
  },

  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    config = function()
      require('lsp_lines').setup()
    end,
  },

  -- Auto completion plugin for nvim
  {
    'hrsh7th/nvim-cmp',
    config = function()
      require 'tap.plugins.nvim-cmp'
    end,
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
  },

  -- statusline in lua
  {
    'tapayne88/lualine.nvim',
    branch = 'suppress-winbar-no-room-error',
    config = function()
      require 'tap.plugins.lualine'
    end,
    dependencies = {
      { 'kyazdani42/nvim-web-devicons', lazy = true },
      'arkav/lualine-lsp-progress',
      {
        'SmiteshP/nvim-navic',
        dependencies = 'neovim/nvim-lspconfig',
      },
    },
  },

  {
    'glepnir/dashboard-nvim',
    config = function()
      require 'tap.plugins.dashboard-nvim'
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

  -- persistent terminals
  {
    'akinsho/toggleterm.nvim',
    config = function()
      require 'tap.plugins.toggleterm'
    end,
  },

  {
    'petertriho/nvim-scrollbar',
    config = function()
      require 'tap.plugins.nvim-scrollbar'
    end,
  },

  {
    'rcarriga/nvim-notify',
    config = function()
      require 'tap.plugins.nvim-notify'
    end,
  },

  {
    'psliwka/vim-dirtytalk',
    build = ':DirtytalkUpdate',
    config = function()
      vim.opt.spelllang = { 'en', 'programming' }
    end,
  },

  {
    'kylechui/nvim-surround',
    config = function()
      require('nvim-surround').setup {}
    end,
  },

  {
    'folke/trouble.nvim',
    dependencies = 'kyazdani42/nvim-web-devicons',
    config = function()
      require 'tap.plugins.trouble'
    end,
  },

  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v2.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'kyazdani42/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require 'tap.plugins.neotree'
    end,
  },

  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require 'tap.plugins.nvim-ufo'
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
}, {
  concurrency = 10,
})
