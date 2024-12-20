return {
  -- Discover keymaps
  {
    'folke/which-key.nvim',
    opts = true,
  },

  -- + & - in column for changed lines
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPost',
    dependencies = { 'nvim-lua/plenary.nvim', 'petertriho/nvim-scrollbar' },
    config = function()
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
          vim.keymap.set('n', ']h', function()
            if vim.wo.diff then
              return ']h'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = '[Git] Next hunk' })

          vim.keymap.set('n', '[h', function()
            if vim.wo.diff then
              return '[h'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = '[Git] Previous hunk' })

          -- Actions
          -- stylua: ignore start
          vim.keymap.set({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', { desc = '[Git] Stage hunk' })
          vim.keymap.set({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', { desc = '[Git] Reset hunk' })

          vim.keymap.set('n', '<leader>hS', gs.stage_buffer,              { desc = '[Git] Stage buffer' })
          vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk,           { desc = '[Git] Undo staged hunk' })
          vim.keymap.set('n', '<leader>hR', gs.reset_buffer,              { desc = '[Git] Reset buffer' })
          vim.keymap.set('n', '<leader>tb', gs.toggle_current_line_blame, { desc = '[Git] Blame current line virtual text' })
          vim.keymap.set('n', '<leader>hd', gs.diffthis,                  { desc = '[Git] Diff this' })
          -- stylua: ignore end

          vim.keymap.set('n', '<leader>hD', function()
            gs.diffthis '~'
          end, { desc = '[Git] Diff this' })
          vim.keymap.set(
            'n',
            '<leader>td',
            gs.toggle_deleted,
            { desc = '[Git] Diff this against default branch' }
          )

          -- Text object
          vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end,
      }
      require('scrollbar.handlers.gitsigns').setup()
    end,
  },

  -- Git integration ':Gstatus' etc.
  {
    'tpope/vim-fugitive',
    cmd = {
      'Git',
      'Gvdiffsplit',
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
      -- stylua: ignore start
      vim.keymap.set('n', '<leader>ga', ':Git add %:p<CR><CR>',       { desc = 'Git add file' })
      vim.keymap.set('n', '<leader>gs', ':Git<CR>',                   { desc = 'Git status' })
      vim.keymap.set('n', '<leader>gc', ':Git commit -v -q<CR>',      { desc = 'Git commit' })
      vim.keymap.set('n', '<leader>gt', ':Git commit -v -q %:p<CR>')
      vim.keymap.set('n', '<leader>gd', ':Gvdiffsplit<CR>',           { desc = 'Git diff' })
      vim.keymap.set('n', '<leader>ge', ':Gedit<CR>')
      vim.keymap.set('n', '<leader>gr', ':Gread<CR>',                 { desc = 'Git read' })
      vim.keymap.set('n', '<leader>gw', ':Gwrite<CR>',                { desc = 'Git write' })
      vim.keymap.set('n', '<leader>gl', ':Gclog<CR>',                 { desc = 'Git log' })
      vim.keymap.set('n', '<leader>go', ':Git checkout<Space>',       { desc = 'Git checkout' })
      vim.keymap.set('n', '<leader>gp', ':GBrowse!<CR>',              { desc = 'Git browse file' })
      vim.keymap.set('x', '<leader>gp', ":'<,'>GBrowse!<CR>",         { desc = 'Git browse visual selection' })
      -- stylua: ignore end
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
    event = { 'VeryLazy' },
    dependencies = {
      'kevinhwang91/promise-async',
      'nvim-treesitter/nvim-treesitter',
    },
    init = function()
      vim.opt.foldcolumn = '1'
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
      vim.opt.foldenable = true

      vim.opt.fillchars:append 'foldopen:'
      vim.opt.fillchars:append 'foldclose:'
    end,
    config = function()
      -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

      require('ufo').setup {
        provider_selector = function()
          return { 'treesitter', 'indent' }
        end,
      }
    end,
  },

  -- Neovim file explorer: edit your filesystem like a buffer
  {
    'stevearc/oil.nvim',
    -- don't lazy load so it works when opening directories with `nvim .`
    lazy = false,
    opts = {
      default_file_explorer = true,
      columns = {
        'icon',
        'permissions',
      },
      buf_options = {
        buflisted = true,
        bufhidden = 'hide',
      },
      use_default_keymaps = false,
      keymaps = {
        ['g?'] = 'actions.show_help',
        ['<CR>'] = 'actions.select',
        ['<C-v>'] = 'actions.select_vsplit',
        ['<C-s>'] = 'actions.select_split',
        ['<C-t>'] = 'actions.select_tab',
        ['<C-p>'] = 'actions.preview',
        ['<C-c>'] = 'actions.close',
        ['-'] = 'actions.parent',
        ['_'] = 'actions.open_cwd',
        ['`'] = 'actions.cd',
        ['~'] = 'actions.tcd',
        ['gs'] = 'actions.change_sort',
        ['gx'] = 'actions.open_external',
        ['g.'] = 'actions.toggle_hidden',
        ['g\\'] = 'actions.toggle_trash',
      },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    init = function()
      vim.keymap.set(
        'n',
        '-',
        require('oil').open,
        { desc = 'Open parent directory' }
      )
    end,
  },

  -- Highlight same words
  {
    'RRethy/vim-illuminate',
    event = 'BufReadPost',
    config = function()
      require('illuminate').configure { delay = 200 }

      -- stylua: ignore start
      vim.keymap.set('n', ']]', function() require('illuminate').goto_next_reference(false) end, { desc = 'Next Reference' })
      vim.keymap.set('n', '[[', function() require('illuminate').goto_prev_reference(false) end, { desc = 'Prev Reference' })
      -- stylua: ignore end
    end,
  },

  -- persistent terminals
  {
    'akinsho/toggleterm.nvim',
    cmd = 'ToggleTerm',
    keys = { '<leader>tt' },
    config = function()
      require('toggleterm').setup {
        open_mapping = [[<leader>tt]],
        insert_mappings = false,
        shade_terminals = false,
      }

      -- Utilise tmux.nvim's bindings for changing windows
      vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-h>]])
      vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-j>]])
      vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-k>]])
      vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-l>]])
    end,
  },

  -- better diagnostics list and others
  {
    'folke/trouble.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    cmd = { 'TroubleToggle', 'Trouble' },
    init = function()
      -- stylua: ignore start
      vim.keymap.set('n', '<leader>xx', '<cmd>TroubleToggle<cr>',                 { desc = '[Trouble] Toggle list' })
      vim.keymap.set('n', '<leader>xw', '<cmd>Trouble workspace_diagnostics<cr>', { desc = '[Trouble] LSP workspace diagnostics' })
      vim.keymap.set('n', '<leader>xd', '<cmd>Trouble document_diagnostics<cr>',  { desc = '[Trouble] LSP document diagnostics' })
      vim.keymap.set('n', '<leader>xq', '<cmd>Trouble quickfix<cr>',              { desc = '[Trouble] Quickfix list' })
      vim.keymap.set('n', '<leader>xl', '<cmd>Trouble loclist<cr>',               { desc = '[Trouble] Location list' })
      vim.keymap.set('n', 'gR', '<cmd>Trouble lsp_references<cr>',                { desc = '[Trouble] LSP references' })
      -- stylua: ignore end
    end,
    opts = {
      use_diagnostic_signs = true,
    },
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
      -- stylua: ignore start
      vim.keymap.set('n', ']t', require('todo-comments').jump_next, { desc = 'Next todo comment' })
      vim.keymap.set('n', '[t', require('todo-comments').jump_prev, { desc = 'Previous todo comment' })

      vim.keymap.set('n', '<leader>xt', '<cmd>TodoTrouble<cr>',                         { desc = 'Todo (Trouble)' })
      vim.keymap.set('n', '<leader>xT', '<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>', { desc = 'Todo/Fix/Fixme (Trouble)' })
      vim.keymap.set('n', '<leader>st', '<cmd>TodoTelescope<cr>',                       { desc = 'Todo' })
      -- stylua: ignore start
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
          pattern = { 'gitcommit', 'gitrebase' },
          callback = function()
            -- If there is only one buffer open then it's probably a commit
            -- message instance (which we don't want to save as the directories
            -- session)
            if #vim.api.nvim_list_bufs() == 1 then
              require('persistence').stop()
            end
          end,
        },
      })

      local excluded_filetypes = {
        'fugitive', -- git status with fugitive (causes errors when restored)
        'git', -- git push / fetch with fugitive and pushed into buffer with ctrl-d
        'gitcommit', -- git commit messages
      }

      require('persistence').setup {
        -- Close excluded filetype buffers before saving the session
        pre_save = function()
          for _, buf_hndl in ipairs(vim.api.nvim_list_bufs()) do
            -- Filter for loaded buffers
            if vim.api.nvim_buf_is_loaded(buf_hndl) then
              if
                vim.tbl_contains(
                  excluded_filetypes,
                  vim.api.nvim_get_option_value('filetype', { buf = buf_hndl })
                )
              then
                require('tap.utils').logger.info(
                  string.format(
                    '[persistence.nvim] Deleting buffer %s before saving session',
                    vim.api.nvim_buf_get_name(buf_hndl)
                  )
                )
                vim.api.nvim_buf_delete(buf_hndl, { force = true })
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
      vim.keymap.set(
        'n',
        '<leader>u',
        vim.cmd.UndotreeToggle,
        { desc = 'Toggle undo tree' }
      )

      vim.opt.undofile = true
    end,
  },

  {
    'luukvbaal/statuscol.nvim',
    config = function()
      local builtin = require 'statuscol.builtin'
      require('statuscol').setup {
        relculright = true,
        segments = {
          { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
          {
            sign = { name = { 'Diagnostic' }, maxwidth = 1 },
            click = 'v:lua.ScSa',
          },
          { text = { builtin.lnumfunc }, click = 'v:lua.ScLa' },
          {
            sign = { namespace = { 'gitsigns' }, colwidth = 1 },
            click = 'v:lua.ScSa',
          },
          {
            sign = { name = { '.*' }, maxwidth = 2, colwidth = 1 },
            click = 'v:lua.ScSa',
          },
        },
      }
    end,
  },

  {
    'lewis6991/hover.nvim',
    lazy = true,
    init = function()
      --stylua: ignore start
      vim.keymap.set('n', 'K', require('hover').hover,          { desc = 'hover.nvim' })
      vim.keymap.set('n', 'gK', require('hover').hover_select,  { desc = 'hover.nvim (select)' })
      --stylua: ignore end
    end,
    config = function()
      require('hover').setup {
        init = function()
          require 'hover.providers.lsp'
          require 'hover.providers.man'
          require 'hover.providers.dictionary'
        end,
        preview_opts = {
          border = 'rounded',
        },
        -- Whether the contents of a currently open hover window should be moved
        -- to a :h preview-window when pressing the hover keymap.
        preview_window = false,
        title = true,
      }
    end,
  },

  {
    'NvChad/nvim-colorizer.lua',
    lazy = true,
    init = function()
      -- Prevent loading of builtin colorizer commands
      vim.g.loaded_colorizer = true

      local opts = {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = false, -- "Name" codes like Blue or blue
        RRGGBBAA = false, -- #RRGGBBAA hex codes
        AARRGGBB = false, -- 0xAARRGGBB hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = false, -- CSS hsl() and hsla() functions
        css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        -- Available modes for `mode`: foreground, background,  virtualtext
        mode = 'background', -- Set the display mode.
        -- Available methods are false / true / "normal" / "lsp" / "both"
        -- True is same as normal
        tailwind = false, -- Enable tailwind colors
        -- parsers can contain values used in |user_default_options|
        sass = { enable = false, parsers = { 'css' } }, -- Enable sass colors
        virtualtext = '■',
        -- update color values even if buffer is not focused
        -- example use: cmp_menu, cmp_docs
        always_update = false,
      }

      vim.api.nvim_create_user_command('ColorizerToggle', function()
        local colorizer = require 'colorizer'

        if colorizer.is_buffer_attached(0) then
          colorizer.detach_from_buffer(0)
          vim.notify(
            'Disabled colorizing for buffer',
            vim.log.levels.INFO,
            { title = 'Colorizer' }
          )
        else
          colorizer.attach_to_buffer(0, opts)
          vim.notify(
            'Enabled colorizing for buffer',
            vim.log.levels.INFO,
            { title = 'Colorizer' }
          )
        end
      end, { desc = 'Toggle colorizer' })
    end,
  },

  {
    'chrishrb/gx.nvim',
    keys = { { 'gx', '<cmd>Browse<cr>', mode = { 'n', 'x' } } },
    cmd = { 'Browse' },
    init = function()
      vim.g.netrw_nogx = 1 -- disable netrw gx
    end,
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = true, -- default settings
    submodules = false, -- not needed, submodules are required only for tests
  },

  {
    'tanvirtin/vgit.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- TODO: Remove pinning when Blame line bug fixed
    commit = 'b94967a0fff2b14a637cdf618ec7335739dc8f89',
    init = function()
      -- stylua: ignore start
      vim.keymap.set('n', '<leader>hp', require('vgit').buffer_hunk_preview,  { desc = '[Git] Preview hunk' })
      vim.keymap.set('n', '<leader>hb', require('vgit').buffer_blame_preview, { desc = '[Git] Blame line' })
      -- stylua: ignore end
    end,
    opts = {
      settings = {
        live_blame = {
          enabled = false,
        },
        live_gutter = {
          enabled = false,
        },
        authorship_code_lens = {
          enabled = false,
        },
        scene = {
          diff_preference = 'split',
        },
      },
    },
  },

  {
    'jellydn/hurl.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    ft = 'hurl',
    init = function()
      require('tap.utils').augroup('hurl.nvim', {
        {
          events = { 'BufRead', 'BufNewFile' },
          pattern = { '*.hurl' },
          callback = function()
            vim.opt_local.filetype = 'hurl'
          end,
        },
      })
    end,
    opts = {
      -- Show debugging info
      debug = false,
      -- Show notification on run
      show_notification = false,
      -- Show response in popup or split
      mode = 'split',
      -- Default formatter
      formatters = {
        json = { 'jq' },
        html = {
          'prettier',
          '--parser',
          'html',
        },
      },
    },
    keys = {
      -- Run API request
      { '<leader>A', '<cmd>HurlRunner<CR>', desc = 'Run All requests' },
      { '<leader>a', '<cmd>HurlRunnerAt<CR>', desc = 'Run Api request' },
      {
        '<leader>te',
        '<cmd>HurlRunnerToEntry<CR>',
        desc = 'Run Api request to entry',
      },
      { '<leader>tm', '<cmd>HurlToggleMode<CR>', desc = 'Hurl Toggle Mode' },
      {
        '<leader>tv',
        '<cmd>HurlVerbose<CR>',
        desc = 'Run Api in verbose mode',
      },
      -- Run Hurl request in visual mode
      { '<leader>h', ':HurlRunner<CR>', desc = 'Hurl Runner', mode = 'v' },
    },
  },

  {
    'm4xshen/hardtime.nvim',
    event = 'BufReadPost',
    enabled = false,
    dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
    opts = function()
      return {
        max_count = 10,
        disable_mouse = false,
        disabled_filetypes = vim
          .iter({
            require('hardtime.config').config.disabled_filetypes,
            'dbout',
            'dbui',
          })
          :flatten()
          :totable(),
      }
    end,
    init = function()
      vim.api.nvim_create_user_command('HardtimeToggle', function()
        local ht = require 'hardtime'

        if ht.is_plugin_enabled then
          ht.disable()
          require('precognition').hide()
        else
          ht.enable()
          require('precognition').show()
        end
      end, { desc = 'Toggle hardtime and precognition' })
    end,
  },

  {
    'tris203/precognition.nvim',
    event = 'VeryLazy',
    opts = {
      startVisible = true,
      showBlankVirtLine = true,
      highlightColor = { link = 'Comment' },
    },
  },

  {
    'tapayne88/bigfile.nvim',
    branch = 'byte-filesize',
    event = 'BufReadPre',
    opts = {
      filesize = 2 * math.pow(1024, 2), -- 2MiB
      filesize_unit = 'bytes',
      pattern = function(bufnr, filesize)
        local ok, file_contents = pcall(function()
          return vim.fn.readfile(vim.api.nvim_buf_get_name(bufnr))
        end)

        if not ok then
          return
        end

        local file_length = #file_contents
        local filetype = vim.filetype.match { buf = bufnr }
        if filesize / file_length > 5000 and filetype == 'javascript' then
          vim.notify(
            'Suspected minified file, disabling features',
            vim.log.levels.INFO,
            { title = 'bigfile.nvim' }
          )
          return true
        end
      end,
    },
  },

  -- SQL Plugins
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true },
      {
        'kristijanhusak/vim-dadbod-completion',
        ft = { 'sql', 'mysql', 'plsql' },
        lazy = true,
      },
      'hrsh7th/nvim-cmp',
    },
    cmd = {
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1
    end,
    config = function()
      require('cmp').setup.filetype({ 'sql' }, {
        sources = {
          { name = 'vim-dadbod-completion' },
          { name = 'buffer' },
        },
      })
    end,
  },

  {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
      require('mini.ai').setup()
    end,
  },
}
