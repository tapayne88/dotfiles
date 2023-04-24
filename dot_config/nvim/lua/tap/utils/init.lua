local log = require 'plenary.log'

local M = {}

---Detect if environment variable is set and is truthy
---@param env_var string
---@return boolean
function M.getenv_bool(env_var)
  local value = vim.fn.getenv(env_var)
  if value == vim.NIL then
    return false
  end

  return vim.tbl_contains({ 'true', '1' }, value:lower())
end

---Detect if DEBUG environment variable is set and is truthy
---@return boolean
function M.debug_enabled()
  return M.getenv_bool 'DEBUG'
end

---Wrapper around vim.notify to log when DEBUG is enabled
---@param msg string Content of the notification to show to the user.
---@param level number|nil One of the values from |vim.log.levels|.
---@param opts table|nil Optional parameters. Unused by default.
function M.notify_in_debug(msg, level, opts)
  vim.schedule(function()
    if M.debug_enabled() then
      vim.notify(msg, level, opts)
    end
  end)
end

-- Setup logger
M.logger_scope = 'tap-lua'

M.logger = log.new {
  plugin = M.logger_scope,
  level = M.debug_enabled() and 'debug' or 'warn',
}

---Map deeply nested table to single key
---```lua
---  local tbl = {name = {foo = {1, 2}, bar = {3, 4}}}
---  local new_tbl = map_table_to_key(tbl, "foo")
---  print(new_tbl) -- {name = {1, 2}}
---```
---@param tbl table<string, table<string, any>>
---@param key string
---@return table<string, any>
function M.map_table_to_key(tbl, key)
  return vim.tbl_map(function(value)
    return value[key]
  end, tbl)
end

---@alias Mode "n" | "x" | "v" | "i" | "o" | "t" | "c"

--- Utility function to support setting a keymap for multiple modes
---@param _modes Mode[] | Mode
---@param lhs string
---@param rhs string | fun(): nil | unknown
---@param _opts? {desc: string}|table
---@return nil
function M.keymap(_modes, lhs, rhs, _opts)
  local modes = type(_modes) == 'string' and { _modes } or _modes
  local opts = _opts ~= nil and _opts or {}

  local description = opts.desc and opts.desc or 'Missing description'
  opts.desc = nil

  require('which-key').register {
    [lhs] = {
      description,
      mode = modes,
      noremap = opts.noremap,
      silent = opts.silent,
      buffer = opts.buffer,
      nowait = opts.nowait,
    },
  }

  require('legendary').keymap {
    lhs,
    rhs,
    description = description,
    mode = modes,
    opts = opts,
  }
end

---create a mapping function factory
---@param mode string
---@param o table
---@return function
local function make_mapper(mode, o)
  local parent_opts = vim.deepcopy(o)

  return function(lhs, rhs, _opts)
    local opts =
      vim.tbl_extend('keep', _opts and vim.deepcopy(_opts) or {}, parent_opts)

    M.keymap(mode, lhs, rhs, opts)
  end
end

local map_opts = { noremap = false, silent = true }
M.nmap = make_mapper('n', map_opts)
M.xmap = make_mapper('x', map_opts)
M.imap = make_mapper('i', map_opts)
M.vmap = make_mapper('v', map_opts)
M.omap = make_mapper('o', map_opts)
M.tmap = make_mapper('t', map_opts)
M.smap = make_mapper('s', map_opts)
M.cmap = make_mapper('c', { noremap = false, silent = false })

local noremap_opts = { noremap = true, silent = true }
M.nnoremap = make_mapper('n', noremap_opts)
M.xnoremap = make_mapper('x', noremap_opts)
M.vnoremap = make_mapper('v', noremap_opts)
M.inoremap = make_mapper('i', noremap_opts)
M.onoremap = make_mapper('o', noremap_opts)
M.tnoremap = make_mapper('t', noremap_opts)
M.cnoremap = make_mapper('c', { noremap = true, silent = false })

---@alias HighlightOpts
---| { guifg?: string, guibg?: string, gui?: string, guisp?: string, ctermfg?: string, ctermbg?: string, cterm?: string }
---| { link?: string, force: boolean }

---@alias Utils.highlight fun(name: string, opts: HighlightOpts): nil

-- Shamelessly stolen from akinsho/dotfiles
-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/lua/as/highlights.lua#L56
--- TODO eventually move to using `nvim_set_hl`
--- however for the time being that expects colors
--- to be specified as rgb not hex
---@type Utils.highlight
function M.highlight(name, opts)
  local force = opts.force or false
  if name and vim.tbl_count(opts) > 0 then
    if opts.link and opts.link ~= '' then
      vim.cmd(
        'highlight'
          .. (force and '!' or '')
          .. ' link '
          .. name
          .. ' '
          .. opts.link
      )
    else
      local cmd = { 'highlight', name }
      if opts.guifg and opts.guifg ~= '' then
        table.insert(cmd, 'guifg=' .. opts.guifg)
      end
      if opts.guibg and opts.guibg ~= '' then
        table.insert(cmd, 'guibg=' .. opts.guibg)
      end
      if opts.gui and opts.gui ~= '' then
        table.insert(cmd, 'gui=' .. opts.gui)
      end
      if opts.guisp and opts.guisp ~= '' then
        table.insert(cmd, 'guisp=' .. opts.guisp)
      end
      if opts.ctermfg and opts.ctermfg ~= '' then
        table.insert(cmd, 'ctermfg=' .. opts.ctermfg)
      end
      if opts.ctermbg and opts.ctermbg ~= '' then
        table.insert(cmd, 'ctermbg=' .. opts.ctermbg)
      end
      if opts.cterm and opts.cterm ~= '' then
        table.insert(cmd, 'cterm=' .. opts.cterm)
      end
      vim.cmd(table.concat(cmd, ' '))
    end
  end
