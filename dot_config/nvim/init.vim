let s:vim_path = expand('~/.vim')
let s:vimrc = expand('~/.vimrc')
if has("nvim")
  let s:vim_path = expand('~/.config/nvim')
  let s:vimrc = expand('~/.config/nvim/init.vim')
endif

"" ==================== Vim Plug ====================
call plug#begin(s:vim_path.'/plugged')

let vimTestCommands = ['TestNearest', 'TestFile', 'TestSuite', 'TestLast', 'TestVisit']

" Core Bundles
Plug 'arcticicestudio/nord-vim'
Plug 'lervag/file-line'                     " Handle filenames with line numbers i.e. :20
Plug 'mhinz/vim-signify'                    " + & - in column for changed lines
Plug 'tpope/vim-fugitive'                   " Git integration ':Gstatus' etc.
Plug 'tpope/vim-characterize'               " Adds 'ga' command to show character code
Plug 'tpope/vim-commentary'                 " Adds 'gc' & 'gcc' commands for commenting lines
Plug 'tpope/vim-eunuch'                     " Adds unix commands like ':Move' etc.
Plug 'tpope/vim-surround'                   " Adds 'cs' command to change surround e.g. cs'<p> - would change 'this' => <p>this</p>
Plug 'tpope/vim-dispatch',
  \ { 'on': 'Dispatch' }                    " Async vim compiler plugins (used to run mocha test below)
Plug 'jaawerth/nrun.vim'                    " Put locally installed npm module .bin at front of path
Plug 'tpope/vim-sleuth'                     " Detect indentation
Plug 'christoomey/vim-tmux-navigator'       " Seemless vim <-> tmux navigation
Plug '~/.fzf'
Plug 'junegunn/fzf.vim'                     " All things FZF
Plug 'chengzeyi/fzf-preview.vim'            " Few utility FZF functions
Plug 'mileszs/ack.vim'                      " ag searching
Plug 'itchyny/lightline.vim'                " Status line plugin
Plug 'sheerun/vim-polyglot'                 " Syntax highlighting
Plug 'leafgarland/typescript-vim'
Plug 'dominikduda/vim_current_word'         " highlight other occurrences of word
Plug 'benmills/vimux'                       " Easily interact with tmux from vim
Plug 'wincent/loupe'                        " more searching configuration
Plug 'janko-m/vim-test',
  \ { 'on': vimTestCommands }               " easy testing
Plug 'terryma/vim-multiple-cursors'         " multiple cursors
Plug 'tweekmonster/startuptime.vim',
  \ { 'on': 'StartupTime' }                 " easier vim startup time profiling
Plug 'iamcco/markdown-preview.nvim',
  \ { 'do': ':call mkdp#util#install()'
  \ , 'for': 'markdown', 'on': 'MarkdownPreview' }
Plug 'rhysd/git-messenger.vim',
  \ { 'on': 'GitMessenger' }
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

call plug#end()

"" ==================== General ====================
set lazyredraw                  "Improve scrolling performance with cursorline
set ttyfast                     "More characters will be sent to the screen for redrawing
set ttimeout
set ttimeoutlen=50              "Time waited for key press(es) to complete. It makes for a faster key response
set showcmd                     "Display incomplete commands
set wildmenu                    "A better menu in command mode
set wildmode=longest:full,full
set scrolloff=4                 "Number of lines from vertical edge to start scrolling
set number                      "Adds line numbers
set cursorline                  "Highlight line the cursor is on
set colorcolumn=80              "Add column line at 80 characters
set splitbelow                  "Better split defaults
set splitright
set autoindent                  "Sets up auto indent (copies indentation from line above)
set incsearch                   "Highlight dynamically as pattern is typed
set hlsearch                    "Highlight search
set ignorecase                  "Case insensitive search
set smartcase                   "Case sensitive when search contains upper-case characters
set wildignorecase              "Ignore case when opening files
set laststatus=2                "Always display the status line
set noswapfile                  "Disable swap files
set autoread                    "Automatically read changes in the file
set hidden                      "Hide buffers instead of closing them even if they contain unwritten changes
set backspace=indent,eol,start  "Make backspace behave properly in insert mode
set noshowmode                  "Hide the default mode text (e.g. -- INSERT -- below the statusline)
set tabstop=4                   "Changes tabs to 4 spaces
set shiftwidth=2                "Determines indentation in normal mode (using '>>' or '<<')
set softtabstop=2               "Let backspace delete indent
set expandtab                   "Expands tabs to spaces, better for formatting
set spelllang=en                "Set vim's spell check language

