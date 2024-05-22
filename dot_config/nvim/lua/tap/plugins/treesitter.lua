-- better syntax highlighting
return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufReadPost',
    build = ':TSUpdate',
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-context',
        opts = true,
      },
      {
        'folke/ts-comments.nvim',
        opts = {},
        event = 'VeryLazy',
      },
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'bash',
          'c',
          'dockerfile',
          'go',
          'graphql',
          'groovy',
          'html',
          'hurl',
          'java',
          'javascript',
          'jsdoc',
          'json',
          'json5',
          'jsonnet',
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
          'terraform',
          'tsx',
          'typescript',
          'vim',
          'vimdoc',
          'yaml',
        },
        highlight = {
          enable = true,
        },
        matchup = { enable = true },
      }
    end,
  },
}
