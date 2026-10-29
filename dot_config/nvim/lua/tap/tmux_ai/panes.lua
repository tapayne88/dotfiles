local config = require 'tap.tmux_ai.config'
local notify = require 'tap.tmux_ai.notify'

local backend = require('tap.tmux_ai.backends.' .. (require('tap.utils.mux').use_rex() and 'rex' or 'tmux'))

local M = {}

local state = {
  pane_id = nil,
}

---@return table[], string|nil
function M.list_panes()
  local ok, err = backend.available()
  if not ok then
    return {}, err
  end

  return backend.list_panes()
end

---@param patterns string[]
---@return string|nil, string|nil
local function resolve_pane_title(patterns)
  local panes, err = M.list_panes()
  if err then
    return nil, err
  end

  local matches = vim.tbl_filter(function(pane)
    local title = pane.title:lower()
    for _, pattern in ipairs(patterns) do
      if title:find(pattern:lower()) ~= nil then
        return true
      end
    end
    return false
  end, panes)

  if #matches == 0 then
    return nil, nil
  end

  if #matches > 1 then
    return nil, 'multiple panes match; pick a pane explicitly'
  end

  return matches[1].id, nil
end

---@param pane_id string an id, or a pane's name such as rex's short ID
---@return table|nil
local function find_pane(pane_id)
  local panes = M.list_panes()
  for _, pane in ipairs(panes) do
    if pane.id == pane_id or pane.name == pane_id then
      return pane
    end
  end

  return nil
end

---@param pane_id string
---@return boolean
function M.pane_exists(pane_id)
  return find_pane(pane_id) ~= nil
end

local function set_resolved_pane(pane_id)
  state.pane_id = pane_id
  return pane_id
end

---@return string|nil, string|nil
function M.resolve_target()
  local configured = config.options.target

  if state.pane_id and M.pane_exists(state.pane_id) then
    return state.pane_id, nil
  end

  if configured.pane_id and M.pane_exists(configured.pane_id) then
    return set_resolved_pane(configured.pane_id), nil
  end

  if configured.pane_titles and #configured.pane_titles > 0 then
    local pane_id, pane_err = resolve_pane_title(configured.pane_titles)
    if pane_id then
      return set_resolved_pane(pane_id), nil
    end

    if pane_err then
      return nil, pane_err
    end
  end

  return nil, nil
end

---@param pane_id string
---@return boolean, string|nil
function M.set_target(pane_id)
  if pane_id == nil or pane_id == '' then
    return false, 'pane id is required'
  end

  local pane = find_pane(pane_id)
  if not pane then
    return false, string.format('pane %s was not found', pane_id)
  end

  set_resolved_pane(pane.id)
  return true, nil
end

---@return string|nil, string|nil
function M.show_target()
  local pane_id, err = M.resolve_target()
  if not pane_id then
    return nil, err
  end

  local pane = find_pane(pane_id)
  if pane then
    return string.format('%s (%s, title=%s, cmd=%s)', pane.name, pane.location, pane.title, pane.command), nil
  end

  return pane_id, nil
end

local function ensure_target_with_picker(on_done)
  local pane_id, err = M.resolve_target()
  if pane_id then
    on_done(pane_id, nil)
    return
  end

  if err then
    notify.warn(err)
  end

  M.pick_target(function(selected_pane_id)
    if not selected_pane_id then
      on_done(nil, 'no TmuxAI pane selected')
      return
    end

    on_done(selected_pane_id, nil)
  end)
end

function M.pick_target(on_done)
  local panes, err = M.list_panes()
  if err then
    notify.error(err)
    return
  end

  vim.ui.select(panes, {
    prompt = 'Select TmuxAI pane',
    format_item = function(pane)
      local active = pane.active and '*' or ' '
      return string.format('%s %s %s [%s] %s', active, pane.name, pane.location, pane.command, pane.title)
    end,
  }, function(choice)
    if not choice then
      if type(on_done) == 'function' then
        on_done(nil)
      end
      return
    end

    set_resolved_pane(choice.id)
    notify.info(string.format('TmuxAI target set to %s', choice.name))
    if type(on_done) == 'function' then
      on_done(choice.id)
    end
  end)
end

---@param text string
---@param opts? { submit?: boolean }
---@param on_done? fun(ok: boolean, err: string|nil)
function M.send_text(text, opts, on_done)
  ensure_target_with_picker(function(pane_id, resolve_err)
    if not pane_id then
      if type(on_done) == 'function' then
        on_done(false, resolve_err)
      end
      return
    end

    if text == nil then
      if type(on_done) == 'function' then
        on_done(false, 'failed to send prompt: empty payload')
      end
      return
    end

    if type(text) ~= 'string' then
      text = tostring(text)
    end

    local paste_err = backend.paste(pane_id, text, config.options.send.use_bracketed_paste)
    if paste_err then
      if type(on_done) == 'function' then
        on_done(false, paste_err)
      end
      return
    end

    if opts == nil or opts.submit ~= false then
      local send_err = backend.send_key(pane_id, 'enter')
      if send_err then
        if type(on_done) == 'function' then
          on_done(false, send_err)
        end
        return
      end
    end

    if type(on_done) == 'function' then
      on_done(true, nil)
    end
  end)
end

---@param mode string
---@param on_done? fun(ok: boolean, err: string|nil)
function M.send_mode(mode, on_done)
  if mode == 'plan' or mode == 'ask' or mode == 'debug' or mode == 'shell' then
    M.send_text('/' .. mode, { submit = true }, on_done)
    return
  end

  if mode == 'toggle' then
    ensure_target_with_picker(function(pane_id, resolve_err)
      if not pane_id then
        if type(on_done) == 'function' then
          on_done(false, resolve_err)
        end
        return
      end

      local send_err = backend.send_key(pane_id, 'backtab')
      if send_err then
        if type(on_done) == 'function' then
          on_done(false, send_err)
        end
        return
      end

      if type(on_done) == 'function' then
        on_done(true, nil)
      end
    end)
    return
  end

  if type(on_done) == 'function' then
    on_done(false, string.format('unsupported mode %q', mode))
  end
end

return M
