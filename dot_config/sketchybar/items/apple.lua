local colors = require 'colors'
local icons = require 'icons'

-- Padding item required because of bracket
sbar.add('item', { width = 5 })

sbar.add('item', {
  icon = {
    font = { size = 16.0 },
    string = icons.apple,
    padding_right = 8,
    padding_left = 8,
  },
  label = { drawing = false },
  background = {
    color = colors.bg2,
    border_color = colors.black,
    border_width = 1,
  },
  padding_left = 1,
  padding_right = 1,
})

-- Padding item required because of bracket
sbar.add('item', { width = 7 })
