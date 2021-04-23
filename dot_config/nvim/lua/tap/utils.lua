local api = vim.api
local Job = require('plenary.job')

local utils = {}

utils.lsp_symbols = {
  error = "",
  warning = "",
  info = "",
  hint = "",
  hint_alt = "",
  ok = " "
}

function utils.get_os_command_output_async(cmd, fn, cwd)
  if type(cmd) ~= "table" then
    print('[get_os_command_output_async]: cmd has to be a table')
    return {}
  end
  local command = table.remove(cmd, 1)
  job = Job:new({ command = command, args = cmd, cwd = cwd })
  job:after(
    vim.schedule_wrap(
      function(j, code, signal)
        if code == 0 then
          return fn(j:result(), code, signal)
        end
        return fn(j:stderr_result(), code, signal)
      end
    )
  )
  job:start()
  return job
end

function utils.get_os_command_output(cmd, cwd)
  if type(cmd) ~= "table" then
    print('[get_os_command_output]: cmd has to be a table')
    return {}
  end
  local command = table.remove(cmd, 1)
  local stderr = {}
  local stdout, ret = Job:new({ command = command, args = cmd, cwd = cwd, on_stderr = function(_, data)
    table.insert(stderr, data)
  end }):sync()
  return stdout, ret, stderr
end

function utils.map_table_to_key(tbl, key)
  return vim.tbl_map(function(value)
    return value[key]
  end, tbl)
end

local function validate_opts(opts)
  if not opts then
    return true
  end

  if opts.buffer and type(opts.buffer) ~= "number" then
    return false, "The buffer key should be a number"
  end

  return true
end

-- Shamelessly stolen from akinsho/dotfiles
-- https://github.com/akinsho/dotfiles/blob/main/.config/nvim/lua/as/utils.lua#L71
local function make_mapper(mode, _opts)
  -- copy the opts table as extends will mutate the opts table passed in otherwise
  local parent_opts = vim.deepcopy(_opts)
  return function(lhs, rhs, __opts)
    local opts = __opts and vim.deepcopy(__opts) or {}
    vim.validate {
      lhs = {lhs, "string"},
      rhs = {rhs, "string"},
      opts = {opts, validate_opts, "mapping options are incorrect"}
    }
    if opts.bufnr then
      -- Remove the bufnr from the args sent to the key map function
      local bufnr = opts.bufnr
      opts.bufnr = nil
      opts = vim.tbl_extend("keep", opts, parent_opts)
      api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    else
      api.nvim_set_keymap(mode, lhs, rhs, vim.tbl_extend("keep", opts, parent_opts))
    end
  end
end

local map_opts = {noremap = false, silent = true}
utils.nmap = make_mapper("n", map_opts)
utils.xmap = make_mapper("x", map_opts)
utils.imap = make_mapper("i", map_opts)
utils.vmap = make_mapper("v", map_opts)
utils.omap = make_mapper("o", map_opts)
utils.tmap = make_mapper("t", map_opts)
utils.smap = make_mapper("s", map_opts)
utils.cmap = make_mapper("c", {noremap = false, silent = false})

local noremap_opts = {noremap = true, silent = true}
utils.nnoremap = make_mapper("n", noremap_opts)
utils.xnoremap = make_mapper("x", noremap_opts)
utils.vnoremap = make_mapper("v", noremap_opts)
utils.inoremap = make_mapper("i", noremap_opts)
utils.onoremap = make_mapper("o", noremap_opts)
utils.tnoremap = make_mapper("t", noremap_opts)
utils.cnoremap = make_mapper("c", {noremap = true, silent = false})

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
    if opts.link and opts.link ~= "" then
      vim.cmd("highlight" .. (force and "!" or "") .. " link " .. name .. " " .. opts.link)
    else
      local cmd = {"highlight", name}
      if opts.guifg and opts.guifg ~= "" then
        table.insert(cmd, "guifg=" .. opts.guifg)
      end
      if opts.guibg and opts.guibg ~= "" then
        table.insert(cmd, "guibg=" .. opts.guibg)
      end
      if opts.gui and opts.gui ~= "" then
        table.insert(cmd, "gui=" .. opts.gui)
      end
      if opts.guisp and opts.guisp ~= "" then
        table.insert(cmd, "guisp=" .. opts.guisp)
      end
      if opts.cterm and opts.cterm ~= "" then
        table.insert(cmd, "cterm=" .. opts.cterm)
      end
      vim.cmd(table.concat(cmd, " "))
    end
  end
end

function utils.join(value, str, sep)
  sep = sep or ","
  str = str or ""
  value = type(value) == "table" and table.concat(value, sep) or value
  return str ~= "" and table.concat({value, str}, sep) or value
end

function utils.termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

return utils
