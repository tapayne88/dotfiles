-- better syntax highlighting
return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
    {
      'nvim-treesitter/playground',
      cmd = { 'TSPlayground', 'TSPlaygroundToggle' },
    }, -- playground for illustrating the AST treesitter builds
  },
  config = function()
    require('nvim-treesitter.configs').setup {
      context_commentstring = { enable = true },
      ensure_installed = {
        'bash',
        'c',
        'dockerfile',
        'go',
        'graphql',
        'help',
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
  end,
  build = ':TSUpdate',
}
