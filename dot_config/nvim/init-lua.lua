require 'tap.globals'

require 'tap.settings'
require 'tap.lazy' -- Plugins
require 'tap.theme'
require 'tap.auto'
require 'tap.keymap'
require 'tap.jest-nvim'
require 'tap.redir'

vim.cmd [[
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
]]
