return {
  'kevinhwang91/nvim-ufo',
  dependencies = {
    'kevinhwang91/promise-async',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    vim.opt.foldcolumn = '1'
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99
    vim.opt.foldenable = true

    -- TODO: Remove numbers from foldcolumn
    -- see https://github.com/kevinhwang91/nvim-ufo/issues/4
    vim.opt.fillchars:append 'foldopen:'
    vim.opt.fillchars:append 'foldclose:'

    require('ufo').setup {
      provider_selector = function()
        return { 'treesitter', 'indent' }
      end,
    }
  end,
}
