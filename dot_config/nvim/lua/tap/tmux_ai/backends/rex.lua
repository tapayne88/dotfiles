local M = {}

local keys = {
  enter = 'enter',
  backtab = 'shift+tab',
}

-- Lists the blocks in the window holding this terminal, the rex equivalent
-- of `tmux list-panes` without -a
local list_panes_script = [[
local terminal = 'com.superlogical.terminal'
local view, err = rex.session.view {}
if err ~= nil then error(err, 0) end

local panes = {}
for _, window in ipairs(view.windows or {}) do
  local blocks, here = {}, false
  for _, layer in ipairs(window.layers or {}) do
    for _, block in ipairs(layer.blocks or {}) do
      blocks[#blocks + 1] = block
      here = here or block.block_id == rex.block_id
    end
  end

  if here then
    for _, block in ipairs(blocks) do
      local title = rex.block.call(terminal, 'title', { block_id = block.block_id })
      local process = rex.block.call(terminal, 'process', { block_id = block.block_id })
      local fg = process and (process.foreground or process.child)
      panes[#panes + 1] = {
        id = block.block_id,
        location = string.format('%s:%s.%s', view.label, window.label, block.label),
        title = title and title.title or '',
        command = fg and fg.name or '',
        active = block.block_id == window.focused_block_id,
      }
    end
  end
end
return panes
]]

local function rex_bin()
  if vim.env.REX_BIN_DIR then
    return vim.env.REX_BIN_DIR .. '/rex'
  end
  return 'rex'
end

local function run(args, opts)
  table.insert(args, 1, rex_bin())
  local result = vim.system(args, vim.tbl_extend('keep', opts or {}, { text = true })):wait()
  if result.code ~= 0 then
    local stderr = vim.trim(result.stderr or ''):gsub('^Error: ', '')
    return nil, stderr == '' and string.format('command failed: %s', table.concat(args, ' ')) or stderr
  end

  return result.stdout or '', nil
end

---@return boolean|nil, string|nil
function M.available()
  if vim.fn.executable(rex_bin()) ~= 1 then
    return nil, '`rex` executable not found'
  end

  if not vim.env.REX_SESSION then
    return nil, 'Neovim is not running inside rex'
  end

  return true, nil
end

---@return table[], string|nil
function M.list_panes()
  local stdout, err = run { 'do', '-e', list_panes_script }
  if not stdout then
    return {}, err
  end

  local ok, panes = pcall(vim.json.decode, stdout)
  if not ok or type(panes) ~= 'table' then
    return {}, 'failed to parse rex panes'
  end

  for _, pane in ipairs(panes) do
    -- Block IDs are long, so name panes by their last six characters, the
    -- short ID the rex CLI shows
    pane.name = pane.id:sub(-6)
  end

  return panes, nil
end

---@param id string
---@param text string
---@param bracketed boolean
---@return string|nil
function M.paste(id, text, bracketed)
  if not bracketed then
    -- Typed, as if the user had entered it
    local _, err = run({ 'send', '-b', id }, { stdin = text })
    return err
  end

  -- A paste event, which the terminal brackets when the program asked for
  -- bracketed paste, as tmux paste-buffer -p does
  local payload = vim.json.encode {
    block_id = id,
    event = { type = 'paste', payload = { text = text } },
  }
  local _, err = run({ 'api', 'call', '-s', vim.env.REX_SESSION, 'block.event', '-' }, { stdin = payload })
  return err
end

---@param id string
---@param key 'enter'|'backtab'
---@return string|nil
function M.send_key(id, key)
  local _, err = run { 'send-key', '-b', id, keys[key] }
  return err
end

return M
