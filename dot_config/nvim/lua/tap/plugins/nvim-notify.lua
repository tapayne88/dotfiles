local lsp_symbols = require("tap.utils").lsp_symbols
local highlight = require("tap.utils").highlight
local color = require("tap.utils").color
local augroup = require("tap.utils").augroup

vim.notify = require("notify")

require("notify").setup {
    icons = {
        ERROR = lsp_symbols.error,
        WARN = lsp_symbols.warning,
        INFO = lsp_symbols.info,
        DEBUG = "",
        TRACE = "✎"
    }
}

require("telescope").load_extension("notify")

local function apply_user_highlights()
    -- LuaFormatter off
    highlight("NotifyERRORBorder", {guifg = color({dark = "nord11_gui", light = "red"})})
    highlight("NotifyWARNBorder", {guifg = color({dark = "nord13_gui", light = "yellow"})})
    highlight("NotifyINFOBorder", {guifg = color({dark = "nord4_gui", light = "fg"})})
    highlight("NotifyDEBUGBorder", {guifg = color({dark = "nord10_gui", light = "blue2"})})
    highlight("NotifyTRACEBorder", {guifg = color({dark="nord15_gui", light="purple"})})

    highlight("NotifyERRORIcon", {guifg = color({dark = "nord11_gui", light = "red"})})
    highlight("NotifyWARNIcon", {guifg = color({dark = "nord13_gui", light = "yellow"})})
    highlight("NotifyINFOIcon", {guifg = color({dark = "nord4_gui", light = "fg"})})
    highlight("NotifyDEBUGIcon", {guifg = color({dark = "nord10_gui", light = "blue2"})})
    highlight("NotifyTRACEIcon", {guifg = color({dark="nord15_gui", light="purple"})})

    highlight("NotifyERRORTitle", {guifg = color({dark = "nord11_gui", light = "red"})})
    highlight("NotifyWARNTitle", {guifg = color({dark = "nord13_gui", light = "yellow"})})
    highlight("NotifyINFOTitle", {guifg = color({dark = "nord4_gui", light = "fg"})})
    highlight("NotifyDEBUGTitle", {guifg = color({dark = "nord10_gui", light = "blue2"})})
    highlight("NotifyTRACETitle", {guifg = color({dark="nord15_gui", light="purple"})})
    -- LuaFormatter on

    highlight("NotifyERRORBody", {link = "Normal"})
    highlight("NotifyWARNBody", {link = "Normal"})
    highlight("NotifyINFOBody", {link = "Normal"})
    highlight("NotifyDEBUGBody", {link = "Normal"})
    highlight("NotifyTRACEBody", {link = "Normal"})
end

augroup("ExplorerHighlights", {
    {
        events = {"VimEnter", "ColorScheme"},
        targets = {"*"},
        command = apply_user_highlights
    }
})

apply_user_highlights()
