require 'tap.globals'

-- Protect against module not being installed and preventing any further loading
tap.safe_call(function()
  require 'impatient'

  if vim.env.PROFILING == 'true' then
    require('impatient').enable_profile()
  end
end)

require 'tap.settings'
require 'tap.plugins'
require 'tap.colours'
require 'tap.auto'
require 'tap.keymap'
require 'tap.jest-nvim'
require 'tap.redir'

vim.cmd [[
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
]]
