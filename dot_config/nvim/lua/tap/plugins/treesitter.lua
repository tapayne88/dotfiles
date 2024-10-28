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
    opts = {
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
      },
      highlight = {
        enable = true,
      },
      matchup = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = {
            [']f'] = '@function.outer',
            [']c'] = '@class.outer',
            [']a'] = '@parameter.inner',
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            [']C'] = '@class.outer',
            [']A'] = '@parameter.inner',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[c'] = '@class.outer',
            ['[a'] = '@parameter.inner',
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[C'] = '@class.outer',
            ['[A'] = '@parameter.inner',
          },
        },
      },
    },
  },
}
