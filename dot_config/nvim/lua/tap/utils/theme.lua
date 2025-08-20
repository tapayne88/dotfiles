local get_os_command_output_async = require('tap.utils.async').get_os_command_output_async
local a = require 'plenary.async'
local fwatch = require 'fwatch'

local M = {}

function M.get_term_theme()
  local res, code = get_os_command_output_async({ 'term-theme', 'echo' }, nil)
  if code ~= 0 then
    vim.notify('Failed running `term-theme echo`, ensure `term-theme` has been set', vim.log.levels.ERROR)
    return 'dark'
  end
  return res[1]
end

local set_dark = function()
  vim.g.use_light_theme = false

  vim.o.background = 'dark'
  vim.cmd.colorscheme 'catppuccin-mocha'
end

local set_light = function()
  vim.g.use_light_theme = true

  vim.o.background = 'light'
  vim.cmd.colorscheme 'catppuccin-latte'
end

function M.set_colorscheme(theme_future, opts)
  -- set dark colorscheme upfront to avoid flickering from "default" scheme
  set_dark()
  return a.run(function()
    local theme = theme_future()

    if theme == 'light' then
      set_light()
    elseif theme == 'dark' then
      set_dark()
    else
      require('tap.utils').logger.error('unknown colorscheme ' .. theme)
    end

    if opts.announce == true then
      vim.notify('set theme to ' .. theme, vim.log.levels.INFO)
    end
  end)
end

-- Patch CursorLine highlighting bug in NeoVim
-- Messes with highlighting of current line in weird ways
-- https://github.com/neovim/neovim/issues/9019#issuecomment-714806259
-- lua version
-- Disable due to messing with neovim terminal colours
-- local function CustomizeColors()
--     if vim.fn.has('gui_running') or vim.o.termguicolors or
--         vim.fn.exists('g:gonvim_running') then
--         highlight("CursorLine", {ctermfg = "white"})
--     else
--         highlight("CursorLine", {guifg = "white"})
--     end
-- end

-- augroup("OnColorScheme", {
--     {
--         events = {"ColorScheme", "BufEnter", "BufWinEnter"},
--         targets = {"*"},
--         command = CustomizeColors
--     }
-- })

vim.api.nvim_create_user_command('TermThemeToggle', function()
  a.run(function()
    if M.get_term_theme() == 'dark' then
      vim.loop.spawn('term-theme', { args = { 'light' } }, nil)
    else
      vim.loop.spawn('term-theme', { args = { 'dark' } }, nil)
    end
  end)
end, { desc = 'Toggle between dark and light themes' })
vim.api.nvim_create_user_command('TermThemeRefresh', function()
  M.set_colorscheme(M.get_term_theme, { announce = true })
end, { desc = 'Refresh the theme' })

--- Attempt to debouce watches by only setting up the listen after handling the
--- colour change
function M.setup_theme_watch()
  fwatch.once(vim.fn.expand '$XDG_CONFIG_HOME' .. '/term_theme', {
    on_event = function()
      vim.schedule(function()
        M.set_colorscheme(M.get_term_theme, { announce = true })
        M.setup_theme_watch()
      end)
    end,
  })
end

return M
