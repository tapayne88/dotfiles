local highlight = require("tap.utils").highlight
local augroup = require("tap.utils").augroup
local color = require("tap.utils").color
local command = require("tap.utils").command
local get_os_command_output_async =
    require("tap.utils").get_os_command_output_async
local a = require("plenary.async_lib.async")
local log = require("plenary.log")

local a_spawn = a.wrap(get_os_command_output_async, 3)

local get_term_theme = a.async(function()
    return a.await(a_spawn({"term-theme", "echo"}, nil))[1]
end)

local set_colorscheme = function(theme_future)
    -- set nord colorscheme upfront to avoid flickering from "default" scheme
    vim.cmd [[colorscheme nord]]
    return a.run(a.future(function()
        local theme = a.await(theme_future)

        if (theme == "light") then
            vim.g.use_light_theme = true
            vim.loop.spawn("term-theme", {args = {"light"}}, nil)

            vim.o.background = "light"
            vim.cmd [[colorscheme tokyonight]]
        elseif (theme == "dark") then
            vim.g.use_light_theme = false
            vim.loop.spawn("term-theme", {args = {"dark"}}, nil)

            vim.g.nord_italic = true
            vim.o.background = "dark"
            vim.cmd [[colorscheme nord]]
        else
            log.error("unknown colorscheme " .. theme)
        end
    end))
end

set_colorscheme(a.future(function() return a.await(get_term_theme()) end))

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
    "ToggleColor", function()
        set_colorscheme(a.future(function()
            if a.await(get_term_theme()) == "dark" then
                return "light"
            else
                return "dark"
            end
        end))
    end
})
command({
    "RefreshColor", function()
        set_colorscheme(a.future(function()
            return a.await(get_term_theme())
        end))
    end
})