end

-- Given a highlight name, grab the bg & fg attributes
-- This can then be passed to Utils.highlight
---@param group string
---@return table
function M.highlight_group_attrs(group)
  local id = vim.fn.synIDtrans(vim.fn.hlID(group))
  local hi = {
    cterm = { fg = 'NONE', bg = 'NONE' },
    gui = { fg = 'NONE', bg = 'NONE' },
  }
  for mode in pairs(hi) do
    local bg_attr = vim.fn.synIDattr(id, 'bg', mode)
    local fg_attr = vim.fn.synIDattr(id, 'fg', mode)

    hi[mode].bg = bg_attr == '' and 'NONE' or bg_attr
    hi[mode].fg = fg_attr == '' and 'NONE' or fg_attr
  end
  return {
    ctermfg = hi.cterm.bg,
    ctermbg = hi.cterm.fg,
    guifg = hi.gui.fg,
    guibg = hi.gui.bg,
  }
end

-- Convenience for making autocommands within a group
---@param name string
---@param commands {events: any, opts?: table<string, any>}[]
function M.augroup(name, commands)
  local group_id = vim.api.nvim_create_augroup(name, { clear = true })

  for _, cmd in ipairs(commands) do
    local events = cmd.events
    cmd.events = nil

    vim.api.nvim_create_autocmd(
      events,
      vim.tbl_extend('error', cmd, { group = group_id })
    )
  end
end

-- Properly escape string for terminal
---@param str string
---@return string
function M.termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

--- Attempt to load plugin config, silently fail if there are errors
---@param name string
---@param callback fun(plugin: any): any
---@return any|nil
function M.require_plugin(name, callback)
  if not string.match(name, '^tap%.plugins%..+') then
    vim.notify(
      string.format('Attempted to load non-plugin! [%s]', name),
      vim.log.levels.ERROR { title = 'require_plugin' }
    )
    return nil
  end

  local ok, plugin = pcall(require, name)

  if not ok then
    return nil
  end

  if type(callback) == 'function' then
    local cbok, val = pcall(callback, plugin)
    return not cbok and nil or val
  end

  return nil
end

local has_augroup = function(name)
  local augroups = ' ' .. vim.api.nvim_exec('augroup', true) .. ' '

  return augroups:match('%s' .. name .. '%s') ~= nil
end

local get_catppuccin_palette = function()
  return require('catppuccin.palettes').get_palette(
    require('catppuccin').flavour
  )
end

--- Load custom highlights at the appropriate time
---@param name string
---@param callback fun(p1: Utils.highlight, p2: table): nil
---@param _opts {force: boolean}|nil
---@return nil
function M.apply_user_highlights(name, callback, _opts)
  local opts = _opts or {}
  local augroup_name = name .. 'TapUserHighlights'
  local force = opts.force or false

  if not force and has_augroup(augroup_name) then
    vim.notify(
      'augroup already exists with name ' .. augroup_name,
      vim.log.levels.ERROR { title = 'apply_user_highlights' }
    )
    return
  end

  M.augroup(augroup_name, {
    {
      events = { 'VimEnter', 'ColorScheme' },
      pattern = { '*' },
      callback = function()
        callback(M.highlight, get_catppuccin_palette())
      end,
    },
  })

  callback(M.highlight, get_catppuccin_palette())
end

function M.run(fns)
  for _, fn in pairs(fns) do
    fn()
  end
end

function M.root_pattern(patterns)
  local function find_root(start)
    if start == '/' then
      return nil
    end
    local res = require('plenary.scandir').scan_dir(
      start,
      { search_pattern = patterns, hidden = true, add_dirs = true, depth = 1 }
    )
    if #res == 0 then
      local new = start .. '/../'
      return find_root(vim.loop.fs_realpath(new))
    else
      return start
    end
  end

  return find_root
end

local max_size = math.pow(1024, 2) / 2 -- 500KB
local min_file_lines = 10
---Determine if file looks to be minifed. Criteria is a large file with few lines
---@param filepath string
---@return boolean
function M.check_file_minified(filepath)
  local ok, stat = pcall(vim.loop.fs_stat, filepath)

  if not ok or not stat then
    return false
  end

  if stat.size > max_size then
    local path = require('plenary.path'):new(filepath)
    local lines = vim.split(path:head(min_file_lines), '[\r]?\n')
    local is_file_minified = lines ~= min_file_lines
    return is_file_minified
  end
  return false
end

---Test visible buffers with passed function
---@param test_fn fun(tbl: {bufnr: number}): boolean
---@return boolean has the condition returned true for a visible buffer
function M.test_visible_buffers(test_fn)
  for _, buffer in ipairs(vim.fn.getwininfo()) do
    local is_truthy = test_fn(buffer)

    if is_truthy then
      return true
    end
  end

  return false
end

---Read file contents
---@param path string
---@return unknown
function M.read_file(path)
  local a = require 'plenary.async'

  local err_open, fd = a.uv.fs_open(path, 'r', 438)
  assert(not err_open, err_open)

  local err_stat, stat = a.uv.fs_fstat(fd)
  assert(not err_stat, err_stat)

  local err_read, data = a.uv.fs_read(fd, stat.size, 0)
  assert(not err_read, err_read)

  local err_close = a.uv.fs_close(fd)
  assert(not err_close, err_close)

  return data
end

-- Map of DAP buffer filetypes
M.dap_filetypes = {
  'dap-repl',
  'dapui_breakpoints',
  'dapui_console',
  'dapui_scopes',
  'dapui_stacks',
  'dapui_watches',
}

return M
