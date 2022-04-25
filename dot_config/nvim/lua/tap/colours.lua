local command = require('tap.utils').command
local require_plugin = require('tap.utils').require_plugin
local get_os_command_output_async =
  require('tap.utils').get_os_command_output_async
local a = require 'plenary.async'
local log = require 'plenary.log'
local fwatch = require 'fwatch'

local get_term_theme = function()
  local res, code = get_os_command_output_async({ 'term-theme', 'echo' }, nil)
  if code ~= 0 then
    vim.notify(
      'Failed running `term-theme echo`, ensure `term-theme` has been set',
      'error'
    )
    return 'dark'
  end
  return res[1]
end

local set_colorscheme = function(theme_future, opts)
  -- set nord colorscheme upfront to avoid flickering from "default" scheme
  vim.cmd [[colorscheme nord]]
  return a.run(function()
    local theme = theme_future()

    if theme == 'light' then
      vim.g.use_light_theme = true

      vim.o.background = 'light'
      require_plugin('tap.plugins.lualine', function(lualine)
        lualine.set_theme 'tokyonight'
      end)
      vim.cmd [[colorscheme tokyonight]]

      if opts.announce == true then
        vim.notify('set theme to light', 'info')
      end
    elseif theme == 'dark' then
      vim.g.use_light_theme = false

      vim.g.nord_italic = true
      vim.g.nord_borders = true
      vim.o.background = 'dark'
      require_plugin('tap.plugins.lualine', function(lualine)
        lualine.set_theme 'nord_custom'
      end)
      vim.cmd [[colorscheme nord]]

      if opts.announce == true then
        vim.notify('set theme to dark', 'info')
      end
    else
      log.error('unknown colorscheme ' .. theme)
    end
  end)
end

set_colorscheme(get_term_theme, { announce = false })

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

command {
  'TermThemeToggle',
  function()
    a.run(function()
      if get_term_theme() == 'dark' then
        vim.loop.spawn('term-theme', { args = { 'light' } }, nil)
      else
        vim.loop.spawn('term-theme', { args = { 'dark' } }, nil)
      end
    end)
  end,
}
command {
  'TermThemeRefresh',
  function()
    set_colorscheme(get_term_theme, { announce = true })
  end,
}

fwatch.watch(vim.fn.expand '$XDG_CONFIG_HOME' .. '/term_theme', {
  on_event = function()
    vim.schedule(function()
      set_colorscheme(get_term_theme, { announce = true })
    end)
  end,
})
