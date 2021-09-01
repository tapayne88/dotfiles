local highlight = require("tap.utils").highlight
local augroup = require("tap.utils").augroup
local color = require("tap.utils").color
local command = require("tap.utils").command
local a = require("plenary.async_lib.async")

local term_theme_fname = vim.fn
                             .expand(vim.env.XDG_CONFIG_HOME .. '/.term_theme')

local function get_term_theme()
    local success, theme = pcall(vim.fn.readfile, term_theme_fname)
    if success then return theme[1] end
    return nil
end

local function set_term_theme(name) vim.fn.writefile({name}, term_theme_fname) end

local spawn_async = a.wrap(vim.loop.spawn, "vararg")

local tmux_conf = vim.env.HOME .. '/.tmux.conf'
local function set_tmux_theme(name)
    a.run(a.future(function()
        -- set tmux var
        a.await(spawn_async('tmux', {args = {'setenv', 'THEME', name}}))
        -- reload tmux
        a.await(spawn_async('tmux', {args = {'source-file', tmux_conf}}))
    end))
end

local function set_terminal_colorscheme(name)
    set_term_theme(name)
    set_tmux_theme(name)
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
        vim.g.use_light_theme = false
        set_terminal_colorscheme("nord")

        vim.g.nord_italic = true
        vim.o.background = "dark"
        vim.cmd [[colorscheme nord]]
    end
end

set_colorscheme(get_term_theme() == "kitty_tokyonight_day")

local function apply_user_highlights()
    highlight('Search', {
        guibg = color({dark = "nord9_gui", light = "blue2"}),
        guifg = color({dark = "nord0_gui", light = "bg"}),
        gui = "NONE"
    })
    highlight('IncSearch', {
        guibg = color({dark = "nord9_gui", light = "blue2"}),
        guifg = color({dark = "nord0_gui", light = "bg"}),
        gui = "NONE"
    })

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
        command = apply_user_highlights
    }
})

apply_user_highlights()

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

command({
    "ToggleColor", function() set_colorscheme(not vim.g.use_light_theme) end
})
