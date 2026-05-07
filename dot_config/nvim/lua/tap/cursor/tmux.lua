local config = require 'tap.cursor.config'
local notify = require 'tap.cursor.notify'

local M = {}

local state = {
  pane_id = nil,
}

local pane_format = table.concat({
  '#{pane_id}',
  '#{session_name}',
  '#{window_index}',
  '#{window_name}',
  '#{pane_index}',
  '#{pane_title}',
  '#{pane_current_command}',
  '#{?pane_active,1,0}',
}, '\t')

local function run(args, opts)
  local result = vim.system(args, vim.tbl_extend('keep', opts or {}, { text = true })):wait()
  if result.code ~= 0 then
    local stderr = vim.trim(result.stderr or '')
    return nil, stderr == '' and string.format('command failed: %s', table.concat(args, ' ')) or stderr
  end

  return result.stdout or '', nil
end

---@param text string
---@param buffer_name string
---@return string|nil
local function load_buffer_text(text, buffer_name)
  if text == nil then
    return 'failed to send prompt: empty payload'
  end

  if type(text) ~= 'string' then
    text = tostring(text)
  end

  local tmpfile = vim.fn.tempname()
  local lines = vim.split(text, '\n', { plain = true })

  local ok_write, write_err = pcall(vim.fn.writefile, lines, tmpfile, 'b')
  if not ok_write then
    return tostring(write_err)
  end

  local _, load_err = run { 'tmux', 'load-buffer', '-b', buffer_name, tmpfile }
  pcall(vim.fn.delete, tmpfile)

  return load_err
end

local function ensure_tmux()
  if vim.fn.executable 'tmux' ~= 1 then
    return nil, '`tmux` executable not found'
  end

  if not vim.env.TMUX then
    return nil, 'Neovim is not running inside tmux'
  end

  return true, nil
end

local function parse_list_panes(output)
  local panes = {}

  for line in vim.gsplit(vim.trim(output), '\n', { plain = true, trimempty = true }) do
    local fields = vim.split(line, '\t', { plain = true })
    if #fields == 8 then
      panes[#panes + 1] = {
        pane_id = fields[1],
        session_name = fields[2],
        window_index = fields[3],
        window_name = fields[4],
        pane_index = fields[5],
        pane_title = fields[6],
        pane_current_command = fields[7],
        pane_active = fields[8] == '1',
      }
    end
  end

  return panes
end

---@return table[], string|nil
function M.list_panes()
  local ok, err = ensure_tmux()
  if not ok then
    return {}, err
  end

  local stdout, list_err = run { 'tmux', 'list-panes', '-F', pane_format }
  if not stdout then
    return {}, list_err
  end

  return parse_list_panes(stdout), nil
end

local function resolve_pane_title(pane_title)
  local panes, err = M.list_panes()
  if err then
    return nil, err
  end

  local pattern = pane_title:lower()
  local matches = vim.tbl_filter(function(pane)
    return pane.pane_title:lower():find(pattern, 1, true) ~= nil
  end, panes)

  if #matches == 0 then
    return nil, nil
  end

  if #matches > 1 then
    return nil, string.format('multiple tmux panes match %q; pick a pane explicitly', pane_title)
  end

  return matches[1].pane_id, nil
end

---@param pane_id string
---@return boolean
function M.pane_exists(pane_id)
  local panes = M.list_panes()
  for _, pane in ipairs(panes) do
    if pane.pane_id == pane_id then
      return true
    end
  end

  return false
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

  if configured.pane_title and configured.pane_title ~= '' then
    local pane_id, pane_err = resolve_pane_title(configured.pane_title)
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

  if not M.pane_exists(pane_id) then
    return false, string.format('tmux pane %s was not found', pane_id)
  end

  set_resolved_pane(pane_id)
  return true, nil
end

---@return string|nil, string|nil
function M.show_target()
  local pane_id, err = M.resolve_target()
  if not pane_id then
    return nil, err
  end

  local panes = M.list_panes()
  for _, pane in ipairs(panes) do
    if pane.pane_id == pane_id then
      return string.format(
        '%s (%s:%s.%s, title=%s, cmd=%s)',
        pane.pane_id,
        pane.session_name,
        pane.window_index,
        pane.pane_index,
        pane.pane_title,
        pane.pane_current_command
      ),
        nil
    end
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
      on_done(nil, 'no Cursor tmux pane selected')
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
    prompt = 'Select Cursor tmux pane',
    format_item = function(pane)
      local active = pane.pane_active and '*' or ' '
      return string.format(
        '%s %s %s:%s.%s [%s] %s',
        active,
        pane.pane_id,
        pane.session_name,
        pane.window_index,
        pane.pane_index,
        pane.pane_current_command,
        pane.pane_title
      )
    end,
  }, function(choice)
    if not choice then
      if type(on_done) == 'function' then
        on_done(nil)
      end
      return
    end

    set_resolved_pane(choice.pane_id)
    notify.info(string.format('Cursor target set to %s', choice.pane_id))
    if type(on_done) == 'function' then
      on_done(choice.pane_id)
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

    local buffer_name = string.format('tap-cursor-%d', vim.loop.hrtime())
    local load_err = load_buffer_text(text, buffer_name)
    if load_err then
      if type(on_done) == 'function' then
        on_done(false, load_err)
      end
      return
    end

    local paste_args = { 'tmux', 'paste-buffer', '-t', pane_id, '-b', buffer_name, '-d' }
    if config.options.send.use_bracketed_paste then
      table.insert(paste_args, 3, '-p')
    end

    local _, paste_err = run(paste_args)
    if paste_err then
      if type(on_done) == 'function' then
        on_done(false, paste_err)
      end
      return
    end

    if opts == nil or opts.submit ~= false then
      local _, send_err = run { 'tmux', 'send-keys', '-t', pane_id, 'Enter' }
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

      local _, send_err = run { 'tmux', 'send-keys', '-t', pane_id, 'BTab' }
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
