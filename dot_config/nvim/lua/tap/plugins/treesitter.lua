local augroup = require('tap.utils').augroup

local parsers = require 'nvim-treesitter.parsers'
local configs = parsers.get_parser_configs()
local ts_fts = vim.tbl_map(function(ft)
  return configs[ft].filetype or ft
end, parsers.available_parsers())

augroup('TreesitterFolding', {
  {
    events = { 'Filetype' },
    targets = ts_fts,
    command = 'setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()',
  },
})

require('nvim-treesitter.configs').setup {
  context_commentstring = { enable = true },
  ensure_installed = {
    'bash',
    'c',
    'dockerfile',
    'go',
    'graphql',
    'html',
    'java',
    'javascript',
    'jsdoc',
    'json',
    'json5',
    'kotlin',
    'lua',
    'make',
    'nix',
    'php',
    'phpdoc',
    'python',
    'rust',
    'scala',
    'scss',
    'tsx',
    'typescript',
    'vim',
    'yaml',
  },
  highlight = { enable = true },
  matchup = { enable = true },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
  },
}
