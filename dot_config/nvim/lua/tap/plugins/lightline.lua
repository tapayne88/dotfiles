vim.cmd [==[
set showtabline=2               "Always show tabline

function! FileTypeIcon()
  return winwidth(0) > 70 ? (strlen(&filetype) ? WebDevIconsGetFileTypeSymbol() . ' ' . &filetype : 'no ft') : ''
endfunction

function! Git_branch() abort
  if fugitive#head() !=# ''
    return  fugitive#head() . "  "
  else
    return "\uf468"
  endif
endfunction

let g:lightline = {
\ 'colorscheme': 'nord',
\ 'active': {
\   'left': [['mode', 'paste'], ['filename', 'modified'], ['gitbranch']],
\   'right': [['percentinfo', 'lineinfo'], ['filetypeicon', 'filetype', 'readonly'], ['cocstatus']]
\ },
\ 'component': {
\   'percentinfo': '≡ %3p%%',
\   'vim_logo': "\ue7c5 ",
\   'git_branch': '%{Git_branch()}',
\ },
\ 'component_function': {
\   'gitbranch': 'fugitive#head',
\   'filetypeicon': 'FileTypeIcon',
\   'cocstatus': 'coc#status'
\ },
\ 'component_type': {
\   'readonly': 'error',
\   'cocstatuswarn': 'warning'
\   'cocstatuserror': 'error'
\ },
\ 'tabline': {
\   'left': [['vim_logo'], ['tabs']],
\   'right': [['git_branch']]
\ }
\ }

if ($TERM_EMU == 'kitty')
  let g:lightline.separator = { 'left': "", 'right': " " }
  let g:lightline.subseparator = { 'left': '\\', 'right': '\\' }
  let g:lightline.tabline_separator = { 'left': " ", 'right': "" }
  let g:lightline.tabline_subseparator = { 'left': "/", 'right': "/" }
endif

let g:coc_status_warning_sign = "◆ "
let g:coc_status_error_sign = "⨯ "

autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
]==]
