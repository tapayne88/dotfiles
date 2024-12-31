-- whizzy command-p launcher
return {
  'nvim-telescope/telescope.nvim',
  lazy = true,
  dependencies = {
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-file-browser.nvim',
    'nvim-telescope/telescope-live-grep-args.nvim',
    {
      'nvim-telescope/telescope-smart-history.nvim',
      dependencies = { 'kkharji/sqlite.lua' },
    },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'natecraddock/telescope-zf-native.nvim', lazy = true },
  },
  cmd = 'Telescope',
  init = function()
    --------------
    -- Internal --
    --------------
    vim.keymap.set('n', '<leader>ts', function()
      require('telescope.builtin').builtin { include_extensions = true }
    end, { desc = 'Give me Telescope!' })

    vim.keymap.set('n', '<leader>,', function()
      require('telescope.builtin').buffers {
        sorter = require('telescope').extensions['zf-native'].native_zf_scorer(),
        sort_lastused = true,
        sort_mru = true,
        show_all_buffers = true,
        selection_strategy = 'closest',
      }
    end, { desc = 'List buffers' })

    -- stylua: ignore start
    vim.keymap.set('n', '<leader>gh', '<cmd>Telescope help_tags<CR>',       { desc = 'Help tags' })
    vim.keymap.set('n', '<leader>:',  '<cmd>Telescope command_history<CR>', { desc = 'Command history' })
    vim.keymap.set('n', '<leader>p',  '<cmd>Telescope commands<CR>',        { desc = 'Neovim commands' })
    vim.keymap.set('n', '<leader>k',  '<cmd>Telescope keymaps<CR>',         { desc = 'Search keymaps' })
    -- stylua: ignore end

    ---------
    -- Git --
    ---------
    vim.keymap.set('n', '<leader>fg', function()
      require('telescope.builtin').git_files { use_git_root = false }
    end, { desc = 'Git files (cwd)' })

    vim.keymap.set('n', '<leader>fw', function()
      local root = require('tap.utils').root_pattern { 'package.json', '.git' }(vim.fn.expand '%:p:h')
      local root_path = require('plenary.path'):new(root)

      if not root_path:exists() then
        vim.notify('Failed to find workspace root', vim.log.levels.WARN, { title = 'telescope' })
        return
      end

      local cwd = vim.loop.cwd()
      local title = root_path:normalize() == '.' and vim.fs.basename(cwd) or root_path:make_relative(cwd)

      require('telescope.builtin').git_files {
        use_git_root = false,
        cwd = root_path.filename,
        prompt_title = title,
      }
    end, { desc = 'Git files (monorepo workspace)' })

    -- stylua: ignore start
    vim.keymap.set('n', '<leader>fG', '<cmd>Telescope git_files<CR>',     { desc = 'Git files (Root)' })
    vim.keymap.set('n', '<leader>gB', '<cmd>Telescope git_branches<CR>',  { desc = 'Git branches' })
    -- stylua: ignore end

    -----------
    -- Files --
    -----------
    vim.keymap.set('n', '<leader>ff', function()
      require('telescope.builtin').find_files { hidden = true }
    end, { desc = 'Find files (cwd)' })

    vim.keymap.set('n', '<leader>fb', function()
      require('telescope').extensions.file_browser.file_browser {
        cwd = vim.fn.expand '%:p:h',
        hidden = true,
      }
    end, { desc = 'File browser (current file)' })

    vim.keymap.set('n', '<leader>fB', function()
      require('telescope').extensions.file_browser.file_browser { hidden = true }
    end, { desc = 'File browser (cwd)' })

    vim.keymap.set('n', '<leader>fH', function()
      require('telescope').extensions.file_browser.file_browser {
        cwd = '~',
        hidden = true,
      }
    end, { desc = 'File browser ($HOME)' })

    vim.keymap.set('n', '<leader>fr', function()
      require('telescope.builtin').oldfiles {
        cwd = vim.loop.cwd(),
      }
    end, { desc = 'Recent files (Root)' })

    ------------
    -- Search --
    ------------

    -- All praise to this
    -- https://github.com/nvim-telescope/telescope.nvim/issues/1923#issuecomment-1122642431
    local function getVisualSelection()
      vim.cmd 'noau normal! "vy"'
      local text = vim.fn.getreg 'v'
      vim.fn.setreg('v', {})

      text = string.gsub(text, '\n', '')
      if #text > 0 then
        return text
      else
        return ''
      end
    end

    local search_opts = {
      prompt_title = 'Ripgrep',
      layout_strategy = 'vertical',
      path_display = { 'shorten', shorten = 2 },
    }

    vim.keymap.set('n', '<leader>/', function()
      require('telescope').extensions.live_grep_args.live_grep_args(search_opts)
    end, { desc = 'Grep (Root)' })

    vim.keymap.set('n', '<leader>sw', function()
      require('telescope').extensions.live_grep_args.live_grep_args(vim.tbl_extend('error', search_opts, {
        default_text = vim.fn.expand '<cword>',
      }))
    end, { desc = 'Search word' })

    vim.keymap.set('v', '<leader>sw', function()
      require('telescope').extensions.live_grep_args.live_grep_args(vim.tbl_extend('error', search_opts, {
        default_text = getVisualSelection(),
      }))
    end, { desc = 'Search word' })

    require('tap.utils.lsp').on_attach(function(_, bufnr)
      -- stylua: ignore start
      vim.keymap.set('n', 'gD', '<cmd>Telescope lsp_definitions<CR>', { buffer = bufnr, desc = '[LSP] Go to definition' })
      vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<CR>',  { buffer = bufnr, desc = '[LSP] Get references' })
      -- stylua: ignore end
    end)
  end,
  config = function()
    local actions = require 'telescope.actions'
    local lga_actions = require 'telescope-live-grep-args.actions'

    local yank_selected_entry = function(prompt_bufnr)
      local action_state = require 'telescope.actions.state'
      local entry_display = require 'telescope.pickers.entry_display'

      local picker = action_state.get_current_picker(prompt_bufnr)
      local manager = picker.manager

      local selection_row = picker:get_selection_row()
      local entry = manager:get_entry(picker:get_index(selection_row))
      local display, _ = entry_display.resolve(picker, entry)

      actions.close(prompt_bufnr)

      vim.fn.setreg('+', display)
    end

    --- Disable treesitter for files that look to be minified
    local buffer_previewer_maker_custom = function(filepath, bufnr, opts)
      opts = opts or {}

      filepath = vim.fn.expand(filepath)

      local is_file_minified = require('tap.utils').check_file_minified(filepath)

      if is_file_minified then
        require('tap.utils').logger.info('disabled treesitter in telescope preview for ', filepath)
      end

      require('telescope.previewers').buffer_previewer_maker(
        filepath,
        bufnr,
        vim.tbl_deep_extend('force', opts, { preview = { treesitter = not is_file_minified } })
      )
    end

    require('telescope').setup {
      defaults = {
        prompt_prefix = '❯ ',
        theme = 'center',
        layout_strategy = 'flex', -- let telescope figure out what to do given the space
        mappings = {
          i = {
            -- Allow selection splitting
            ['<c-s>'] = actions.select_horizontal,
            -- Cycle through history
            ['<Up>'] = actions.cycle_history_prev,
            ['<Down>'] = actions.cycle_history_next,
            -- Allow refining of telescope results
            ['<c-f>'] = actions.to_fuzzy_refine,
            ['<c-t>'] = function(...)
              return require('trouble.providers.telescope').open_with_trouble(...)
            end,

            ['<c-y>'] = yank_selected_entry,
          },
          n = {
            -- Allow selection splitting
            ['<c-s>'] = actions.select_horizontal,
            -- Reestablish insert mode mappings
            ['<c-p>'] = actions.move_selection_previous,
            ['<c-n>'] = actions.move_selection_next,
            -- Cycle through history
            ['<Up>'] = actions.cycle_history_prev,
            ['<Down>'] = actions.cycle_history_next,
            ['<c-t>'] = function(...)
              return require('trouble.providers.telescope').open_with_trouble(...)
            end,

            ['<c-y>'] = yank_selected_entry,
          },
        },
        buffer_previewer_maker = buffer_previewer_maker_custom,
        preview = {
          timeout = 100,
          -- Need to disable treesitter in config to override default (true)
          -- The custom buffer_previewer_maker will detect when to use it
          treesitter = false,
        },
        path_display = { 'truncate' },
        dynamic_preview_title = true,
        cache_picker = {
          num_pickers = -1,
        },
        history = {
          path = vim.fn.stdpath 'data' .. '/telescope_history.sqlite3',
          limit = 100,
        },
      },
      extensions = {
        file_browser = {
          mappings = {
            ['i'] = {
              -- Allow selection splitting
              ['<c-s>'] = actions.select_horizontal,
            },
          },
        },
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = false,
          case_mode = 'smart_case',
        },
        ['zf-native'] = {
          file = {
            enable = true,
            highlight_results = true,
            match_filename = true,
          },
          generic = {
            enable = false,
            highlight_results = true,
            match_filename = false,
          },
        },
        live_grep_args = {
          auto_quoting = true,
          mappings = {
            i = {
              ['<C-k>'] = lga_actions.quote_prompt(),
              ['<C-i>'] = lga_actions.quote_prompt { postfix = ' --iglob ' },
            },
          },
        },
      },
    }

    require('telescope').load_extension 'file_browser'
    require('telescope').load_extension 'live_grep_args'
    require('telescope').load_extension 'smart_history'
    require('telescope').load_extension 'fzf'
    require('telescope').load_extension 'notify'
    require('telescope').load_extension 'zf-native'

    vim.opt.grepprg = table.concat(require('telescope.config').values.vimgrep_arguments, ' ')

    -- Setup borderless telescope layout
    require('tap.utils').apply_user_highlights('Telescope', function(hl, p)
      hl('TelescopeMatching', { fg = p.peach })

      hl('TelescopeSelectionCaret', { fg = p.flamingo, bg = p.surface1 })
      hl('TelescopeSelection', { fg = p.text, bg = p.surface1 })
      hl('TelescopeMultiSelection', { fg = p.text, bg = p.surface2 })

      hl('TelescopeTitle', { link = 'comment' })

      hl('TelescopePromptBorder', { fg = p.surface0, bg = p.surface0 })
      hl('TelescopePromptTitle', { fg = p.crust, bg = p.mauve })
      hl('TelescopePromptNormal', { fg = p.flamingo, bg = p.surface0 })

      hl('TelescopePreviewBorder', { fg = p.crust, bg = p.crust })
      hl('TelescopePreviewNormal', { fg = p.text, bg = p.crust })

      hl('TelescopeResultsBorder', { fg = p.mantle, bg = p.mantle })
      hl('TelescopeResultsNormal', { bg = p.mantle })
    end)
  end,
}
