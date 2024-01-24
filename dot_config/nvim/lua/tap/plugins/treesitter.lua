-- better syntax highlighting
return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- Pin while waiting on solution / workaround for nix issue
    -- https://github.com/NixOS/nixpkgs/issues/282927
    tag = 'v0.9.2',
    event = 'BufReadPost',
    build = ':TSUpdate',
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-context',
        opts = true,
      },
      {
        'JoosepAlviste/nvim-ts-context-commentstring',
        config = function()
          -- skip backwards compatibility routines and speed up loading
          vim.g.skip_ts_context_commentstring_module = true
        end,
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
