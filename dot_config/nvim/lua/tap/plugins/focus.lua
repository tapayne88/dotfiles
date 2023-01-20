return {
  'beauwilliams/focus.nvim',
  config = function()
    require('focus').setup {
      signcolumn = false,
      excluded_filetypes = { 'fugitive', 'git' },
    }
    require('tap.utils').keymap('n', '<leader>ft', ':FocusToggle<CR>', {
      description = '[Focus] Toggle window focusing',
    })
  end,
}
