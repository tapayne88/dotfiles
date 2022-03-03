local fn = vim.fn

local packer_scope = fn.stdpath('data') .. '/site/pack/packer'
local packer_install_path = packer_scope .. '/start/packer.nvim'

if fn.empty(fn.glob(packer_install_path)) > 0 then
    fn.system({
        'git', 'clone', 'https://github.com/wbthomason/packer.nvim',
        packer_install_path
    })
    vim.api.nvim_command 'packadd packer.nvim'
end

-- If chezmoi.vim is available, load immediately
if fn.empty(fn.glob(packer_scope .. '/opt/chezmoi.vim')) == 0 then
    vim.g['chezmoi#source_dir_path'] = vim.g.chezmoi_source_dir
    vim.api.nvim_command 'packadd chezmoi.vim'
end

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- Special handling for chezmoi files (templates, etc.), set as optional so
    -- packer doesn't load it,  needs to be loaded earlier than packer can
    use {'alker0/chezmoi.vim', opt = true}

    -- treesitter colorscheme
    use {
        'shaunsingh/nord.nvim',
        requires = {
            'folke/tokyonight.nvim' -- light colorscheme
        },
        config = [[require("tap.plugins.nord")]]
    }

    -- LuaFormatter off
    use 'lervag/file-line'                              -- Handle filenames with line numbers i.e. :20
    use 'tpope/vim-characterize'                        -- Adds 'ga' command to show character code
    use 'tpope/vim-commentary'                          -- Adds 'gc' & 'gcc' commands for commenting lines
    use 'tpope/vim-eunuch'                              -- Adds unix commands like ':Move' etc.
    use 'tpope/vim-surround'                            -- Adds 'cs' command to change surround e.g. cs'<p> - would change 'this' => <p>this</p>
    use 'jaawerth/nrun.vim'                             -- Put locally installed npm module .bin at front of path
    use 'nvim-lua/plenary.nvim'                         -- Utility function used by plugins and my config
    use 'tpope/vim-scriptease'                          -- Vim plugin for making Vim plugins
    use 'RRethy/vim-illuminate'                         -- Highlight same words
    use 'tpope/vim-unimpaired'                          -- Complementary pairs of mappings for common actions
    use 'tpope/vim-vinegar'                             -- Nicer netrw defaults
    -- LuaFormatter on

    -- Detect indentation
    use {
        'tpope/vim-sleuth',
        config = function()
            -- The below can be removed when Neovim 0.7 is released
            -- https://github.com/tpope/vim-sleuth/issues/80
            vim.cmd [[au BufEnter * setlocal fixendofline]]
        end
    }

    -- Interactive neovim scratchpad for lua
    use {'rafcamlet/nvim-luapad', cmd = {"Luapad", "LuaRun"}}

    -- Seemless vim <-> tmux navigation
    use {'aserowy/tmux.nvim', config = [[require("tap.plugins.tmux-nvim")]]}

    -- even better % navigation
    use {
        'andymass/vim-matchup',
        config = function()
            vim.g.matchup_surround_enabled = 1
            vim.g.matchup_matchparen_offscreen = {method = 'popup'}
        end
    }

    -- Filetype icon support with lua support
    use {'ryanoasis/vim-devicons', 'kyazdani42/nvim-web-devicons'}

    -- Syntax not supported by treesitter
    use {'plasticboy/vim-markdown'}

    -- Async vim compiler plugins (used to run mocha test below)
    use {'tpope/vim-dispatch', cmd = 'Dispatch'}
    -- easier vim startup time profiling
    use {'tweekmonster/startuptime.vim', cmd = 'StartupTime'}
    -- Markdown previewing commands
    use {
        'iamcco/markdown-preview.nvim',
        run = ':call mkdp#util#install()',
        ft = 'markdown',
        cmd = 'MarkdownPreview'
    }
    -- Git blame for line with commit message
    use {
        'rhysd/git-messenger.vim',
        cmd = 'GitMessenger',
        setup = [[require("tap.utils").nnoremap('<leader>gm', ':GitMessenger<CR>')]]
    }

    -- Git integration ':Gstatus' etc.
    use {
        'tpope/vim-fugitive',
        config = [[require("tap.plugins.fugitive")]],
        requires = {
            'tpope/vim-rhubarb', -- :GBrowse github
            'shumphrey/fugitive-gitlab.vim' -- :GBrowse gitlab
        }
    }
    -- Easier find & replace
    use {'wincent/scalpel', config = [[require("tap.plugins.scalpel")]]}
    -- Simple plugin to easily resize windows
    use {
        'simeji/winresizer',
        config = [[vim.g.winresizer_start_key = '<leader>w']]
    }
    -- Fix performance issue with CursorHold events
    use {
        'antoinemadec/FixCursorHold.nvim',
        config = [[vim.g.cursorhold_updatetime = 500]]
    }
    -- better syntax highlighting
    use {
        {
            'nvim-treesitter/nvim-treesitter',
            config = [[require("tap.plugins.treesitter")]],
            run = ':TSUpdate',
            requires = {'JoosepAlviste/nvim-ts-context-commentstring'}
        },
        {
            'nvim-treesitter/playground',
            cmd = {"TSPlayground", "TSPlaygroundToggle"}
        } -- playground for illustrating the AST treesitter builds
    }
    -- whizzy command-p launcher
    use {
        'nvim-telescope/telescope.nvim',
        config = [[require("tap.plugins.telescope")]],
        requires = {
            'nvim-lua/popup.nvim', 'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-file-browser.nvim',
            'nvim-telescope/telescope-live-grep-raw.nvim'
        }
    }
    -- customise vim.ui appearance
    use {'stevearc/dressing.nvim', config = [[require("tap.plugins.dressing")]]}
    -- + & - in column for changed lines
    use {
        'lewis6991/gitsigns.nvim',
        config = [[require("tap.plugins.gitsigns")]],
        requires = {'nvim-lua/plenary.nvim'}
    }

    -- native neovim LSP support
    use {
        'neovim/nvim-lspconfig', -- LSP server config
        after = "nvim-notify",
        config = [[require("tap.plugins.lspconfig")]],
        requires = {
            'williamboman/nvim-lsp-installer', -- install LSP servers
            'b0o/schemastore.nvim', -- jsonls schemas
            'folke/lua-dev.nvim', -- lua-dev setup
            'lukas-reineke/lsp-format.nvim', -- async formatting
            {
                'rmagatti/goto-preview',
                config = function()
                    require('goto-preview').setup {
                        border = {
                            "↖", "─", "╮", "│", "╯", "─", "╰",
                            "│"
                        }
                    }
                end
            }
        }
    }

    -- Auto completion plugin for nvim
    use {
        'hrsh7th/nvim-cmp',
        config = [[require("tap.plugins.nvim-cmp")]],
        requires = {
            'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-nvim-lua', 'hrsh7th/cmp-path',
            'hrsh7th/cmp-buffer', 'onsails/lspkind-nvim', 'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip'
        }
    }

    -- statusline in lua
    use {
        'nvim-lualine/lualine.nvim',
        config = [[require("tap.plugins.lualine")]],
        requires = {
            {'kyazdani42/nvim-web-devicons', opt = true},
            'arkav/lualine-lsp-progress'
        }
    }

    use {
        'glepnir/dashboard-nvim',
        config = [[require("tap.plugins.dashboard-nvim")]]
    }

    -- keymap plugins
    use {
        {"tapayne88/mappy.nvim", branch = "feature/buffer-mappings"},
        {
            "folke/which-key.nvim",
            config = function() require("which-key").setup {} end
        }
    }

    use {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("indent_blankline").setup {
                char = " ",
                context_char = "│",
                space_char_blankline = " ",
                show_current_context = true
            }
        end
    }

    -- persistent terminals
    use {
        "akinsho/toggleterm.nvim",
        config = [[require("tap.plugins.toggleterm")]]
    }

    use {
        "petertriho/nvim-scrollbar",
        config = [[require("tap.plugins.nvim-scrollbar")]]
    }

    use {
        "rcarriga/nvim-notify",
        config = [[require("tap.plugins.nvim-notify")]]
    }
end)
