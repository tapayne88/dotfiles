local command = require("tap.utils").command
local require_plugin = require("tap.utils").require_plugin
local get_os_command_output_async =
    require("tap.utils").get_os_command_output_async
local a = require("plenary.async")
local log = require("plenary.log")
local fwatch = require('fwatch')

local get_term_theme = function()
    return get_os_command_output_async({"term-theme", "echo"}, nil)[1]
end

local set_colorscheme = function(theme_future, opts)
    local spawn = opts.spawn == nil and true or false
    -- set nord colorscheme upfront to avoid flickering from "default" scheme
    vim.cmd [[colorscheme nord]]
    return a.run(function()
        local theme = theme_future()

        if (theme == "light") then
            vim.g.use_light_theme = true
            if spawn == true then
                vim.loop.spawn("term-theme", {args = {"light"}}, nil)
            end

            vim.o.background = "light"
            require_plugin("tap.plugins.lualine", function(lualine)
                lualine.set_theme('tokyonight')
            end)
            vim.cmd [[colorscheme tokyonight]]

            if opts.announce == true then
                vim.notify("setting theme to light", "info")
            end
        elseif (theme == "dark") then
            vim.g.use_light_theme = false
            if spawn == true then
                vim.loop.spawn("term-theme", {args = {"dark"}}, nil)
            end

            vim.g.nord_italic = true
            vim.g.nord_borders = tap.neovim_nightly()
            vim.o.background = "dark"
            require_plugin("tap.plugins.lualine", function(lualine)
                lualine.set_theme('nord_custom')
            end)
            vim.cmd [[colorscheme nord]]

            if opts.announce == true then
                vim.notify("setting theme to dark", "info")
            end
        else
            log.error("unknown colorscheme " .. theme)
        end
    end)
end

set_colorscheme(get_term_theme, {announce = false})

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
    "TermThemeToggle", function()
        set_colorscheme(function()
            if get_term_theme() == "dark" then
                return "light"
            else
                return "dark"
            end
        end, {announce = true})
    end
})
command({
    "TermThemeRefresh",
    function()
        set_colorscheme(get_term_theme, {announce = true, spawn = false})
    end
})

local change_count = 0
fwatch.watch(vim.fn.expand("$XDG_CONFIG_HOME") .. "/term_theme", {
    on_event = function()
        change_count = change_count + 1
        print('file changed', change_count)
        if change_count <= 1 then
            -- Event is triggered on neovim load so discard it
            return
        end

        vim.schedule(function()
            set_colorscheme(get_term_theme, {announce = true, spawn = false})
        end)
    end
})
