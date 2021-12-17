-- Pulled from telescope.nvim
-- https://github.com/nvim-telescope/telescope.nvim/blob/master/.github/ISSUE_TEMPLATE/bug_report.yml
--
-- To make use of this file run the following
-- nvim -u ~/.config/nvim/minimal.lua ...
vim.cmd [[set runtimepath=$VIMRUNTIME]]
vim.cmd [[set packpath=/tmp/nvim/site]]

local package_root = '/tmp/nvim/site/pack'
local install_path = package_root .. '/packer/start/packer.nvim'
local function load_plugins()
    require('packer').startup {
        {
            'wbthomason/packer.nvim',
            {"tapayne88/which-key.nvim", branch = "fix/sporadic-function-loss"},
            {
                'nvim-telescope/telescope.nvim',
                requires = {'nvim-lua/popup.nvim', 'nvim-lua/plenary.nvim'}
            }
        },
        config = {
            package_root = package_root,
            compile_path = install_path .. '/plugin/packer_compiled.lua',
            display = {non_interactive = true}
        }
    }
end

_G.load_config = function()
    vim.g.mapleader = ","

    require("which-key").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    }
    require('telescope').setup {
        defaults = {
            prompt_prefix = "❯ ", -- this currently causes a neovim bug (see https://github.com/nvim-telescope/telescope.nvim/issues/567)
            layout_strategy = "flex", -- let telescope figure out what to do given the space
            layout_config = {height = {padding = 10}}
        }
    }

    local rhs_to_string = function(rhs)
        -- add functions to a global table keyed by their index
        if type(rhs) == "function" then
            local fn_id = tap._create(rhs)
            return string.format("<cmd>lua tap._execute(%s)<CR>", fn_id)
        end
        return rhs
    end

    local function make_mapper(mode, o)
        -- copy the opts table as extends will mutate the opts table passed in otherwise
        local parent_opts = vim.deepcopy(o)
        ---Create a mapping
        ---@param lhs string
        ---@param rhs string|function
        ---@param opts table
        return function(lhs, rhs, opts)
            assert(lhs ~= mode, string.format(
                       "The lhs should not be the same as mode for %s", lhs))
            local _opts = opts and vim.deepcopy(opts) or {}

            -- don't pass this invalid key to set keymap
            _opts.check_existing = nil

            local options = vim.tbl_extend("keep", _opts, parent_opts)
            if options.name ~= nil then
                local wk_opts = {
                    rhs,
                    options.name,
                    mode = mode,
                    noremap = options.noremap,
                    silent = options.silent,
                    buffer = options.bufnr
                }
                return require('which-key').register({[lhs] = wk_opts})
            end

            rhs = rhs_to_string(rhs)

            if options.bufnr then
                -- Remove the buffer from the args sent to the key map function
                local bufnr = options.bufnr
                options.bufnr = nil
                vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, options)
            else
                vim.api.nvim_set_keymap(mode, lhs, rhs, options)
            end
        end
    end

    local nnoremap = make_mapper("n", {noremap = true, silent = true})

    nnoremap("<leader>l", function()
        require('telescope.builtin').buffers {
            sort_lastused = true,
            sort_mru = true,
            show_all_buffers = true,
            selection_strategy = "closest"
        }
    end, {name = "List buffers"})
    nnoremap("<leader>gf", function()
        require('telescope.builtin').git_files {use_git_root = false}
    end, {name = "Relative git file"})
    nnoremap("<leader>gF",
             function() require('telescope.builtin').git_files() end,
             {name = "All git files"})
    nnoremap("<leader>rf", function()
        require('telescope.builtin').git_files {
            use_git_root = false,
            cwd = vim.fn.expand('%:p:h')
        }
    end, {name = "Git files relative to current file"})
    nnoremap("<leader>ff", function()
        require('telescope.builtin').find_files {hidden = true}
    end, {name = "Find File"})
    nnoremap("<leader>fb", function()
        require('telescope.builtin').file_browser {
            cwd = vim.fn.expand('%:p:h'),
            hidden = true
        }
    end, {name = "Relative File Browser"})
    nnoremap("<leader>fB", function()
        require('telescope.builtin').file_browser {hidden = true}
    end, {name = "CWD File Browser"})
    nnoremap("<leader>fh", function()
        require('telescope.builtin').file_browser {cwd = '~', hidden = true}
    end, {name = "Home Files"})
    nnoremap("<leader>gh",
             function() require('telescope.builtin').help_tags() end,
             {name = "Help Tags"})
    nnoremap("<leader>fg", function()
        require("telescope").extensions.live_grep_raw.live_grep_raw()
    end, {name = "Live Grep"})
    nnoremap("<leader>fG",
             function() require('telescope.builtin').live_grep() end,
             {name = "Live Grep"})
    nnoremap("<leader>fw", function()
        require('telescope.builtin').grep_string {
            prompt_title = "Grep: " .. vim.fn.expand("<cword>")
        }
    end, {name = "Find Word"})
    nnoremap("<leader>ch",
             function() require('telescope.builtin').command_history() end,
             {name = "Command History"})
end

if vim.fn.isdirectory(install_path) == 0 then
    print("Installing packer packages...")
    vim.fn.system {
        'git', 'clone', '--depth=1',
        'https://github.com/wbthomason/packer.nvim', install_path
    }
end

load_plugins()
require('packer').sync()
vim.cmd [[autocmd User PackerComplete ++once echo "Ready!" | lua load_config()]]
