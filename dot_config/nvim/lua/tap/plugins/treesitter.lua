-- better syntax highlighting
return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufReadPost',
    build = ':TSUpdate',
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
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
          'terraform',
          'tsx',
          'typescript',
          'vim',
          'yaml',
        },
        highlight = {
          enable = true,
          disable = function(_, buf)
            local filepath = vim.api.nvim_buf_get_name(buf)

            local is_file_minified =
              require('tap.utils').check_file_minified(filepath)

            if is_file_minified then
              vim.notify(
                'Suspected minified file, disabling treesitter',
                vim.log.levels.INFO,
                { title = 'treesitter.nvim' }
              )
              require('tap.utils').logger.info(
                'disabled treesitter for file ',
                filepath
              )
            end

            return is_file_minified
          end,
        },
        matchup = { enable = true },
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
        },
      }
    end,
  },

  -- playground for illustrating the AST treesitter builds
  {
    'nvim-treesitter/playground',
    cmd = { 'TSPlayground', 'TSPlaygroundToggle' },
  },
}
