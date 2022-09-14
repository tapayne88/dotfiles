local nnoremap = require('tap.utils').nnoremap
local apply_user_highlights = require('tap.utils').apply_user_highlights
local highlight = require('tap.utils').highlight

vim.g.neo_tree_remove_legacy_commands = 1

require('neo-tree').setup {
  enable_diagnostics = false,
  window = {
    position = 'current',
    mappings = {
      ['w'] = 'open',
      ['s'] = 'open_split',
      ['v'] = 'open_vsplit',
    },
  },
  default_component_configs = {
    git_status = {
      symbols = {
        added = '',
        modified = '',
        deleted = '',
        renamed = '',
        untracked = '',
        ignored = '',
        unstaged = '',
        staged = '',
        conflict = '',
      },
    },
  },
  filesystem = {
    bind_to_cwd = false,
  },
}

apply_user_highlights('Neotree', function()
  highlight('NeoTreeDimText', { link = 'Comment', force = true })
  highlight('NeoTreeGitConflict', { link = 'Warnings', force = true })
  highlight('NeoTreeGitUntracked', { link = 'NvimTreeGitNew', force = true })
end)

nnoremap(
  '<leader>ex',
  ':Neotree reveal<CR>',
  { description = 'Open neotree at current file' }
)
