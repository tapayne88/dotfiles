local colors = require 'colors'
local app_icons = require 'helpers.app_icons'

local docker = sbar.add('item', 'widgets.docker', {
  position = 'right',
  icon = {
    font = 'sketchybar-app-font:Regular:16.0',
    y_offset = 1,
  },
  label = { padding_left = 0, padding_right = 0 },
  update_freq = 180,
  drawing = false,
})

local function update_docker_status()
  sbar.exec('ps aux | grep -v grep | grep -c -i docker', function(docker_pid)
    local drawing = false

    if docker_pid ~= '0' then
      drawing = true
    end

    docker:set {
      icon = {
        string = app_icons['Docker Desktop'],
      },
      drawing = drawing,
    }
  end)
end

update_docker_status()
