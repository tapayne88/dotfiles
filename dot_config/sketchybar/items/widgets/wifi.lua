local settings = require 'settings'
local colors = require 'colors'
local icons = require 'icons'

local wifi = sbar.add('item', 'widgets.wifi', {
  position = 'right',
  icon = {
    font = {
      style = settings.font.style_map['Regular'],
      size = 14.0,
    },
    color = colors.bg1,
    padding_left = 8,
    padding_right = 8,
    drawing = false,
  },
  label = { drawing = false },
  update_freq = 180,
})

wifi:subscribe({ 'routine', 'wifi_change' }, function()
  sbar.exec("scutil --nwi | grep address | sed 's/.*://' | tr -d ' ' | head -1", function(ip_address)
    sbar.exec(os.getenv 'HOME' .. '/.local/bin/check-vpn-connected', function(_, exit_code)
      local color
      local icon

      local is_vpn = exit_code == 0

      if is_vpn then
        color = colors.palette.green
        icon = icons.wifi.vpn
      elseif ip_address ~= '' then
        color = colors.palette.blue
        icon = icons.wifi.connected
      else
        color = colors.white
        icon = '󰖪'
        icon = icons.wifi.disconnected
      end

      wifi:set {
        icon = {
          string = icon,
          drawing = true,
        },
        background = {
          color = color,
        },
      }
    end)
  end)
end)
