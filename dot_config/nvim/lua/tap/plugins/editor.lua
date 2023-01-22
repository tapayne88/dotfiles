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

  -- + & - in column for changed lines
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local keymap = require('tap.utils').keymap

      require('gitsigns').setup {
        trouble = true,
        preview_config = {
          -- Options passed to nvim_open_win
          border = 'rounded',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1,
        },
        on_attach = function()
          local gs = package.loaded.gitsigns

          -- Navigation
          keymap('n', ']h', function()
            if vim.wo.diff then
              return ']h'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true })

          keymap('n', '[h', function()
            if vim.wo.diff then
              return '[h'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true })

          -- Actions
          keymap(
            { 'n', 'v' },
            '<leader>hs',
            ':Gitsigns stage_hunk<CR>',
            { description = '[Git] Stage hunk' }
          )
          keymap(
            { 'n', 'v' },
            '<leader>hr',
            ':Gitsigns reset_hunk<CR>',
            { description = '[Git] Reset hunk' }
          )
          keymap(
            'n',
            '<leader>hS',
            gs.stage_buffer,
            { description = '[Git] Stage buffer' }
          )
          keymap(
            'n',
            '<leader>hu',
            gs.undo_stage_hunk,
            { description = '[Git] Undo staged hunk' }
          )
          keymap(
            'n',
            '<leader>hR',
            gs.reset_buffer,
            { description = '[Git] Reset buffer' }
          )
          keymap(
            'n',
            '<leader>hp',
            gs.preview_hunk,
            { description = '[Git] Preview hunk' }
          )
          keymap('n', '<leader>hb', function()
            gs.blame_line { full = true }
          end, { description = '[Git] Blame line' })
          keymap(
            'n',
            '<leader>tb',
            gs.toggle_current_line_blame,
            { description = '[Git] Blame current line virtual text' }
          )
          keymap(
            'n',
            '<leader>hd',
            gs.diffthis,
            { description = '[Git] Diff this' }
          )
          keymap('n', '<leader>hD', function()
            gs.diffthis '~'
          end, { description = '[Git] Diff this' })
          keymap(
            'n',
            '<leader>td',
            gs.toggle_deleted,
            { description = '[Git] Diff this against default branch' }
          )

          -- Text object
          keymap({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end,
      }
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

  -- better diagnostics list and others
  {
    'folke/trouble.nvim',
    dependencies = 'kyazdani42/nvim-web-devicons',
    cmd = { 'TroubleToggle', 'Trouble' },
    init = function()
      local nnoremap = require('tap.utils').nnoremap

      nnoremap(
        '<leader>xx',
        '<cmd>TroubleToggle<cr>',
        { description = '[Trouble] Toggle list' }
      )
      nnoremap(
        '<leader>xw',
        '<cmd>TroubleToggle workspace_diagnostics<cr>',
        { description = '[Trouble] LSP workspace diagnostics' }
      )
      nnoremap(
        '<leader>xd',
        '<cmd>TroubleToggle document_diagnostics<cr>',
        { description = '[Trouble] LSP document diagnostics' }
      )
      nnoremap(
        '<leader>xq',
        '<cmd>TroubleToggle quickfix<cr>',
        { description = '[Trouble] Quickfix list' }
      )
      nnoremap(
        '<leader>xl',
        '<cmd>TroubleToggle loclist<cr>',
        { description = '[Trouble] Location list' }
      )
      nnoremap(
        'gR',
        '<cmd>TroubleToggle lsp_references<cr>',
        { description = '[Trouble] LSP references' }
      )
    end,
    config = function()
      local lsp_symbols = require('tap.utils.lsp').symbols

      require('trouble').setup {
        signs = {
          error = lsp_symbols 'error',
          warning = lsp_symbols 'warning',
          hint = lsp_symbols 'hint',
          information = lsp_symbols 'info',
          other = lsp_symbols 'ok',
        },
      }
    end,
  },

  -- Window resizing on focus
  {
    'beauwilliams/focus.nvim',
    config = function()
      require('focus').setup {
        signcolumn = false,
        excluded_filetypes = { 'fugitive', 'git' },
      }
      require('tap.utils').keymap('n', '<leader>ft', ':FocusToggle<CR>', {
        description = '[Focus] Toggle window focusing',
      })
    end,
  },

  -- Toggle zoom in / out individual windows
  { 'dhruvasagar/vim-zoom', keys = '<C-w>m' },

  -- Simple plugin to easily resize windows
  {
    'simeji/winresizer',
    config = function()
      vim.g.winresizer_start_key = '<leader>w'
    end,
    keys = '<leader>w',
  },
}