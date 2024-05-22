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
          disable = function(_, bufnr)
            local status_ok, cache_value =
              pcall(vim.api.nvim_buf_get_var, bufnr, 'minified_detected')
            if status_ok then
              return cache_value
            end

            local file_minified =
              require('tap.utils').check_file_minified(bufnr)

            vim.api.nvim_buf_set_var(
              bufnr,
              'minified_detected',
              file_minified and 1 or 0
            )

            if file_minified then
              vim.notify(
                'Suspected minified file, disabling treesitter',
                vim.log.levels.INFO,
                { title = 'treesitter.nvim' }
              )
              require('tap.utils').logger.info(
                'disabled treesitter for file ',
                vim.api.nvim_buf_get_name(bufnr)
              )
            end

            return file_minified
          end,
        },
        matchup = { enable = true },
      }
    end,
  },
}
