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

  highlight('DiffAdd', { gui = 'None' })
  highlight('DiffDelete', { gui = 'None' })
end)
