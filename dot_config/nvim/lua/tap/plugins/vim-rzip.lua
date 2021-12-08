vim.cmd [[
" Decode URI encoded characters
function! DecodeURI(uri)
    return substitute(a:uri, '%\([a-fA-F0-9][a-fA-F0-9]\)', '\=nr2char("0x" . submatch(1))', "g")
endfunction

" Attempt to clear non-focused buffers with matching name
function! ClearDuplicateBuffers(uri)
    " if our filename has URI encoded characters
    if DecodeURI(a:uri) !=# a:uri
        " wipeout buffer with URI decoded name - can print error if buffer in focus
        sil! exe "bwipeout " . fnameescape(DecodeURI(a:uri))
        " change the name of the current buffer to the URI decoded name
        exe "keepalt file " . fnameescape(DecodeURI(a:uri))
        " ensure we don't have any open buffer matching non-URI decoded name
        sil! exe "bwipeout " . fnameescape(a:uri)
    endif
endfunction

function! RzipOverride()
    " Disable vim-rzip's autocommands
    autocmd! zip BufReadCmd   zipfile:*,zipfile:*/*
    exe "au! zip BufReadCmd ".g:zipPlugin_ext

    " order is important here, setup name of new buffer correctly then fallback to vim-rzip's handling
    autocmd zip BufReadCmd   zipfile:*  call ClearDuplicateBuffers(expand("<afile>"))
    autocmd zip BufReadCmd   zipfile:*  call rzip#Read(DecodeURI(expand("<afile>")), 1)

    if has("unix")
        autocmd zip BufReadCmd   zipfile:*/*  call ClearDuplicateBuffers(expand("<afile>"))
        autocmd zip BufReadCmd   zipfile:*/*  call rzip#Read(DecodeURI(expand("<afile>")), 1)
    endif

    exe "au zip BufReadCmd ".g:zipPlugin_ext."  call rzip#Browse(DecodeURI(expand('<afile>')))"
endfunction

autocmd VimEnter * call RzipOverride()
]]
