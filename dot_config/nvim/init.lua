require('tap.globals')
require('tap.settings')
require('tap.plugins')
require('tap.colours')
require('tap.auto')
require('tap.keymap')
require('tap.jest-nvim')

vim.cmd [[
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
]]
