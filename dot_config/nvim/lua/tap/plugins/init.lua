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

    -- LuaFormatter off
    use 'ChristianChiarulli/nvcode-color-schemes.vim'   -- treesitter colorscheme
    use 'lervag/file-line'                              -- Handle filenames with line numbers i.e. :20
    use 'tpope/vim-characterize'                        -- Adds 'ga' command to show character code
    use 'tpope/vim-commentary'                          -- Adds 'gc' & 'gcc' commands for commenting lines
    use 'tpope/vim-eunuch'                              -- Adds unix commands like ':Move' etc.
    use 'tpope/vim-surround'                            -- Adds 'cs' command to change surround e.g. cs'<p> - would change 'this' => <p>this</p>
    use 'jaawerth/nrun.vim'                             -- Put locally installed npm module .bin at front of path
    use 'tpope/vim-sleuth'                              -- Detect indentation
    use 'christoomey/vim-tmux-navigator'                -- Seemless vim <-> tmux navigation
    use 'nvim-lua/plenary.nvim'                         -- Utility function used by plugins and my config
    -- LuaFormatter on

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
    -- easy testing
    use {
        'janko-m/vim-test',
        config = [[require("tap.plugins.vim-test")]],
        cmd = {'TestNearest', 'TestFile', 'TestSuite', 'TestLast', 'TestVisit'}
    }
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
    use {'tpope/vim-fugitive', config = [[require("tap.plugins.fugitive")]]}
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
            run = ':TSUpdate'
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
        requires = {'nvim-lua/popup.nvim', 'nvim-lua/plenary.nvim'}
    }
    -- + & - in column for changed lines
    use {
        'lewis6991/gitsigns.nvim',
        config = [[require("tap.plugins.gitsigns")]],
        requires = {'nvim-lua/plenary.nvim'}
    }

    -- native neovim LSP support
    use {
        'neovim/nvim-lspconfig', -- LSP server config
        config = [[require("tap.lsp")]],
        requires = {
            'kabouzeid/nvim-lspinstall', -- install LSP servers
            'tapayne88/lspsaga.nvim' -- Better LSP diagnostics display
        }
    }

    -- Auto completion plugin for nvim
    use {'hrsh7th/nvim-compe', config = [[require("tap.plugins.nvim-compe")]]}

    -- statusline in lua
    use {
        'glepnir/galaxyline.nvim',
        branch = 'main',
        config = [[require("tap.plugins.galaxyline")]],
        requires = {'kyazdani42/nvim-web-devicons'}
    }
end)
