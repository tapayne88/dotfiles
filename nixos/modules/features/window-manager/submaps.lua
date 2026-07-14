local resizeValue = '30'
local mod = 'SUPER'

-- A completely native function leveraging the internal window.group state
local function get_group_position()
  local win = hl.get_active_window()
  if not win or not win.group then
    return nil, nil
  end

  local group = win.group
  -- If the group only has 1 window, treat it as a normal tiled layout
  if group.size <= 1 then
    return nil, nil
  end

  -- Match our current window's hardware address against the group's members array
  for index, group_win in ipairs(group.members) do
    if win.address == group_win.address then
      return index, group.size
    end
  end

  return nil, nil
end

--- ==========================================
--- SMART WINDOW SWITCHING (Super + h/j/k/l)
--- ==========================================

-- Focus Left: Cycle tab backward, or break out left if at the first tab
hl.bind(mod .. ' + h', function()
  local idx, total = get_group_position()
  if idx and idx > 1 then
    hl.dispatch(hl.dsp.group.prev())
  else
    hl.dispatch(hl.dsp.focus { direction = 'left' })
  end
end)

-- Focus Right: Cycle tab forward, or break out right if at the last tab
hl.bind(mod .. ' + l', function()
  local idx, total = get_group_position()
  if idx and idx < total then
    hl.dispatch(hl.dsp.group.next())
  else
    hl.dispatch(hl.dsp.focus { direction = 'right' })
  end
end)

-- Vertical focus shifts always step outside the horizontal tab layout
hl.bind(mod .. ' + k', hl.dsp.focus { direction = 'up' })
hl.bind(mod .. ' + j', hl.dsp.focus { direction = 'down' })

--- ==========================================
--- SMART WINDOW MOVING (Super + Shift + h/j/k/l)
--- ==========================================

-- Move Left: Shift tab position backward, or eject window left at the edge
hl.bind(mod .. ' + SHIFT + h', function()
  local idx, total = get_group_position()
  if idx and idx > 1 then
    hl.dispatch(hl.dsp.group.move_window { forward = false })
  else
    hl.dispatch(hl.dsp.window.move { direction = 'left', group_aware = true })
  end
end)

-- Move Right: Shift tab position forward, or eject window right at the edge
hl.bind(mod .. ' + SHIFT + l', function()
  local idx, total = get_group_position()
  if idx and idx < total then
    hl.dispatch(hl.dsp.group.move_window { forward = true })
  else
    hl.dispatch(hl.dsp.window.move { direction = 'right', group_aware = true })
  end
end)

-- Vertical shifts gracefully slice windows out of the tab bar up or down
hl.bind(mod .. ' + SHIFT + k', hl.dsp.window.move { direction = 'up', group_aware = true })
hl.bind(mod .. ' + SHIFT + j', hl.dsp.window.move { direction = 'down', group_aware = true })

--- ==========================================
--- WINDOW MODE SUBMAP
--- ==========================================

local submapNotificationId = 'string:x-canonical-private-synchronous:submap'
local submapWindowModeIdLocation = '$XDG_RUNTIME_DIR/hypr_submap.id'

hl.bind(mod .. ' + w', function()
  hl.exec_cmd(
    'notify-send --expire-time 0 --print-id --hint '
      .. submapNotificationId
      .. ' "Submap: Window Mode" "Use vim motions to manipulate windows"'
      .. ' > '
      .. submapWindowModeIdLocation
  )
  hl.dispatch(hl.dsp.submap 'window_mode')
end)

hl.define_submap('window_mode', function()
  -- Set repeating binds for resizing the active window.
  hl.bind('SHIFT + l', hl.dsp.window.resize { x = resizeValue, y = 0, relative = true }, { repeating = true })
  hl.bind('SHIFT + h', hl.dsp.window.resize { x = -resizeValue, y = 0, relative = true }, { repeating = true })
  hl.bind('SHIFT + k', hl.dsp.window.resize { x = 0, y = resizeValue, relative = true }, { repeating = true })
  hl.bind('SHIFT + j', hl.dsp.window.resize { x = 0, y = -resizeValue, relative = true }, { repeating = true })

  -- Bare keys (h,j,k,l) execute classic layout shuffles ignoring group tabs
  hl.bind(mod .. ' + h', hl.dsp.focus { direction = 'left' })
  hl.bind(mod .. ' + l', hl.dsp.focus { direction = 'right' })
  hl.bind(mod .. ' + k', hl.dsp.focus { direction = 'up' })
  hl.bind(mod .. ' + j', hl.dsp.focus { direction = 'down' })

  -- Catch Shift + directional keys too just in case muscle memory kicks in
  hl.bind(mod .. ' + SHIFT + h', hl.dsp.window.move { direction = 'left', group_aware = false })
  hl.bind(mod .. ' + SHIFT + l', hl.dsp.window.move { direction = 'right', group_aware = false })
  hl.bind(mod .. ' + SHIFT + k', hl.dsp.window.move { direction = 'up', group_aware = false })
  hl.bind(mod .. ' + SHIFT + j', hl.dsp.window.move { direction = 'down', group_aware = false })

  local clear = function()
    hl.exec_cmd(
      'notify-send --expire-time 1 --replace-id $(cat '
        .. submapWindowModeIdLocation
        .. ') --hint '
        .. submapNotificationId
        .. ' "Submap: Window Mode" "Exited"'
    )
    hl.dispatch(hl.dsp.submap 'reset')
  end

  hl.bind('Escape', clear)
  hl.bind('Return', clear)
end)
