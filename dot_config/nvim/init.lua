require('tap.globals')
require('tap.plugins')
require('tap.settings')
require('tap.colours')
require('tap.auto')
require('tap.keymap')

vim.cmd [[
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
]]
