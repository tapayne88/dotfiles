return {
  -- Searchable keymaps
  {
    'mrjones2014/legendary.nvim',
    config = function()
      require('legendary').setup {}

      require('tap.utils').nnoremap('<leader>p', function()
        require('legendary').find 'keymaps'
      end, {
        description = 'Legendary keymaps',
      })
    end,
  },

  -- Discover keymaps
  {
    'folke/which-key.nvim',
    config = function()
      require('which-key').setup {}
    end,
  },

  -- Smarter folding
  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      vim.opt.foldcolumn = '1'
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
      vim.opt.foldenable = true

      -- TODO: Remove numbers from foldcolumn
      -- see https://github.com/kevinhwang91/nvim-ufo/issues/4
      vim.opt.fillchars:append 'foldopen:'
      vim.opt.fillchars:append 'foldclose:'

      require('ufo').setup {
        provider_selector = function()
          return { 'treesitter', 'indent' }
        end,
      }
    end,
  },

  -- file explorer
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v2.x',
    cmd = 'Neotree',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'kyazdani42/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    init = function()
      require('tap.utils').nnoremap(
        '<leader>ex',
        ':Neotree reveal<CR>',
        { description = 'Open neotree at current file' }
      )
    end,
    config = function()
      local apply_user_highlights = require('tap.utils').apply_user_highlights
      local highlight = require('tap.utils').highlight

      vim.g.neo_tree_remove_legacy_commands = 1

      require('neo-tree').setup {
        enable_diagnostics = false,
        window = {
          position = 'current',
          mappings = {
            ['w'] = 'open',
            ['s'] = 'open_split',
            ['v'] = 'open_vsplit',
          },
        },
        default_component_configs = {
          git_status = {
            symbols = {
              added = '',
              modified = '',
              deleted = '',
              renamed = '',
              untracked = '',
              ignored = '',
              unstaged = '',
              staged = '',
              conflict = '',
            },
          },
        },
        filesystem = {
          bind_to_cwd = false,
        },
      }

      apply_user_highlights('Neotree', function()
        highlight('NeoTreeDimText', { link = 'Comment', force = true })
        highlight('NeoTreeGitConflict', { link = 'Warnings', force = true })
        highlight(
          'NeoTreeGitUntracked',
          { link = 'NvimTreeGitNew', force = true }
        )
      end)
    end,
  },

  -- Highlight same words
  {
    'RRethy/vim-illuminate',
    event = 'BufReadPost',
    opts = { delay = 200 },
    config = function(_, opts)
      require('illuminate').configure(opts)

      local nnoremap = require('tap.utils').nnoremap

      nnoremap(']]', function()
        require('illuminate').goto_next_reference(false)
      end, { description = 'Next Reference' })
      nnoremap('[[', function()
        require('illuminate').goto_prev_reference(false)
      end, { description = 'Prev Reference' })
    end,
    keys = {
      ']]',
      '[[',
    },
  },

  -- persistent terminals
  {
    'akinsho/toggleterm.nvim',
    cmd = 'ToggleTerm',
    keys = { '<leader>tt' },
    config = function()
      local tmap = require('tap.utils').tmap

      require('toggleterm').setup {
        open_mapping = [[<leader>tt]],
        insert_mappings = false,
        shade_terminals = false,
      }

      -- Utilise tmux.nvim's bindings for changing windows
      tmap('<C-h>', [[<C-\><C-n><C-h>]])
      tmap('<C-j>', [[<C-\><C-n><C-j>]])
      tmap('<C-k>', [[<C-\><C-n><C-k>]])
      tmap('<C-l>', [[<C-\><C-n><C-l>]])
    end,
  },
}
