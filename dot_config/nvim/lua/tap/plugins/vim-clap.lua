vim.cmd [[
let g:clap_open_action = {
\  'ctrl-t': 'tab split',
\  'ctrl-s': 'split',
\  'ctrl-v': 'vsplit'
\ }
let g:clap_layout = {
\ 'width': '90%',
\ 'height': '33%',
\ 'row': '33%',
\ 'col': '5%'
\ }
" Below doesn't work with icons despite being a very close copy of internal
" git_files provider - some custom handle I can't access allows icons support.
" Should re-enable when I can access it
let g:clap_provider_git_files_plus = {
\ 'source': 'git ls-files && git ls-files --others --exclude-standard',
\ 'sink': function('clap#provider#files#sink_impl'),
\ 'sink*': function('clap#provider#files#sink_star_impl'),
\ 'on_move': function('clap#provider#files#on_move_impl'),
\ 'syntax': 'clap_files',
\ 'enable_rooter': v:true,
\ 'support_open_action': v:true
\ }

nnoremap <leader>l :Clap buffers<CR>
nnoremap <leader>t :Clap git_files<CR>
nnoremap <leader>f :Clap grep2<CR>
nnoremap <c-t> :Clap git_files<CR>
nnoremap <c-f> :Clap grep2<CR>
nnoremap <leader>fw :Clap grep2 ++query=<cword><CR>
]]
