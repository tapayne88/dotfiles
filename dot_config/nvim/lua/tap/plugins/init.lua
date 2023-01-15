local fn = vim.fn

local packer_scope = fn.stdpath 'data' .. '/site/pack/packer'
local packer_install_path = packer_scope .. '/start/packer.nvim'

local packer_bootstrap
if fn.empty(fn.glob(packer_install_path)) > 0 then
  vim.notify 'installing packer.nvim'
  packer_bootstrap = fn.system {
    'git',
    'clone',
    '--depth',
    '1',
    'https://github.com/wbthomason/packer.nvim',
    packer_install_path,
  }
  vim.cmd [[packadd packer.nvim]]
end

return require('packer').startup {
  function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- treesitter colorscheme
    use {
      'shaunsingh/nord.nvim',
      requires = {
        'folke/tokyonight.nvim', -- light colorscheme
      },
      config = [[require("tap.plugins.nord")]],
    }

    -- stylua: ignore start
    use 'tpope/vim-characterize'                        -- Adds 'ga' command to show character code
    use 'tpope/vim-commentary'                          -- Adds 'gc' & 'gcc' commands for commenting lines
    use 'tpope/vim-eunuch'                              -- Adds unix commands like ':Move' etc.
    use 'tpope/vim-scriptease'                          -- Vim plugin for making Vim plugins
    use 'tpope/vim-unimpaired'                          -- Complementary pairs of mappings for common actions
    use 'tpope/vim-vinegar'                             -- Nicer netrw defaults
    use 'tpope/vim-sleuth'                              -- Detect indentation
    use 'lervag/file-line'                              -- Handle filenames with line numbers i.e. :20
    use 'nvim-lua/plenary.nvim'                         -- Utility function used by plugins and my config
    use 'RRethy/vim-illuminate'                         -- Highlight same words
    use 'rktjmp/fwatch.nvim'                            -- Utility for watching files
    use 'dhruvasagar/vim-zoom'                          -- Toggle zoom in / out individual windows
    -- stylua: ignore end

    -- Chunk cache for neovim modules
    use {
      'lewis6991/impatient.nvim',
      config = function()
        require('tap.utils').augroup('Impatient', {
          {
            events = { 'PackerComplete', 'PackerCompileDone' },
            user = true,
            command = function()
              vim.cmd [[LuaCacheClear]]
              vim.notify(
                'Module cache cleared',
                vim.log.levels.INFO,
                { title = 'impatient.nvim' }
              )
            end,
          },
        })
      end,
    }

    use {
      'ckipp01/nvim-jenkinsfile-linter',
      requires = { 'nvim-lua/plenary.nvim' },
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
    }

    -- Interactive neovim scratchpad for lua
    use { 'rafcamlet/nvim-luapad', cmd = { 'Luapad', 'LuaRun' } }

    -- Seemless vim <-> tmux navigation
    use { 'aserowy/tmux.nvim', config = [[require("tap.plugins.tmux-nvim")]] }

    -- even better % navigation
    use {
      'andymass/vim-matchup',
      config = function()
        vim.g.matchup_surround_enabled = 1
        vim.g.matchup_matchparen_offscreen = { method = 'popup' }
      end,
    }

    -- Filetype icon support with lua support
    use { 'ryanoasis/vim-devicons', 'kyazdani42/nvim-web-devicons' }

    -- Syntax not supported by treesitter
    use { 'plasticboy/vim-markdown' }

    -- easier vim startup time profiling
    use { 'dstein64/vim-startuptime', cmd = 'StartupTime' }
    -- Markdown previewing commands
    use {
      'iamcco/markdown-preview.nvim',
      run = ':call mkdp#util#install()',
      ft = 'markdown',
      cmd = 'MarkdownPreview',
    }
    -- Git blame for line with commit message
    use {
      'rhysd/git-messenger.vim',
      cmd = 'GitMessenger',
      setup = function()
        require('tap.utils').nnoremap('<leader>gm', ':GitMessenger<CR>', {
          description = 'Show git blame for line',
        })
      end,
    }

    -- Git integration ':Gstatus' etc.
    use {
      'tpope/vim-fugitive',
      config = [[require("tap.plugins.fugitive")]],
      requires = {
        'tpope/vim-rhubarb', -- :GBrowse github
        'shumphrey/fugitive-gitlab.vim', -- :GBrowse gitlab
      },
    }
    -- Easier find & replace
    use { 'wincent/scalpel', config = [[require("tap.plugins.scalpel")]] }
    -- Simple plugin to easily resize windows
    use {
      'simeji/winresizer',
      config = [[vim.g.winresizer_start_key = '<leader>w']],
    }
    -- Fix performance issue with CursorHold events
    use {
      'antoinemadec/FixCursorHold.nvim',
      config = [[vim.g.cursorhold_updatetime = 500]],
    }
    -- better syntax highlighting
    use {
      {
        'nvim-treesitter/nvim-treesitter',
        config = [[require("tap.plugins.treesitter")]],
        run = ':TSUpdate',
        requires = { 'JoosepAlviste/nvim-ts-context-commentstring' },
      },
      {
        'nvim-treesitter/playground',
        cmd = { 'TSPlayground', 'TSPlaygroundToggle' },
      }, -- playground for illustrating the AST treesitter builds
    }
    -- whizzy command-p launcher
    use {
      'nvim-telescope/telescope.nvim',
      config = [[require("tap.plugins.telescope")]],
      requires = {
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-file-browser.nvim',
        'nvim-telescope/telescope-live-grep-args.nvim',
        {
          'nvim-telescope/telescope-smart-history.nvim',
          requires = { 'tami5/sqlite.lua' },
        },
        { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
      },
    }
    -- customise vim.ui appearance
    use {
      'stevearc/dressing.nvim',
      config = [[require("tap.plugins.dressing")]],
    }
    -- + & - in column for changed lines
    use {
      'lewis6991/gitsigns.nvim',
      config = [[require("tap.plugins.gitsigns")]],
      requires = { 'nvim-lua/plenary.nvim' },
    }

    -- Language server and external tool installer
    use {
      {
        'williamboman/mason.nvim',
        config = function()
          require('mason').setup()
          require 'tap.mason-registry'
        end,
      },
      'williamboman/mason-lspconfig.nvim',
    }

    -- native neovim LSP support
    use {
      'neovim/nvim-lspconfig', -- LSP server config
      after = 'nvim-notify',
      config = [[require("tap.plugins.lspconfig")]],
      requires = {
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
    }

    use {
      'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
      config = function()
        require('lsp_lines').setup()
      end,
    }

    -- Auto completion plugin for nvim
    use {
      'hrsh7th/nvim-cmp',
      config = [[require("tap.plugins.nvim-cmp")]],
      requires = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-buffer',
        'onsails/lspkind-nvim',
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',
        'f3fora/cmp-spell',
      },
    }

    -- statusline in lua
    use {
      'tapayne88/lualine.nvim',
      branch = 'suppress-winbar-no-room-error',
      config = [[require("tap.plugins.lualine")]],
      requires = {
        { 'kyazdani42/nvim-web-devicons', opt = true },
        'arkav/lualine-lsp-progress',
        {
          'SmiteshP/nvim-navic',
          requires = 'neovim/nvim-lspconfig',
        },
      },
    }

    use {
      'glepnir/dashboard-nvim',
      config = [[require("tap.plugins.dashboard-nvim")]],
    }

    -- keymap plugins
    use {
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
    }

    use {
      'lukas-reineke/indent-blankline.nvim',
      config = function()
        require('indent_blankline').setup {
          char = '',
          context_char = '│',
          space_char_blankline = ' ',
          show_current_context = true,
        }
      end,
    }

    -- persistent terminals
    use {
      'akinsho/toggleterm.nvim',
      config = [[require("tap.plugins.toggleterm")]],
    }

    use {
      'petertriho/nvim-scrollbar',
      config = [[require("tap.plugins.nvim-scrollbar")]],
    }

    use {
      'rcarriga/nvim-notify',
      config = [[require("tap.plugins.nvim-notify")]],
    }

    use {
      'psliwka/vim-dirtytalk',
      run = ':DirtytalkUpdate',
      config = function()
        vim.opt.spelllang = { 'en', 'programming' }
      end,
    }

    use {
      'kylechui/nvim-surround',
      config = function()
        require('nvim-surround').setup {}
      end,
    }

    use {
      'folke/trouble.nvim',
      requires = 'kyazdani42/nvim-web-devicons',
      config = [[require("tap.plugins.trouble")]],
    }

    use {
      'nvim-neo-tree/neo-tree.nvim',
      branch = 'v2.x',
      requires = {
        'nvim-lua/plenary.nvim',
        'kyazdani42/nvim-web-devicons', -- not strictly required, but recommended
        'MunifTanjim/nui.nvim',
      },
      config = [[require("tap.plugins.neotree")]],
    }

    use {
      'kevinhwang91/nvim-ufo',
      requires = {
        'kevinhwang91/promise-async',
        'nvim-treesitter/nvim-treesitter',
      },
      config = [[require("tap.plugins.nvim-ufo")]],
    }

    -- The interactive scratchpad for hackers
    use {
      'metakirby5/codi.vim',
      after = 'mason.nvim',
      config = function()
        require('tap.utils.lsp').ensure_installed {
          'tsun',
        }
      end,
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
      require('packer').sync()
    end
  end,
  config = {
    max_jobs = 10,
  },
}
