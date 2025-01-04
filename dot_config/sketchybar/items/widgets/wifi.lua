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
    padding_right = 6,
  },
  label = { padding_left = 0, padding_right = 0 },
  update_freq = 180,
  drawing = false,
})

local function update_vpn_status()
  sbar.exec("scutil --nwi | grep address | sed 's/.*://' | tr -d ' ' | head -1", function(ip_address)
    sbar.exec(os.getenv 'HOME' .. '/.local/bin/check-vpn-connected', function(_, exit_code)
      local color
      local icon
      local drawing = false

      local is_vpn = exit_code == 0

      if is_vpn then
        color = colors.green
        icon = icons.wifi.vpn
        drawing = true
      elseif ip_address ~= '' then
        color = colors.blue
        icon = icons.wifi.connected
        drawing = true
      else
        color = colors.white
        icon = '󰖪'
        icon = icons.wifi.disconnected
        drawing = true
      end

      wifi:set {
        icon = {
          string = icon,
        },
        background = {
          color = color,
        },
        drawing = drawing,
      }
    end)
  end)
end

update_vpn_status()
wifi:subscribe({ 'wifi_change' }, update_vpn_status)
