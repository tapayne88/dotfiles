local colors = require 'colors'
local app_icons = require 'helpers.app_icons'

local docker = sbar.add('item', 'widgets.docker', {
  position = 'right',
  icon = {
    font = 'sketchybar-app-font:Regular:16.0',
    y_offset = 1,
    padding_left = 9,
    padding_right = 6,
    drawing = false,
  },
  label = { drawing = false },
  background = { color = colors.bg1, border_width = 0 },
  update_freq = 180,
  width = 0,
})

docker:subscribe({ 'routine' }, function()
  sbar.exec('ps aux | grep -v grep | grep -c Docker', function(docker_pid)
    local drawing = false

    if docker_pid ~= '0' then
      drawing = true
    end

    docker:set {
      icon = {
        string = app_icons['Docker Desktop'],
        drawing = drawing,
      },
      width = 'dynamic',
    }
  end)
end)
