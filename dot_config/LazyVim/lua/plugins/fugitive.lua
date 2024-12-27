-- Git integration ':Gstatus' etc.
return {
  'tpope/vim-fugitive',
  cmd = {
    'Git',
    'Gvdiffsplit',
    'Gedit',
    'Gread',
    'GDelete',
    'GRemove',
    'GRename',
    'GMove',
    'Gwrite',
    'Gclog',
    'GBrowse',
  },
  dependencies = {
    'tpope/vim-rhubarb', -- :GBrowse github
    'shumphrey/fugitive-gitlab.vim', -- :GBrowse gitlab
  },
  keys = function()
    -- stylua: ignore start
    return {
      { '<leader>ga', ':Git add %:p<CR><CR>',   desc = 'Git add file' },
      { '<leader>gs', ':Git<CR>',               desc = 'Git status' },
      { '<leader>gc', ':Git commit -v -q<CR>',  desc = 'Git commit' },
      { '<leader>gd', ':Gvdiffsplit<CR>',       desc = 'Git diff' },
      { '<leader>go', ':Git checkout<Space>',   desc = 'Git checkout' },
      { '<leader>gr', ':Gread<CR>',             desc = 'Git read' },
    }
    -- stylua: ignore end
  end,
  config = function()
    vim.g.fugitive_dynamic_colors = 0
    -- vim.g.github_enterprise_urls is set in .vimrc.local

    -- Stops fugitive files being left in buffer by removing all but currently visible
    vim.cmd 'autocmd BufReadPost fugitive://* set bufhidden=delete'
  end,
}
