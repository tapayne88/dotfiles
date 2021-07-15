vim.cmd [[
function! ParseURI(uri)
    return substitute(a:uri, '%\([a-fA-F0-9][a-fA-F0-9]\)', '\=nr2char("0x" . submatch(1))', "g")
endfunction

function! ClearDuplicateBuffers(uri)
    if ParseURI(a:uri) !=# a:uri
        sil! exe "bwipeout " . fnameescape(ParseURI(a:uri))
        exe "keepalt file " . fnameescape(ParseURI(a:uri))
        sil! exe "bwipeout " . fnameescape(a:uri)
    endif
endfunction

function! RzipOverride()
    " Disable vim-rzip's autocommands
    autocmd! zip BufReadCmd   zipfile:*,zipfile:*/*
    exe "au! zip BufReadCmd ".g:zipPlugin_ext

    autocmd zip BufReadCmd   zipfile:*,zipfile:*/* call ClearDuplicateBuffers(expand("<amatch>"))
    autocmd zip BufReadCmd   zipfile:*,zipfile:*/* call rzip#Read(ParseURI(expand("<amatch>")), 1)
    exe "au zip BufReadCmd ".g:zipPlugin_ext."     call rzip#Browse(ParseURI(expand('<amatch>')))"
endfunction

autocmd VimEnter * call RzipOverride()
]]
