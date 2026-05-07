local config = require 'tap.cursor.config'
local commands = require 'tap.cursor.commands'
local tmux = require 'tap.cursor.tmux'
local uv = vim.uv or vim.loop

local M = {}

local setup_done = false
local file_watchers = {}
local pending_checktime = {}

---@param arg number|{buf?: number}|nil
local function maybe_checktime(arg)
  local bufnr = arg
  if type(arg) == 'table' then
    bufnr = arg.buf
  end

  local mode = vim.api.nvim_get_mode().mode
  if mode == 'c' then
    return
  end

  if type(bufnr) == 'number' then
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    local bufinfo = vim.fn.getbufinfo(bufnr)
    if type(bufinfo) ~= 'table' or #bufinfo == 0 then
      return
    end

    if bufinfo[1].loaded ~= 1 then
      return
    end

    if vim.bo[bufnr].modified then
      return
    end

    pcall(vim.cmd, string.format('silent! checktime %d', bufnr))
    return
  end

  pcall(vim.cmd, 'silent! checktime')
end

local function stop_buffer_watch(bufnr)
  local handle = file_watchers[bufnr]
  if not handle then
    return
  end

  pcall(handle.stop, handle)
  pcall(handle.close, handle)
  file_watchers[bufnr] = nil
  pending_checktime[bufnr] = nil
end

local function can_watch_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  if vim.bo[bufnr].buftype ~= '' then
    return false
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == nil or path == '' then
    return false
  end

  return true
end

local function start_buffer_watch(bufnr)
  stop_buffer_watch(bufnr)
  if not can_watch_buffer(bufnr) then
    return
  end

  local handle = uv.new_fs_event()
  if not handle then
    return
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  local ok = pcall(handle.start, handle, path, {}, function(err)
    if err then
      return
    end

    if pending_checktime[bufnr] then
      return
    end

    pending_checktime[bufnr] = true
    vim.schedule(function()
      pending_checktime[bufnr] = nil
      maybe_checktime(bufnr)
    end)
  end)

  if not ok then
    pcall(handle.close, handle)
    return
  end

  file_watchers[bufnr] = handle
end

local function create_file_watch_autocmds()
  local group = vim.api.nvim_create_augroup('TapCursorRefreshWatch', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufFilePost', 'BufWritePost', 'BufEnter' }, {
    group = group,
    callback = function(args)
      start_buffer_watch(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
    group = group,
    callback = function(args)
      stop_buffer_watch(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      for bufnr in pairs(file_watchers) do
        stop_buffer_watch(bufnr)
      end
    end,
  })

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    start_buffer_watch(bufnr)
  end
end

local function create_refresh_autocmds()
  local group = vim.api.nvim_create_augroup('TapCursorRefresh', { clear = true })

  for _, event in ipairs(config.options.refresh.events) do
    vim.api.nvim_create_autocmd(event, {
      group = group,
      callback = maybe_checktime,
    })
  end
end

---@param opts table|nil
function M.setup(opts)
  config.setup(opts)

  if config.options.refresh.enable_autoread then
    vim.opt.autoread = true
  end

  create_refresh_autocmds()
  if config.options.refresh.watch_files then
    create_file_watch_autocmds()
  end
  if setup_done then
    return
  end

  commands.create()

  setup_done = true
end

M.send = commands.send
M.mode = commands.mode
M.pick_target = commands.target_pick
M.show_target = commands.target_show
M.tmux = tmux

return M
