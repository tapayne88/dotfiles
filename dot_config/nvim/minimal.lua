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
            -- ADD PLUGINS THAT ARE _NECESSARY_ FOR REPRODUCING THE ISSUE
            'tpope/vim-sleuth', {
                'nvim-treesitter/nvim-treesitter',
                config = function()
                    require"nvim-treesitter.configs".setup {
                        ensure_installed = {"lua"},
                        highlight = {enable = true}
                    }
                end
            }, {
                'neovim/nvim-lspconfig', -- LSP server config
                requires = {"williamboman/nvim-lsp-installer"},
                config = function()
                    vim.lsp.set_log_level(vim.lsp.log_levels.DEBUG)

                    local lsp_installer = require "nvim-lsp-installer"

                    lsp_installer.settings({
                        install_root_dir = "/tmp/nvim/lsp_servers"
                    })

                    local name, version =
                        require"nvim-lsp-installer.servers".parse_server_identifier(
                            'sumneko_lua@v2.6.6')
                    local ok, server = lsp_installer.get_server(name)
                    if ok then
                        if not server:is_installed() then
                            server:install(version)
                        end
                        server:on_ready(function()
                            server:setup({
                                cmd = {"lua-language-server", "--preview"},
                                autostart = true,
                                on_attach = function(client)
                                    if client.resolved_capabilities
                                        .document_formatting then
                                        vim.cmd [[nnoremap <space>f <cmd>lua vim.lsp.buf.formatting()<CR>]]
                                    end
                                end
                            })
                        end)
                    end
                end
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
    -- ADD INIT.LUA SETTINGS THAT ARE _NECESSARY_ FOR REPRODUCING THE ISSUE
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
