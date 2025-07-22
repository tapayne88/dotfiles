require 'tap.globals'

require 'tap.settings'
require 'tap.lazy' -- Plugins
require 'tap.auto'
require 'tap.keymap'
-- require 'tap.jest-nvim'
require 'tap.redir'

require('tap.utils').notify_in_debug(
  -- Copied from https://github.com/nvim-lua/plenary.nvim/blob/253d34830709d690f013daf2853a9d21ad7accab/lua/plenary/log.lua#L57
  string.format('%s/%s.log', vim.api.nvim_call_function('stdpath', { 'cache' }), require('tap.utils').logger_scope),
  vim.log.levels.DEBUG,
  { title = require('tap.utils').logger_scope }
)

local should_profile = os.getenv 'NVIM_PROFILE'
if should_profile then
  require('profile').instrument_autocmds()
  if should_profile:lower():match '^start' then
    require('profile').start '*'
  else
    require('profile').instrument '*'
  end
end

local function toggle_profile()
  local prof = require 'profile'
  if prof.is_recording() then
    prof.stop()
    vim.ui.input({ prompt = 'Save profile to:', completion = 'file', default = 'profile.json' }, function(filename)
      if filename then
        prof.export(filename)
        vim.notify(string.format('Wrote %s', filename))
      end
    end)
  else
    prof.start '*'
  end
end
vim.keymap.set('', '<f1>', toggle_profile)

vim.cmd [[
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
]]
