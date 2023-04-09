return {
  -- Searchable keymaps
  {
    'mrjones2014/legendary.nvim',
    config = function()
      require('legendary').setup {}

      require('tap.utils').nnoremap('<leader>k', function()
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

  -- Git integration ':Gstatus' etc.
  {
    'tpope/vim-fugitive',
    cmd = {
      'Git',
      'Gvdiff',
      'Gedit',
      'Gread',
      'GDelete',
      'GRemove',
      'GRename',
      'GMove',
      'Gwrite',
      'Gclog',
      'GBrowse',
    },
    dependencies = {
      'tpope/vim-rhubarb', -- :GBrowse github
      'shumphrey/fugitive-gitlab.vim', -- :GBrowse gitlab
    },
    init = function()
      local nnoremap = require('tap.utils').nnoremap
      local xnoremap = require('tap.utils').xnoremap

      nnoremap(
        '<leader>ga',
        ':Git add %:p<CR><CR>',
        { description = 'Git add file' }
      )
      nnoremap('<leader>gs', ':Git<CR>', { description = 'Git status' })
      nnoremap(
        '<leader>gc',
        ':Git commit -v -q<CR>',
        { description = 'Git commit' }
      )
      nnoremap('<leader>gt', ':Git commit -v -q %:p<CR>')
      nnoremap('<leader>gd', ':Gvdiff<CR>', { description = 'Git diff' })
      nnoremap('<leader>ge', ':Gedit<CR>')
      nnoremap('<leader>gr', ':Gread<CR>', { description = 'Git read' })
      nnoremap('<leader>gw', ':Gwrite<CR>', { description = 'Git write' })
      nnoremap('<leader>gl', ':Gclog<CR>', { description = 'Git log' })
      nnoremap(
        '<leader>go',
        ':Git checkout<Space>',
        { description = 'Git checkout' }
      )
      nnoremap(
        '<leader>gp',
        ':GBrowse<CR>',
        { description = 'Git browse file' }
      )
      xnoremap(
        '<leader>gp',
        ":'<,'>GBrowse<CR>",
        { description = 'Git browse visual selection' }
      )
    end,
    config = function()
      vim.g.fugitive_dynamic_colors = 0
      -- vim.g.github_enterprise_urls is set in .vimrc.local

      -- Stops fugitive files being left in buffer by removing all but currently visible
      vim.cmd 'autocmd BufReadPost fugitive://* set bufhidden=delete'
    end,
  },

  -- Smarter folding
  {
    'kevinhwang91/nvim-ufo',
    event = { 'BufReadPre', 'BufNewFile' },
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

      -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
      require('tap.utils').keymap('n', 'zR', require('ufo').openAllFolds)
      require('tap.utils').keymap('n', 'zM', require('ufo').closeAllFolds)

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
        ':Neotree toggle current<CR>',
        { description = 'Open neotree at current file' }
      )
    end,
    config = function()
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

      require('tap.utils').apply_user_highlights('Neotree', function(highlight)
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
      local lsp_symbol = require('tap.utils.lsp').symbol

      require('trouble').setup {
        signs = {
          error = lsp_symbol 'error',
          warning = lsp_symbol 'warning',
          hint = lsp_symbol 'hint',
          information = lsp_symbol 'info',
          other = lsp_symbol 'ok',
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
        excluded_filetypes = vim.tbl_flatten {
          '',
          'diff',
          'fugitive',
          'git',
          'undotree',
          require('tap.utils').dap_filetypes,
        },
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
    init = function()
      vim.g.winresizer_start_key = '<leader>w'
    end,
    cmd = {
      'WinResizerStartResize',
      'WinResizerStartMove',
      'WinResizerStartFocus',
    },
    keys = '<leader>w',
  },

  -- todo comments
  {

    'folke/todo-comments.nvim',
    cmd = { 'TodoTrouble', 'TodoTelescope' },
    event = 'BufReadPost',
    config = true,
    init = function()
      local keymap = require('tap.utils').keymap

      keymap('n', ']t', function()
        require('todo-comments').jump_next()
      end, { description = 'Next todo comment' })
      keymap('n', '[t', function()
        require('todo-comments').jump_prev()
      end, { description = 'Previous todo comment' })

      keymap(
        'n',
        '<leader>xt',
        '<cmd>TodoTrouble<cr>',
        { description = 'Todo (Trouble)' }
      )
      keymap(
        'n',
        '<leader>xT',
        '<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>',
        { description = 'Todo/Fix/Fixme (Trouble)' }
      )
      keymap(
        'n',
        '<leader>st',
        '<cmd>TodoTelescope<cr>',
        { description = 'Todo' }
      )
    end,
  },

  {
    'folke/persistence.nvim',
    event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    config = function()
      -- Prevent Persistence from saving a session for commit messages
      require('tap.utils').augroup('TapPersistence', {
        {
          events = { 'FileType' },
          targets = { 'gitcommit' },
          command = function()
            -- If there is only one buffer open then it's probably a commit
            -- message instance (which we don't want to save as the directories
            -- session)
            if #vim.api.nvim_list_bufs() == 1 then
              require('persistence').stop()
            end
          end,
        },
      })

      local excluded_filetypes = { 'fugitive' }

      require('persistence').setup {
        -- Close excluded filetype buffers before saving the session
        pre_save = function()
          for _, buf_hndl in ipairs(vim.api.nvim_list_bufs()) do
            -- Filter for loaded buffers
            if vim.api.nvim_buf_is_loaded(buf_hndl) then
              if
                vim.tbl_contains(
                  excluded_filetypes,
                  vim.api.nvim_buf_get_option(buf_hndl, 'filetype')
                )
              then
                require('tap.utils').logger.info(
                  string.format(
                    '[persistence.nvim] Deleting buffer %s before saving session',
                    vim.api.nvim_buf_get_name(buf_hndl)
                  )
                )
                vim.api.nvim_buf_delete(buf_hndl, {})
              end
            end
          end
        end,
      }
    end,
  },

  {
    'mbbill/undotree',
    config = function()
      require('tap.utils').keymap('n', '<leader>u', vim.cmd.UndotreeToggle)

      vim.opt.undofile = true
    end,
  },
}
