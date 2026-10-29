local M = {}

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

local keys = {
  enter = 'Enter',
  backtab = 'BTab',
}

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

---@return boolean|nil, string|nil
function M.available()
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
        id = fields[1],
        name = fields[1],
        location = string.format('%s:%s.%s', fields[2], fields[3], fields[5]),
        title = fields[6],
        command = fields[7],
        active = fields[8] == '1',
      }
    end
  end

  return panes
end

---@return table[], string|nil
function M.list_panes()
  local stdout, err = run { 'tmux', 'list-panes', '-F', pane_format }
  if not stdout then
    return {}, err
  end

  return parse_list_panes(stdout), nil
end

---@param id string
---@param text string
---@param bracketed boolean
---@return string|nil
function M.paste(id, text, bracketed)
  local buffer_name = string.format('tap-tmux-ai-%d', vim.loop.hrtime())
  local load_err = load_buffer_text(text, buffer_name)
  if load_err then
    return load_err
  end

  local paste_args = { 'tmux', 'paste-buffer', '-t', id, '-b', buffer_name, '-d' }
  if bracketed then
    table.insert(paste_args, 3, '-p')
  end

  local _, paste_err = run(paste_args)
  return paste_err
end

---@param id string
---@param key 'enter'|'backtab'
---@return string|nil
function M.send_key(id, key)
  local _, err = run { 'tmux', 'send-keys', '-t', id, keys[key] }
  return err
end

return M
