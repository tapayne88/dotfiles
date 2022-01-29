local highlight = require("tap.utils").highlight
local augroup = require("tap.utils").augroup
local color = require("tap.utils").color

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
    highlight('FloatBorder', {
        guifg = color({dark = "nord2_gui", light = "blue0"}),
        guibg = color({dark = "nord0_gui", light = "none"})
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
