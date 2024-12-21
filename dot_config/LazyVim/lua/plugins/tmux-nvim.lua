-- Seemless vim <-> tmux navigation
return {
  "aserowy/tmux.nvim",
  event = "VeryLazy",
  keys = {
    { "<c-h>", [[<cmd>lua require("tmux").resize_left()<cr>]] },
    { "<c-j>", [[<cmd>lua require("tmux").resize_down()<cr>]] },
    { "<c-k>", [[<cmd>lua require("tmux").resize_up()<cr>]] },
    { "<c-l>", [[<cmd>lua require("tmux").resize_right()<cr>]] },
  },
  opts = {
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
  },
}
