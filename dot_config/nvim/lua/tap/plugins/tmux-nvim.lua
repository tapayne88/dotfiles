-- Seemless vim <-> tmux/rex navigation
-- tmux wins when nvim runs in tmux inside rex, as tmux owns the panes. Outside
-- both, tmux.nvim still provides plain C-hjkl split navigation.
local use_rex = vim.env.TMUX == nil and vim.env.REX_BLOCK ~= nil

-- netrw maps <C-l> to refresh, so rebind navigation in its buffers
local function netrw_navigation(nav)
  require('tap.utils').augroup('TmuxNvimNetrw', {
    {
      events = { 'Filetype' },
      pattern = { 'netrw' },
      callback = function()
        -- stylua: ignore start
        vim.keymap.set('n', '<C-h>', nav.move_left,   { buffer = 0, desc = 'Swap to split left' })
        vim.keymap.set('n', '<C-j>', nav.move_bottom, { buffer = 0, desc = 'Swap to split below' })
        vim.keymap.set('n', '<C-k>', nav.move_top,    { buffer = 0, desc = 'Swap to split above' })
        vim.keymap.set('n', '<C-l>', nav.move_right,  { buffer = 0, desc = 'Swap to split right' })
        -- stylua: ignore end
      end,
    },
  })
end

return {
  {
    'aserowy/tmux.nvim',
    cond = not use_rex,
    event = 'VeryLazy',
    config = function()
      require('tmux').setup {
        copy_sync = {
          -- enables copy sync. by default, all registers are synchronized.
          -- to control which registers are synced, see the `sync_*` options.
          enable = false,
        },
        navigation = {
          -- cycles to opposite pane while navigating into the border
          cycle_navigation = false,
          -- enables default keybindings (C-hjkl) for normal mode
          enable_default_keybindings = true,
          -- prevents unzoom tmux when navigating beyond vim border
          persist_zoom = true,
        },
        resize = {
          -- enables default keybindings (A-hjkl) for normal mode
          enable_default_keybindings = false,
        },
      }

      netrw_navigation(require 'tmux')
    end,
  },
  {
    -- virtual with its own dir, as lazy merges local plugins that share a dir
    -- (tmux_ai.lua uses stdpath('config'))
    name = 'tap-rex-nav',
    dir = vim.fn.stdpath 'config' .. '/tap-rex-nav',
    virtual = true,
    cond = use_rex,
    event = 'VeryLazy',
    config = function()
      local rex_nav = require 'tap.rex_nav'
      rex_nav.setup()
      netrw_navigation(rex_nav)
    end,
  },
}
