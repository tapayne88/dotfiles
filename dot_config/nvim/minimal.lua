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
            'wbthomason/packer.nvim', 'lbrayner/vim-rzip'
            -- ADD PLUGINS THAT ARE _NECESSARY_ FOR REPRODUCING THE ISSUE
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
    vim.cmd [[
" Decode URI encoded characters
function! DecodeURI(uri)
    return substitute(a:uri, '%\([a-fA-F0-9][a-fA-F0-9]\)', '\=nr2char("0x" . submatch(1))', "g")
endfunction

" Attempt to clear non-focused buffers with matching name
function! ClearDuplicateBuffers(uri)
echo 'a:uri: '. a:uri
echo 'expand("<amatch>"): '. expand("<amatch>")
echo 'DecodeURI(a:uri): '. DecodeURI(a:uri)

    " if our filename has URI encoded characters
    if DecodeURI(a:uri) !=# a:uri
        " wipeout buffer with URI decoded name - can print error if buffer in focus
        sil! exe "bwipeout " . fnameescape(DecodeURI(a:uri))
        " change the name of the current buffer to the URI decoded name
        exe "keepalt file " . fnameescape(DecodeURI(a:uri))
        " ensure we don't have any open buffer matching non-URI decoded name
        sil! exe "bwipeout " . fnameescape(a:uri)
    endif
endfunction

function! RzipOverride()
echo "overriding"
    " Disable vim-rzip's autocommands
    autocmd! zip BufReadCmd   zipfile:*,zipfile:*/*
    exe "au! zip BufReadCmd ".g:zipPlugin_ext

    " order is important here, setup name of new buffer correctly then fallback to vim-rzip's handling
    autocmd zip BufReadCmd   zipfile:*  call ClearDuplicateBuffers(expand("<amatch>"))
    autocmd zip BufReadCmd   zipfile:*  call rzip#Read(DecodeURI(expand("<amatch>")), 1)

    if has("unix")
        autocmd zip BufReadCmd   zipfile:*/*  call ClearDuplicateBuffers(expand("<amatch>"))
        autocmd zip BufReadCmd   zipfile:*/*  call rzip#Read(DecodeURI(expand("<amatch>")), 1)
    endif

    exe "au zip BufReadCmd ".g:zipPlugin_ext."  call rzip#Browse(DecodeURI(expand('<amatch>')))"
endfunction

call RzipOverride()
]]
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
