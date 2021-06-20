local augroup = require("tap.utils").augroup
local termcodes = require("tap.utils").termcodes

-- Automatically resize vim splits on resize
augroup("TapWinResize", {
    {
        events = {"VimResized"},
        targets = {"*"},
        command = 'execute "normal! ' .. termcodes("<c-w>") .. '="'

    }
})

-- Save and load vim views - remembers scroll position & folds
augroup("TapMkViews", {
    {events = {"BufWinLeave"}, targets = {"*.*"}, command = 'mkview'},
    {events = {"BufWinEnter"}, targets = {"*.*"}, command = 'silent! loadview'}
})