let mapleader = ","
let maplocalleader = "\\"

"" ==================== Config ====================
" disable sleuth for markdown files due to slowdown caused in combination with
" vim-polyglot
autocmd FileType markdown let b:sleuth_automatic = 0

" disable typescript polyglot (don't like it)
let g:polyglot_disabled = ['typescript']

" Automatically resize vim splits on resize
autocmd VimResized * execute "normal! \<c-w>="

" Save and load vim views - remembers scroll position & folds
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent! loadview

"" ==================== Colors ====================
let g:nord_italic = 1
let g:nord_underline = 1
let g:nord_uniform_diff_background = 1

syntax enable
colorscheme nord

highlight Search guibg=Blue guifg=Black ctermbg=Blue ctermfg=Black
highlight IncSearch guibg=Blue guifg=Black ctermbg=Green ctermfg=Black

highlight typescriptReserved cterm=italic ctermfg=blue
highlight typescriptStatement cterm=italic ctermfg=blue
highlight typescriptIdentifier cterm=italic
highlight jsClassKeyword cterm=italic
highlight jsExtendsKeyword cterm=italic
highlight jsReturn cterm=italic
highlight jsThis  cterm=italic
highlight htmlArg cterm=italic
highlight Comment cterm=italic
highlight Type    cterm=italic

highlight link gitmessengerHeader Identifier
highlight link gitmessengerHash Comment
highlight link gitmessengerHistory Constant
highlight link gitmessengerPopupNormal CursorLine

"" ==================== Folding ====================
set foldmethod=syntax   "syntax highlighting items specify folds
set foldcolumn=1        "defines 1 col at window left, to indicate folding
set foldlevelstart=99   "start file with all folds opened

"" ==================== netrw ====================
let g:netrw_liststyle = 3

"" ==================== FZF ====================
autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

let g:fzf_preview_window = 'right:60%'
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
let g:fzf_action = {
\  'ctrl-s': 'split',
\  'ctrl-v': 'vsplit'
\}
let g:fzf_colors = {
  \ 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment']
  \ }

function! MyGitFiles()
  let preview_window = get(g:, 'fzf_preview_window', 'right')

  return fzf#run(fzf#wrap(fzf#vim#with_preview({
  \ 'source': 'git ls-files `pwd` && git ls-files --others --exclude-standard `pwd`',
  \ 'options': '--multi'
  \ }, preview_window, '?')))
endfunction

function! MyBuffers()
  let preview_window = get(g:, 'fzf_preview_window', 'right')

  return fzf#vim#buffers(fzf#wrap(fzf#vim#with_preview({}, preview_window, '?')))
endfunction

function! FindWord(word)
  let preview_window = get(g:, 'fzf_preview_window', 'right')

  return fzf#vim#ag(a:word, fzf#wrap(fzf#vim#with_preview({}, preview_window, '?')))
endfunction


nnoremap <leader>l :call MyBuffers()<CR>
nnoremap <leader>t :call MyGitFiles()<CR>
nnoremap <leader>f :FZFAg<CR>
nnoremap <c-t> :call MyGitFiles()<CR>
nnoremap <c-f> :FZFAg<CR>
nnoremap <leader>fw :call FindWord(expand('<cword>'))<CR>

"" ==================== Ack ====================
let g:ackprg = 'ag --smart-case --word-regexp --vimgrep'
let g:ackhighlight = 1
nnoremap <leader>ag :Ack!<CR>

"" ==================== Signify ====================
let g:signify_sign_add = "•"
let g:signify_sign_change = "•"
let g:signify_sign_delete = "•"
let g:signify_sign_changedelete = "•"
let g:signify_sign_show_count = 0
let g:signify_sign_show_text = 1
let g:signify_update_on_focusgained = 1

nmap gh <plug>(signify-next-hunk)
nmap gH <plug>(signify-prev-hunk)

"" ==================== Coc ====================
let g:coc_global_extensions = ['coc-eslint', 'coc-tslint', 'coc-prettier', 'coc-json', 'coc-tsserver']

inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

"" ==================== Vimux ====================
map <Leader>vp :VimuxPromptCommand<CR>

"" ==================== Vim-test ====================
let g:test#runner_commands = ['Jest']
let g:test#strategy = "vimux"

" Below needed for tests inside spec folder
let g:test#javascript#jest#file_pattern = '\v((__tests__|spec)/.*|(spec|test))\.(js|jsx|coffee|ts|tsx)$'
let g:test#javascript#jest#executable = "yarn jest"

