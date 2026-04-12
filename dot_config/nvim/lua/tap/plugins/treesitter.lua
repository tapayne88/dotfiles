-- better syntax highlighting
return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufReadPost',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install {
        'bash',
        'c',
        'dockerfile',
        'go',
        'graphql',
        'gotmpl',
        'groovy',
        'helm',
        'html',
        'hurl',
        'java',
        'javascript',
        'jsdoc',
        'json',
        'json5',
        'jsonnet',
        'just',
        'kotlin',
        'lua',
        'make',
        'markdown',
        'markdown_inline',
        'nix',
        'php',
        'phpdoc',
        'python',
        'rust',
        'scala',
        'scss',
        'sql',
        'terraform',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
      }
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    event = 'VeryLazy',
    opts = { multiline_threshold = 3 },
    keys = {
      {
        '[c',
        function()
          require('treesitter-context').go_to_context(vim.v.count1)
        end,
        desc = 'Jump to context',
      },
    },
  },

  {
    'folke/ts-comments.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {},
    event = 'VeryLazy',
  },
}
