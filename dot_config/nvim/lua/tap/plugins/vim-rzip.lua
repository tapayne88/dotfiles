vim.cmd [[
" Decode URI encoded characters
function! DecodeURI(uri)
    return substitute(a:uri, '%\([a-fA-F0-9][a-fA-F0-9]\)', '\=nr2char("0x" . submatch(1))', "g")
endfunction

" Attempt to clear non-focused buffers with matching name
function! ClearDuplicateBuffers()
    let uri = bufname()

    " if our filename has URI encoded characters
    if DecodeURI(uri) !=# uri
        " wipeout buffer with URI decoded name - can print error if buffer in focus
        sil! exe "bwipeout " . fnameescape(DecodeURI(uri))
        " change the name of the current buffer to the URI decoded name
        exe "keepalt file " . fnameescape(DecodeURI(uri))
        " ensure we don't have any open buffer matching non-URI decoded name
        sil! exe "bwipeout " . fnameescape(uri)
    endif
endfunction

function! RzipRead()
    let uri = bufname()
    call rzip#Read(DecodeURI(uri), 1)
endfunction

function! RzipOverride()
    " Disable vim-rzip's autocommands
    autocmd! zip BufReadCmd   zipfile:*,zipfile:*/*
    exe "au! zip BufReadCmd ".g:zipPlugin_ext

    " order is important here, setup name of new buffer correctly then fallback to vim-rzip's handling
    autocmd zip BufReadCmd   zipfile:*  call ClearDuplicateBuffers()
    autocmd zip BufReadCmd   zipfile:*  call RzipRead()

    if has("unix")
        autocmd zip BufReadCmd   zipfile:*/*  call ClearDuplicateBuffers()
        autocmd zip BufReadCmd   zipfile:*/*  call RzipRead()
    endif

    exe "au zip BufReadCmd ".g:zipPlugin_ext."  call rzip#Browse(DecodeURI(expand('<amatch>')))"
endfunction

autocmd VimEnter * call RzipOverride()
]]
