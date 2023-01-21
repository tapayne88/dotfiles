local a = require 'plenary.async'
local scan = require 'plenary.scandir'
local Job = require 'plenary.job'

local utils = {}

---@param color string|table<'"light"' | '"dark"', string>
---@return string|nil
function utils.color(color)
  local nord = require 'nord.colors'
  local tokyo_setup = require('tokyonight.colors').setup { style = 'day' }
  local colors = { nord = nord, tokyo = tokyo_setup }

  if type(color) ~= 'table' then
    color = { light = color, dark = color }
  end

  return vim.g.use_light_theme == true and colors.tokyo[color.light]
    or colors.nord[color.dark]
end

---@alias lsp_status 'error' | 'warning' | 'info' | 'hint' | 'ok'

---@type { error: string, warning: string, info: string, hint: string, hint_alt: string, ok: string }
utils.lsp_symbols = {
  error = ' ',
  warning = ' ',
  info = ' ',
  hint = ' ',
  hint_alt = ' ',
  ok = ' ',
}

---@param type lsp_status
---@return string|nil
utils.lsp_colors = function(type)
  local color_map = {
    error = utils.color { dark = 'nord11_gui', light = 'red' },
    warning = utils.color { dark = 'nord13_gui', light = 'yellow' },
    info = utils.color { dark = 'nord4_gui', light = 'fg' },
    hint = utils.color { dark = 'nord10_gui', light = 'blue2' },
    ok = utils.color { dark = 'nord14_gui', light = 'green' },
  }
  return color_map[type]
end

--- Run cmd async and trigger callback on completion - wrapped with plenary.async
---@param cmd string[]
---@param cwd string|nil
---@param fn fun(result: string[], code: number, signal: number)
utils.get_os_command_output_async = a.wrap(function(cmd, cwd, fn)
  if type(cmd) ~= 'table' then
    print '[get_os_command_output_async]: cmd has to be a table'
    return {}
  end
  local command = table.remove(cmd, 1)
  local job = Job:new { command = command, args = cmd, cwd = cwd }
  job:after(vim.schedule_wrap(function(j, code, signal)
    if code == 0 then
      return fn(j:result(), code, signal)
    end
    return fn(j:stderr_result(), code, signal)
  end))
  job:start()
end, 3)

---Run cmd synchronously and return value
---@param cmd string[]
---@param cwd string|nil
---@return string[]|nil, number|nil, string[]|nil
function utils.get_os_command_output(cmd, cwd)
  if type(cmd) ~= 'table' then
    print '[get_os_command_output]: cmd has to be a table'
    return nil, nil, nil
  end
  local command = table.remove(cmd, 1)
  local stderr = {}
  local stdout, ret = Job:new({
    command = command,
    args = cmd,
    cwd = cwd,
    on_stderr = function(_, data)
      table.insert(stderr, data)
    end,
  }):sync()
  return stdout, ret, stderr
end

---Map deeply nested table to single key
---```lua
---  local tbl = {name = {foo = {1, 2}, bar = {3, 4}}}
---  local new_tbl = map_table_to_key(tbl, "foo")
---  print(new_tbl) -- {name = {1, 2}}
---```
---@param tbl table<string, table<string, any>>
---@param key string
---@return table<string, any>
function utils.map_table_to_key(tbl, key)
  return vim.tbl_map(function(value)
    return value[key]
  end, tbl)
end

