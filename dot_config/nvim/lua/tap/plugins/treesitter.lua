-- better syntax highlighting
return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufReadPost',
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      {
        'nvim-treesitter/nvim-treesitter-context',
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
        opts = {},
        event = 'VeryLazy',
      },
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'bash',
          'c',
          'dockerfile',
          'go',
          'graphql',
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
      }
    end,
  },
}
