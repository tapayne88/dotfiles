local color = require('tap.utils').color
local lsp_colors = require('tap.utils').lsp_colors
local apply_user_highlights = require('tap.utils').apply_user_highlights

apply_user_highlights('NvimScrollbar', function()
  require('scrollbar').setup {
    handle = { color = color { dark = 'nord1_gui', light = 'bg_highlight' } },
    marks = {
      Search = { color = color { dark = 'nord0_gui', light = 'bg' } },
      Error = { color = lsp_colors 'error' },
      Warn = { color = lsp_colors 'warning' },
      Info = { color = lsp_colors 'info' },
      Hint = { color = lsp_colors 'hint' },
      Misc = { color = color { dark = 'nord15_gui', light = 'purple' } },
    },
  }
end)