nmap <silent> t<C-n> :TestNearest<CR> " t Ctrl+n
nmap <silent> t<C-f> :TestFile<CR>    " t Ctrl+f
" nmap <silent> t<C-s> :TestSuite<CR>   " t Ctrl+s
nmap <silent> t<C-l> :TestLast<CR>    " t Ctrl+l
nmap <silent> t<C-g> :TestVisit<CR>   " t Ctrl+g
nmap <silent> t<C-w> :Jest --watch<CR>

"" ==================== Lightline ====================
let g:lightline#ale#indicator_checking = ""
let g:lightline#ale#indicator_warnings = "◆ "
let g:lightline#ale#indicator_errors = "✗ "
let g:lightline#ale#indicator_ok = "✔"

function! LightLineCocStatusWarn() abort
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info) | return '' | endif
  if get(info, 'warning', 0) || get(info, 'information', 0)
    return printf(g:lightline#ale#indicator_warnings . '%d', (info['warning'] + info['information']))
  endif
  return ''
endfunction

function! LightLineCocStatusError() abort
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info) | return '' | endif
  if get(info, 'error', 0)
    return printf(g:lightline#ale#indicator_errors . '%d', info['error'])
  endif
  return ''
endfunction

let g:lightline = {
\ 'colorscheme': 'nord_alt',
\ 'separator': {
\   'left': '❮',
\   'right': '❯',
\ },
\ 'tabline_separator': {
\   'left': '',
\   'right': '',
\ },
\ 'active': {
\   'left': [['mode', 'paste'], ['filename', 'modified'], ['gitbranch']],
\   'right': [['percentinfo', 'lineinfo'], ['filetype', 'readonly'], ['cocstatuswarn', 'cocstatuserror']]
\ },
\ 'component': {
\   'percentinfo': '≡ %3p%%',
\ },
\ 'component_function': {
\   'gitbranch': 'fugitive#head',
\   'cocstatuswarn': 'LightLineCocStatusWarn',
\   'cocstatuserror': 'LightLineCocStatusError',
\ },
\ 'component_type': {
\   'readonly': 'error',
\   'cocstatuswarn': 'warning',
\   'cocstatuserror': 'error',
\ }
\ }

"" ==================== Coc-nvim ====================
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

"" ==================== vim_current_word ====================
let g:vim_current_word#highlight_current_word = 0
let g:vim_current_word#highlight_twins = 1

"" ==================== Fugitive ====================
autocmd BufReadPost fugitive://* set bufhidden=delete       "Stops fugitive files being left in buffer by removing all but currently visible

"" ==================== Key (re)Mappings ====================
" Makes up/down on line wrapped lines work better (more intuitive)
nnoremap j gj
nnoremap k gk

"keep text selected after indentation
vnoremap < <gv
vnoremap > >gv

" Shows and hides invisible characters
noremap <leader>e :set list!<CR>
nnoremap <leader>- :resize -5<CR>
nnoremap <leader>= :resize +5<CR>
nnoremap <leader>. :vertical resize -20<CR>
nnoremap <leader>, :vertical resize +20<CR>
nnoremap <leader>x :cclose<CR>
nnoremap <leader>h :set hlsearch!<CR>
nnoremap <leader>n :set number!<CR>
nnoremap <leader>w :%s/\s\+$//e<CR>:echom "Cleared whitespace"<CR>
nnoremap <leader>evv :vsplit $MYVIMRC<CR>
nnoremap <leader>ev :split $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>:echom 'Reloaded '. $MYVIMRC<CR>
nnoremap <leader>ff :Ex<CR>
nnoremap <leader>fp :echo @%<CR>
nnoremap <leader>ga :Git add %:p<CR><CR>
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gc :Gcommit -v -q<CR>
nnoremap <leader>gt :Gcommit -v -q %:p<CR>
nnoremap <leader>gd :Gvdiff<CR>
nnoremap <leader>ge :Gedit<CR>
nnoremap <leader>gr :Gread<CR>
nnoremap <leader>gw :Gwrite<CR><CR>
nnoremap <leader>gl :silent! Glog<CR>:bot copen<CR>
nnoremap <leader>gp :Ggrep -n<Space>
nnoremap <leader>gm :GitMessenger<CR>
nnoremap <leader>gb :Git branch<Space>
nnoremap <leader>go :Git checkout<Space>
nnoremap <leader>gps :Dispatch! git push<CR>
nnoremap <leader>gpl :Dispatch! git pull<CR>

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
