-- Seemless vim <-> tmux navigation
return {
  'aserowy/tmux.nvim',
  config = function()
    local augroup = require('tap.utils').augroup
    local nnoremap = require('tap.utils').nnoremap

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

    augroup('TmuxNvimNetrw', {
      {
        events = { 'Filetype' },
        pattern = { 'netrw' },
        callback = function()
          nnoremap(
            '<C-h>',
            require('tmux').move_left,
            { buffer = 0, description = 'Swap to split left' }
          )
          nnoremap(
            '<C-j>',
            require('tmux').move_bottom,
            { buffer = 0, description = 'Swap to split below' }
          )
          nnoremap(
            '<C-k>',
            require('tmux').move_top,
            { buffer = 0, description = 'Swap to split above' }
          )
          nnoremap(
            '<C-l>',
            require('tmux').move_right,
            { buffer = 0, description = 'Swap to split right' }
          )
        end,
      },
    })
  end,
}
