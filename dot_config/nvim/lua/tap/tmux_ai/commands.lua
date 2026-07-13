local context = require 'tap.tmux_ai.context'
local tmux = require 'tap.tmux_ai.tmux'
local notify = require 'tap.tmux_ai.notify'

local M = {}
local prompt_highlight = 'TapTmuxAIPrompt'
local this_keyword = '@this'

---@param text string
---@return table[]
local function highlight_this_keyword(text)
  local start = text:find(this_keyword, 1, true)
  if start == nil then
    return {}
  end

  -- dressing.nvim expects 0-indexed byte ranges for highlights.
  local col_start = start - 1
  local col_end = col_start + #this_keyword
  return { { col_start, col_end, prompt_highlight } }
end

local function send_prompt(prompt, opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local payload = context.build_prompt(bufnr, prompt, opts.range)
  tmux.send_text(payload, { submit = opts.submit }, function(ok, err)
    if not ok then
      notify.error(err or 'Failed to send prompt to TmuxAI')
      return
    end

    notify.info 'Sent context to TmuxAI'
  end)
end

local function ask_for_prompt(callback, default_text)
  if vim.fn.hlexists(prompt_highlight) == 0 then
    vim.api.nvim_set_hl(0, prompt_highlight, { link = 'WarningMsg' })
  end

  vim.ui.input({
    prompt = 'TmuxAI prompt: ',
    default = default_text or '',
    highlight = highlight_this_keyword,
  }, function(input)
    if input == nil or vim.trim(input) == '' then
      return
    end

    callback(input)
  end)
end

local function with_prompt(args, callback, default_text)
  if args.args and vim.trim(args.args) ~= '' then
    callback(args.args)
    return
  end

  ask_for_prompt(callback, default_text)
end

local function get_range(args)
  if args.range > 0 then
    return {
      line1 = args.line1,
      line2 = args.line2,
    }
  end

  return nil
end

---@param prompt string
---@param range { line1: number, line2: number }|nil
---@return string
local function normalize_prompt(prompt, range)
  if range ~= nil and not prompt:find('@this', 1, true) then
    return '@this ' .. prompt
  end

  return prompt
end

function M.send(args)
  local range = get_range(args)
  with_prompt(args, function(prompt)
    send_prompt(normalize_prompt(prompt, range), {
      range = range,
      submit = true,
    })
  end, range == nil and '' or '@this ')
end

function M.mode(args)
  local mode = args.args ~= '' and args.args or 'toggle'
  tmux.send_mode(mode, function(ok, err)
    if not ok then
      notify.error(err or 'Failed to change TmuxAI mode')
      return
    end

    if mode == 'toggle' then
      notify.info 'Sent TmuxAI mode cycle'
      return
    end

    notify.info(string.format('Sent TmuxAI mode change: /%s', mode))
  end)
end

function M.target(args)
  local ok, err = tmux.set_target(args.args)
  if not ok then
    notify.error(err or 'Failed to set TmuxAI target pane')
    return
  end

  notify.info(string.format('TmuxAI target set to %s', args.args))
end

function M.target_show()
  local target, err = tmux.show_target()
  if not target then
    notify.error(err or 'no TmuxAI tmux pane configured')
    return
  end

  notify.info(target)
end

function M.target_pick()
  tmux.pick_target()
end

function M.create()
  vim.api.nvim_create_user_command('TmuxAISend', M.send, {
    desc = 'Send current file or range to TmuxAI',
    nargs = '*',
    range = true,
  })

  vim.api.nvim_create_user_command('TmuxAIMode', M.mode, {
    desc = 'Change TmuxAI CLI mode',
    nargs = '?',
    complete = function()
      return { 'plan', 'ask', 'debug', 'shell' }
    end,
  })

  vim.api.nvim_create_user_command('TmuxAITarget', M.target, {
    desc = 'Set the tmux pane target for TmuxAI',
    nargs = 1,
  })

  vim.api.nvim_create_user_command('TmuxAITargetShow', M.target_show, {
    desc = 'Show the tmux pane target for TmuxAI',
    nargs = 0,
  })

  vim.api.nvim_create_user_command('TmuxAITargetPick', M.target_pick, {
    desc = 'Pick the tmux pane target for TmuxAI',
    nargs = 0,
  })
end

return M
