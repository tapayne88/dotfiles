local actions = require 'telescope.actions'
local trouble = require 'trouble.providers.telescope'
local nnoremap = require('tap.utils').nnoremap
local vnoremap = require('tap.utils').vnoremap
local highlight = require('tap.utils').highlight
local color = require('tap.utils').color
local apply_user_highlights = require('tap.utils').apply_user_highlights
local command = require('tap.utils').command

require('telescope').setup {
  defaults = {
    prompt_prefix = '❯ ',
    layout_strategy = 'flex', -- let telescope figure out what to do given the space
    layout_config = { height = { padding = 5 }, preview_cutoff = 20 },
    mappings = {
      i = {
        -- Allow selection splitting
        ['<c-s>'] = actions.select_horizontal,
        -- Cycle through history
        ['<Up>'] = actions.cycle_history_prev,
        ['<Down>'] = actions.cycle_history_next,
        -- Allow refining of telescope results
        ['<c-f>'] = actions.to_fuzzy_refine,
        ['<c-t>'] = trouble.open_with_trouble,
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
        ['<c-t>'] = trouble.open_with_trouble,
      },
    },
    borderchars = {
      prompt = { '█', '▌', '▀', '▐', '▐', '▌', '▘', '▝' },
      results = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
      preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    },
    preview = { timeout = 100, treesitter = false },
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
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
  },
}

require('telescope').load_extension 'file_browser'
require('telescope').load_extension 'live_grep_args'
require('telescope').load_extension 'smart_history'
require('telescope').load_extension 'fzf'

--------------
-- Internal --
--------------
nnoremap('<leader>ts', function()
  require('telescope.builtin').builtin { include_extensions = true }
end, { description = 'Give me Telescope!' })
nnoremap('<leader>l', function()
  require('telescope.builtin').buffers {
    sort_lastused = true,
    sort_mru = true,
    show_all_buffers = true,
    selection_strategy = 'closest',
  }
end, { description = 'List buffers' })
nnoremap('<leader>gh', function()
  require('telescope.builtin').help_tags()
end, { description = 'Help tags' })
nnoremap('<leader>ch', function()
  require('telescope.builtin').command_history()
end, { description = 'Command history' })
nnoremap('<leader>tp', function()
  require('telescope.builtin').pickers()
end, { description = 'Past telescope pickers with state' })

---------
-- Git --
---------
nnoremap('<leader>gf', function()
  require('telescope.builtin').git_files { use_git_root = false }
end, { description = 'Git files relative to pwd' })
nnoremap('<leader>gF', function()
  require('telescope.builtin').git_files()
end, { description = 'All git files' })
nnoremap('<leader>rf', function()
  require('telescope.builtin').git_files {
    use_git_root = false,
    cwd = vim.fn.expand '%:p:h',
  }
end, { description = 'Git files relative to current file' })
nnoremap('<leader>gb', function()
  require('telescope.builtin').git_branches()
end, { description = 'Git branches' })

-----------
-- Files --
-----------
nnoremap('<leader>ff', function()
  require('telescope.builtin').find_files { hidden = true }
end, { description = 'Fuzzy file finder' })
nnoremap('<leader>fb', function()
  require('telescope').extensions.file_browser.file_browser {
    cwd = vim.fn.expand '%:p:h',
    hidden = true,
  }
end, { description = 'File browser at current file' })
nnoremap('<leader>fB', function()
  require('telescope').extensions.file_browser.file_browser { hidden = true }
end, { description = 'File browser at pwd' })
nnoremap('<leader>fh', function()
  require('telescope').extensions.file_browser.file_browser {
    cwd = '~',
    hidden = true,
  }
end, { description = 'File browser at $HOME' })

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
end, { description = 'Search with ripgrep' })
nnoremap('<leader>fw', function()
  require('telescope').extensions.live_grep_args.live_grep_args(
    vim.tbl_extend('error', search_opts, {
      default_text = vim.fn.expand '<cword>',
    })
  )
end, { description = 'Search current word with ripgrep' })
vnoremap('<leader>fw', function()
  require('telescope').extensions.live_grep_args.live_grep_args(
    vim.tbl_extend('error', search_opts, {
      default_text = getVisualSelection(),
    })
  )
end, { description = 'Search current visual selection with ripgrep' })

apply_user_highlights('Telescope', function()
  local border_colors = { dark = 'nord2_gui', light = 'blue0' }

  highlight('TelescopeBorder', { guifg = color(border_colors) })
  highlight('TelescopePromptBorder', {
    guifg = color(border_colors),
    guibg = color { dark = 'nord0_gui', light = 'none' },
  })
  highlight('TelescopePreviewBorder', { guifg = color(border_colors) })
  highlight('TelescopeResultsBorder', { guifg = color(border_colors) })

  highlight('TelescopePromptTitle', {
    guifg = color { dark = 'nord2_gui', light = 'bg' },
    guibg = color { dark = 'nord7_gui', light = 'none' },
  })
  highlight('TelescopePromptNormal', {
    guifg = color { dark = 'nord4_gui', light = 'fg' },
    guibg = color(border_colors),
  })
  highlight('TelescopePromptCounter', {
    guifg = color { dark = 'nord5_gui', light = 'fg' },
    guibg = color(border_colors),
  })

  highlight('TelescopePreviewTitle', {
    guifg = color { dark = 'nord2_gui', light = 'bg' },
    guibg = color { dark = 'nord14_gui', light = 'green' },
  })
  highlight('TelescopeResultsTitle', {
    guifg = color { dark = 'nord4_gui', light = 'fg' },
    guibg = color { dark = 'nord3_gui', light = 'blue0' },
  })

  highlight(
    'TelescopeMatching',
    { guifg = color { dark = 'nord13_gui', light = 'yellow' } }
  )
end)

command {
  'Fw',
  function(args)
    local word = table.remove(args, 1)
    local search_dirs = args

    local search_args = #search_dirs > 0 and { search_dirs = search_dirs } or {}

    require('telescope.builtin').grep_string(
      vim.tbl_extend('error', search_args, {
        search = word,
        prompt_title = string.format('Grep: %s', word),
        use_regex = true,
      })
    )
  end,
  nargs = '+',
  extra = '-complete=dir',
}
