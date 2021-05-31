local highlight = require("tap.utils").highlight
local augroup = require("tap.utils").augroup
local nord_colors = require("tap.utils").nord_colors

local function set_terminal_colorscheme(name)
    vim.loop.spawn('kitty', {
        args = {
            '@', '--to', vim.env.KITTY_LISTEN_ON, 'set-colors',
            -- '-a', -- update for all windows
            -- '-c', -- update for new windows
            string.format('~/.config/kitty/colors/%s.conf', name) -- path to kitty colorscheme
        }
    }, nil)
end

local function set_colorscheme(use_light_theme)
    if (use_light_theme) then
        vim.g.use_light_theme = true
        set_terminal_colorscheme("kitty_tokyonight_day")
        vim.o.background = "light"
        vim.cmd [[colorscheme tokyonight]]
    else
        vim.g.nvcode_termcolors = 256

        -- Nord config if/when they merge treesitter support
        vim.g.nord_italic = 1
        vim.g.nord_italic_comments = 1
        vim.g.nord_underline = 1
        vim.g.nord_uniform_diff_background = 1
        vim.g.nord_cursor_line_number_background = 1

        vim.g.use_light_theme = nil
        set_terminal_colorscheme("nord")
        vim.o.background = "dark"
        vim.cmd [[colorscheme nord]]
    end
end

set_colorscheme(false)

local module = {}

function module.apply_user_highlights()
    highlight('Search', {guibg = nord_colors.nord9, guifg = nord_colors.nord0})
    highlight('IncSearch',
              {guibg = nord_colors.nord9, guifg = nord_colors.nord0})

    -- Treesitter overrides
    highlight('TSInclude', {gui = 'italic', cterm = 'italic'})
    highlight('TSOperator', {gui = 'italic', cterm = 'italic'})
    highlight('TSKeyword', {gui = 'italic', cterm = 'italic'})

    highlight('gitmessengerHeader', {link = 'Identifier'})
    highlight('gitmessengerHash', {link = 'Comment'})
    highlight('gitmessengerHistory', {link = 'Constant'})
    highlight('gitmessengerPopupNormal', {link = 'CursorLine'})
end

augroup("ExplorerHighlights", {
    {
        events = {"VimEnter", "ColorScheme"},
        targets = {"*"},
        command = "lua require('tap.colours').apply_user_highlights()"
    }
})

-- Patch CursorLine highlighting bug in NeoVim
-- Messes with highlighting of current line in weird ways
-- https://github.com/neovim/neovim/issues/9019#issuecomment-714806259
-- lua version
local function CustomizeColors()
    if vim.fn.has('gui_running') or vim.o.termguicolors or
        vim.fn.exists('g:gonvim_running') then
        highlight("CursorLine", {ctermfg = "white"})
    else
        highlight("CursorLine", {guifg = "white"})
    end
end

augroup("OnColorScheme", {
    {
        events = {"ColorScheme", "BufEnter", "BufWinEnter"},
        targets = {"*"},
        command = CustomizeColors
    }
})

_G.tap.toggle_color =
    function() set_colorscheme(vim.g.use_light_theme == nil) end

return module
