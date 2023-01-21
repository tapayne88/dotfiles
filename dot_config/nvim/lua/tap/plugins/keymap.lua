-- keymap plugins
return {
  'mrjones2014/legendary.nvim',
  dependencies = {
    'folke/which-key.nvim',
  },
  config = function()
    require('which-key').setup {}
    require('legendary').setup {}

    require('tap.utils').nnoremap('<leader>p', function()
      require('legendary').find 'keymaps'
    end, {
      description = 'Legendary keymaps',
    })
  end,
}
