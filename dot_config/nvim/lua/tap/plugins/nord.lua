local nord = require 'nord.colors'
local highlight = require('tap.utils').highlight
local color = require('tap.utils').color
local apply_user_highlights = require('tap.utils').apply_user_highlights

apply_user_highlights('Nord', function()
  highlight('Search', {
    guibg = color { dark = 'nord9_gui', light = 'blue2' },
    guifg = color { dark = 'nord0_gui', light = 'bg' },
    gui = 'NONE',
  })
  highlight('IncSearch', {
    guibg = color { dark = 'nord9_gui', light = 'blue2' },
    guifg = color { dark = 'nord0_gui', light = 'bg' },
    gui = 'NONE',
  })
  highlight('FloatBorder', {
    guifg = color { dark = 'nord9_gui', light = 'blue0' },
    guibg = color { dark = 'nord0_gui', light = 'none' },
  })

  -- Treesitter overrides
  highlight('TSInclude', { gui = 'italic', cterm = 'italic' })
  highlight('TSOperator', { gui = 'italic', cterm = 'italic' })
  highlight('TSKeyword', { gui = 'italic', cterm = 'italic' })

  highlight('gitmessengerHeader', { link = 'Identifier' })
  highlight('gitmessengerHash', { link = 'Comment' })
  highlight('gitmessengerHistory', { link = 'Constant' })
  highlight('gitmessengerPopupNormal', { link = 'CursorLine' })

  -- g:nord_uniform_diff_background from arcticicestudio/nord-vim
  highlight(
    'DiffAdd',
    { guifg = nord.nord14_gui, guibg = nord.nord1_gui, gui = nord.none }
  )
  highlight(
    'DiffChange',
    { guifg = nord.nord13_gui, guibg = nord.nord1_gui, gui = nord.none }
  )
  highlight(
    'DiffDelete',
    { guifg = nord.nord11_gui, guibg = nord.nord1_gui, gui = nord.none }
  )
  highlight(
    'DiffText',
    { guifg = nord.nord15_gui, guibg = nord.nord1_gui, gui = nord.none }
  )
end)