local function register_with_which_key(lhs, name, mode, options)
  local present, wk = pcall(require, 'which-key')
  if not present then
    return
  end
  wk.register {
    [lhs] = {
      name,
      mode = mode,
      noremap = options.noremap,
      silent = options.silent,
      buffer = options.buffer,
    },
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

    local description = opts.description and opts.description
      or 'Missing description'
    opts.description = nil

    register_with_which_key(lhs, description, mode, opts)

    require('legendary').keymap {
      lhs,
      rhs,
      description = description,
      mode = { mode },
      opts = opts,
    }
  end
end

local map_opts = { noremap = false, silent = true }
utils.nmap = make_mapper('n', map_opts)
utils.xmap = make_mapper('x', map_opts)
utils.imap = make_mapper('i', map_opts)
utils.vmap = make_mapper('v', map_opts)
utils.omap = make_mapper('o', map_opts)
utils.tmap = make_mapper('t', map_opts)
utils.smap = make_mapper('s', map_opts)
utils.cmap = make_mapper('c', { noremap = false, silent = false })

local noremap_opts = { noremap = true, silent = true }
utils.nnoremap = make_mapper('n', noremap_opts)
utils.xnoremap = make_mapper('x', noremap_opts)
utils.vnoremap = make_mapper('v', noremap_opts)
utils.inoremap = make_mapper('i', noremap_opts)
utils.onoremap = make_mapper('o', noremap_opts)
utils.tnoremap = make_mapper('t', noremap_opts)
utils.cnoremap = make_mapper('c', { noremap = true, silent = false })

---@alias Mode "n" | "x" | "v" | "i" | "o" | "t" | "c"

--- Utility function to support setting a keymap for multiple modes
---@param _modes Mode[] | Mode
---@param lhs string
---@param rhs string | fun(): nil | unknown
---@param _opts? {description: string}|table
---@return nil
function utils.keymap(_modes, lhs, rhs, _opts)
  local modes = type(_modes) == 'string' and { _modes } or _modes
  local opts = _opts ~= nil and _opts or {}

  -- TODO: Remove disable line when it behaves!
  ---@diagnostic disable-next-line: param-type-mismatch
  for _, mode in ipairs(modes) do
    make_mapper(mode, noremap_opts)(lhs, rhs, opts)
  end
end

-- Shamelessly stolen from akinsho/dotfiles
-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/lua/as/highlights.lua#L56
--- TODO eventually move to using `nvim_set_hl`
--- however for the time being that expects colors
--- to be specified as rgb not hex
---@param name string
---@param opts table
function utils.highlight(name, opts)
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
-- This can then be passed to utils.highlight
---@param group string
---@return table
function utils.highlight_group_attrs(group)
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

-- try to figure out if the commands are <buffer> targets so we can clear the
-- group appropraitely
local function has_buffer_target(commands)
  return #vim.tbl_filter(function(item)
    return #vim.tbl_filter(function(target)
      -- Only supports <buffer>, more complicated for things like
      -- <buffer=N>
      return target == '<buffer>'
    end, item.targets or {}) > 0
  end, commands) > 0
end

-- Convenience for making autocommands
---@param name string
---@param commands {command: fun()|string, user: boolean, events: string[], targets: string[], modifiers: string[]}[]
function utils.augroup(name, commands)
  vim.cmd('augroup ' .. name)

  -- Clear autogroup appropraitely for <buffer> targets
  if has_buffer_target(commands) then
    vim.cmd 'autocmd! * <buffer>'
  else
    vim.cmd 'autocmd!'
  end

  for _, c in ipairs(commands) do
    local command = c.command
    if type(command) == 'function' then
      local fn_id = tap._create(command)
      command = string.format('lua tap._execute(%s)', fn_id)
    end
    vim.cmd(
      string.format(
        'autocmd %s%s %s %s %s',
        c.user and 'User ' or '',
        table.concat(c.events, ','),
        table.concat(c.targets or {}, ','),
        table.concat(c.modifiers or {}, ' '),
        command
      )
    )
  end
  vim.cmd 'augroup END'
end

-- Convenience for making commands
-- ```lua
--    command({"name", function() {...})
-- ```
---@param args table
function utils.command(args)
  local nargs = args.nargs or 0
  local name = args[1]
  local rhs = args[2]
  local types = (args.types and type(args.types) == 'table')
      and table.concat(args.types, ' ')
    or ''
  local extra = args.extra or ''

  local fn_has_args = function(num_args)
    if type(num_args) == 'string' then
      return true
    end
    if type(num_args) == 'number' then
      return num_args > 0
    end
    return false
  end

  if type(rhs) == 'function' then
    local fn_id = tap._create(rhs)
    local has_args = fn_has_args(nargs)
    rhs = string.format(
      'lua tap._execute(%d%s)',
      fn_id,
      has_args and ', {<f-args>}' or ''
    )
  end

  vim.cmd(
    string.format(
      'command! -nargs=%s %s %s %s %s',
      nargs,
      types,
      extra,
      name,
      rhs
    )
  )
end

-- Properly escape string for terminal
---@param str string
---@return string
function utils.termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

--- Attempt to load plugin config, silently fail if there are errors
---@param name string
---@param callback fun(plugin: any): any
---@return any|nil
function utils.require_plugin(name, callback)
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

--- Load custom highlights at the appropriate time
---@param name string
---@param callback fun(): nil
---@param _opts {force: boolean}|nil
---@return nil
function utils.apply_user_highlights(name, callback, _opts)
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

  utils.augroup(augroup_name, {
    {
      events = { 'VimEnter', 'ColorScheme' },
      targets = { '*' },
      command = callback,
    },
  })

  callback()
end

function utils.run(fns)
  for _, fn in pairs(fns) do
    fn()
  end
end

function utils.root_pattern(patterns)
  local function find_root(start)
    if start == '/' then
      return nil
    end
    local res = scan.scan_dir(
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

return utils
