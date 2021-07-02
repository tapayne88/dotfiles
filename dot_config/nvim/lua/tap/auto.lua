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

vim.cmd [[
    function! YarnPnPRead(uri)
        let l:parsed_uri = substitute(a:uri, '%\([a-fA-F0-9][a-fA-F0-9]\)', '\=nr2char("0x" . submatch(1))', "g")
        let l:zipfile_uri = substitute(l:parsed_uri, '^yarnpnp', 'zipfile', "g")
        call rzip#Read(l:zipfile_uri, 1)
    endfunction

    augroup YarnPnP
        autocmd!
        autocmd BufReadCmd yarnpnp:*,yarnpnp:*/* call YarnPnPRead(expand('<amatch>'))
    augroup END
]]
