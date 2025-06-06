local colors = require 'colors'
local settings = require 'settings'
local app_icons = require 'helpers.app_icons'

sbar.exec('aerospace list-workspaces --all | grep -v "^alt-"', function(spaces)
  for space_name in spaces:gmatch '[^\r\n]+' do
    local space = sbar.add('item', 'space.' .. space_name, {
      icon = {
        font = { family = settings.font },
        string = string.sub(space_name, 3),
        color = colors.white,
        highlight_color = colors.palette.red,
      },
      label = {
        padding_right = 18,
        color = colors.grey,
        highlight_color = colors.white,
        font = 'sketchybar-app-font:Regular:16.0',
      },
      padding_right = 1,
      padding_left = 1,
      background = {
        color = colors.bg1,
        border_width = 1,
        height = 26,
        border_color = colors.bg1,
      },
    })

    space:subscribe('aerospace_workspace_change', function(env)
      local selected = env.FOCUSED_WORKSPACE == space_name
      space:set {
        icon = { highlight = selected },
        label = { highlight = selected },
        background = { border_color = selected and colors.grey or colors.bg1 },
      }
    end)

    space:subscribe('mouse.clicked', function()
      sbar.exec('aerospace workspace ' .. space_name)
    end)

    space:subscribe('space_windows_change', function()
      sbar.exec(
        'aerospace list-windows --format %{app-name}:%{window-title} --workspace ' .. space_name .. ' | grep -v ":$"',
        function(windows)
          local icon_line = ''
          for app in windows:gmatch '[^\r\n]+' do
            local app_name = STR_SPLIT(app, ':')
            local lookup = app_icons[app_name[1]]
            local icon = ((lookup == nil) and app_icons['Default'] or lookup)
            icon_line = icon_line .. ' ' .. icon
          end

          sbar.animate('tanh', 10, function()
            space:set { label = icon_line }
          end)
        end
      )
    end)
  end
end)
