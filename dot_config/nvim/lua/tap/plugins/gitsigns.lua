local keymap = require('tap.utils').keymap

require('gitsigns').setup {
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'rounded',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1,
  },
  on_attach = function()
    local gs = package.loaded.gitsigns

    -- Navigation
    keymap('n', ']h', function()
      if vim.wo.diff then
        return ']h'
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return '<Ignore>'
    end, { expr = true })

    keymap('n', '[h', function()
      if vim.wo.diff then
        return '[h'
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return '<Ignore>'
    end, { expr = true })

    -- Actions
    keymap(
      { 'n', 'v' },
      '<leader>hs',
      ':Gitsigns stage_hunk<CR>',
      { description = '[Git] Stage hunk' }
    )
    keymap(
      { 'n', 'v' },
      '<leader>hr',
      ':Gitsigns reset_hunk<CR>',
      { description = '[Git] Reset hunk' }
    )
    keymap(
      'n',
      '<leader>hS',
      gs.stage_buffer,
      { description = '[Git] Stage buffer' }
    )
    keymap(
      'n',
      '<leader>hu',
      gs.undo_stage_hunk,
      { description = '[Git] Undo staged hunk' }
    )
    keymap(
      'n',
      '<leader>hR',
      gs.reset_buffer,
      { description = '[Git] Reset buffer' }
    )
    keymap(
      'n',
      '<leader>hp',
      gs.preview_hunk,
      { description = '[Git] Preview hunk' }
    )
    keymap('n', '<leader>hb', function()
      gs.blame_line { full = true }
    end, { description = '[Git] Blame line' })
    keymap(
      'n',
      '<leader>tb',
      gs.toggle_current_line_blame,
      { description = '[Git] Blame current line virtual text' }
    )
    keymap('n', '<leader>hd', gs.diffthis, { description = '[Git] Diff this' })
    keymap('n', '<leader>hD', function()
      gs.diffthis '~'
    end, { description = '[Git] Diff this' })
    keymap(
      'n',
      '<leader>td',
      gs.toggle_deleted,
      { description = '[Git] Diff this against default branch' }
    )

    -- Text object
    keymap({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end,
}
