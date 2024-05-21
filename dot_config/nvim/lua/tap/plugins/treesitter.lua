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
      }
    end,
  },
}
