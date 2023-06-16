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
  },
  cmd = 'Telescope',
  init = function()
    local nnoremap = require('tap.utils').nnoremap
    local vnoremap = require('tap.utils').vnoremap
    local root_pattern = require('tap.utils').root_pattern

    --------------
    -- Internal --
    --------------
    nnoremap('<leader>ts', function()
      require('telescope.builtin').builtin { include_extensions = true }
    end, { desc = 'Give me Telescope!' })
    nnoremap('<leader>l', function()
      require('telescope.builtin').buffers {
        sort_lastused = true,
        sort_mru = true,
        show_all_buffers = true,
        selection_strategy = 'closest',
      }
    end, { desc = 'List buffers' })
    nnoremap('<leader>gh', function()
      require('telescope.builtin').help_tags()
    end, { desc = 'Help tags' })
    nnoremap('<leader>ch', function()
      require('telescope.builtin').command_history()
    end, { desc = 'Command history' })
    nnoremap('<leader>tp', function()
      require('telescope.builtin').pickers()
    end, { desc = 'Past telescope pickers with state' })
    nnoremap('<leader>p', function()
      require('telescope.builtin').commands()
    end, { desc = 'Neovim commands' })

    ---------
    -- Git --
    ---------
    nnoremap('<leader>gf', function()
      require('telescope.builtin').git_files { use_git_root = false }
    end, { desc = 'Git files relative to pwd' })
    nnoremap('<leader>gF', function()
      require('telescope.builtin').git_files()
    end, { desc = 'All git files' })
    nnoremap('<leader>rf', function()
      local root = require('plenary.path'):new(
        root_pattern { 'package.json', '\\.git' }(vim.fn.expand '%:p:h')
      )
      require('telescope.builtin').git_files {
        use_git_root = false,
        cwd = root.filename,
        prompt_title = root:make_relative(vim.loop.cwd()),
      }
    end, { desc = 'Git files relative to current file' })
    nnoremap('<leader>gb', function()
      require('telescope.builtin').git_branches()
    end, { desc = 'Git branches' })

    -----------
    -- Files --
    -----------
    nnoremap('<leader>ff', function()
      require('telescope.builtin').find_files { hidden = true }
    end, { desc = 'Fuzzy file finder' })
    nnoremap('<leader>fb', function()
      require('telescope').extensions.file_browser.file_browser {
        cwd = vim.fn.expand '%:p:h',
        hidden = true,
      }
    end, { desc = 'File browser at current file' })
    nnoremap('<leader>fB', function()
      require('telescope').extensions.file_browser.file_browser { hidden = true }
    end, { desc = 'File browser at pwd' })
    nnoremap('<leader>fh', function()
      require('telescope').extensions.file_browser.file_browser {
        cwd = '~',
        hidden = true,
      }
    end, { desc = 'File browser at $HOME' })

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
    nnoremap('<leader>fg', function()
      require('telescope').extensions.live_grep_args.live_grep_args(search_opts)
    end, { desc = 'Search with ripgrep' })
    nnoremap('<leader>fw', function()
      require('telescope').extensions.live_grep_args.live_grep_args(
        vim.tbl_extend('error', search_opts, {
          default_text = vim.fn.expand '<cword>',
        })
      )
    end, { desc = 'Search current word with ripgrep' })
    vnoremap('<leader>fw', function()
      require('telescope').extensions.live_grep_args.live_grep_args(
        vim.tbl_extend('error', search_opts, {
          default_text = getVisualSelection(),
        })
      )
    end, { desc = 'Search current visual selection with ripgrep' })

    require('tap.utils.lsp').on_attach(function(_, bufnr)
      require('tap.utils').nnoremap(
        'gD',
        '<cmd>Telescope lsp_definitions<CR>',
        { buffer = bufnr, desc = '[LSP] Go to definition' }
      )
      require('tap.utils').nnoremap(
        'gr',
        '<cmd>Telescope lsp_references<CR>',
        { buffer = bufnr, desc = '[LSP] Get references' }
      )
    end)

    vim.api.nvim_create_user_command('Fw', function(args)
      local word = table.remove(args, 1)
      local search_dirs = args

      local search_args = #search_dirs > 0 and { search_dirs = search_dirs }
        or {}

      require('telescope.builtin').grep_string(
        vim.tbl_extend('error', search_args, {
          search = word,
          prompt_title = string.format('Grep: %s', word),
          use_regex = true,
        })
      )
    end, {
      desc = 'Search for a word in a list of directories',
      nargs = '+',
      complete = 'dir',
    })
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

      local is_file_minified =
        require('tap.utils').check_file_minified(filepath)

      if is_file_minified then
        require('tap.utils').logger.info(
          'disabled treesitter in telescope preview for ',
          filepath
        )
      end

      require('telescope.previewers').buffer_previewer_maker(
        filepath,
        bufnr,
        vim.tbl_deep_extend(
          'force',
          opts,
          { preview = { treesitter = not is_file_minified } }
        )
      )
    end

    local focus = require('telescope.actions.mt').transform_mod {
      split_nicely = function(prompt_bufnr)
        local action_state = require 'telescope.actions.state'
        local entry = action_state.get_selected_entry()

        actions.close(prompt_bufnr)
        require('focus').split_nicely(entry.filename)
      end,
    }

    require('telescope').setup {
      defaults = {
        prompt_prefix = '❯ ',
        layout_strategy = 'flex', -- let telescope figure out what to do given the space
        layout_config = { height = { padding = 5 }, preview_cutoff = 20 },
        mappings = {
          i = {
            -- Split nicely, inital
            ['<c-v>'] = focus.split_nicely,
            -- Allow selection splitting
            ['<c-s>'] = actions.select_horizontal,
            -- Cycle through history
            ['<Up>'] = actions.cycle_history_prev,
            ['<Down>'] = actions.cycle_history_next,
            -- Allow refining of telescope results
            ['<c-f>'] = actions.to_fuzzy_refine,
            ['<c-t>'] = function(...)
              return require('trouble.providers.telescope').open_with_trouble(
                ...
              )
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
              return require('trouble.providers.telescope').open_with_trouble(
                ...
              )
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
          override_file_sorter = true,
          case_mode = 'smart_case',
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

    vim.opt.grepprg =
      table.concat(require('telescope.config').values.vimgrep_arguments, ' ')

    -- Setup borderless telescope layout
    require('tap.utils').apply_user_highlights('Telescope', function(hl, p)
      hl('TelescopeMatching', { fg = p.peach })

      hl('TelescopeSelectionCaret', { fg = p.flamingo, bg = p.surface1 })
      hl('TelescopeSelection', { fg = p.text, bg = p.surface1 })
      hl('TelescopeMultiSelection', { fg = p.text, bg = p.surface2 })

      hl('TelescopeTitle', { fg = p.crust, bg = p.green })

      hl('TelescopePromptBorder', { fg = p.surface0, bg = p.surface0 })
      hl('TelescopePromptTitle', { fg = p.crust, bg = p.mauve })
      hl('TelescopePromptNormal', { fg = p.flamingo, bg = p.surface0 })

      hl('TelescopePreviewBorder', { fg = p.mantle, bg = p.mantle })
      hl('TelescopePreviewTitle', { fg = p.crust, bg = p.red })

      hl('TelescopeResultsBorder', { fg = p.mantle, bg = p.mantle })
      hl('TelescopeResultsNormal', { bg = p.mantle })
    end)
  end,
}
