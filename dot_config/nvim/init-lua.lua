require 'tap.globals'

require 'tap.settings'
require 'tap.lazy' -- Plugins
require 'tap.auto'
require 'tap.keymap'
require 'tap.jest-nvim'
require 'tap.redir'

require('tap.utils').notify_in_debug(
  -- Copied from https://github.com/nvim-lua/plenary.nvim/blob/253d34830709d690f013daf2853a9d21ad7accab/lua/plenary/log.lua#L57
  string.format('%s/%s.log', vim.api.nvim_call_function('stdpath', { 'cache' }), require('tap.utils').logger_scope),
  vim.log.levels.DEBUG,
  { title = require('tap.utils').logger_scope }
)

vim.cmd [[
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
]]
