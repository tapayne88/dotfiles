"" ==================== Vim Plug ====================
call plug#begin('~/.vim/plugged')

" Core Bundles
Plug 'chriskempson/base16-vim'
Plug 'scrooloose/nerdtree'                  " NerdTree (press F7)
Plug 'Xuyuanp/nerdtree-git-plugin'          " NerdTree Plugin for git stuff
Plug 'bogado/file-line'                     " Handle filenames with line numbers i.e. :20
Plug 'airblade/vim-gitgutter'               " + & - in column for changed lines
Plug 'tpope/vim-fugitive'                   " Git integration ':Gstatus' etc.
Plug 'tpope/vim-characterize'               " Adds 'ga' command to show character code
Plug 'tpope/vim-commentary'                 " Adds 'gc' & 'gcc' commands for commenting lines
Plug 'tpope/vim-eunuch'                     " Adds unix commands like ':Move' etc.
Plug 'tpope/vim-surround'                   " Adds 'cs' command to change surround e.g. cs'<p> - would change 'this' => <p>this</p>
Plug 'tpope/vim-dispatch'                   " Async vim compiler plugins (used to run mocha test below)
Plug 'wesQ3/vim-windowswap'                 " Swap panes positions
Plug 'jaawerth/nrun.vim'                    " Run locally install npm stuff
Plug 'tpope/vim-sleuth'                     " Detect indentation
Plug 'christoomey/vim-tmux-navigator'       " Seemless vim <-> tmux navigation
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'w0rp/ale'                             " Linting
Plug 'sheerun/vim-polyglot'                 " Syntax highlighting
Plug 'itchyny/lightline.vim'                " Status line plugin
Plug 'daviesjamie/vim-base16-lightline'     " Status line theme
Plug 'mileszs/ack.vim'                      " ag searching`
Plug 'dominikduda/vim_current_word'         " highlight other occurrences of word
Plug 'tpope/vim-unimpaired'                 " More vim shortcuts
Plug 'haya14busa/is.vim'                    " Enhanced searching
Plug 'osyo-manga/vim-anzu'                  " Search - no. of matches
Plug 'benmills/vimux'                       " Easily interact with tmux from vim
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --tern-completer' }

call plug#end()

"" ==================== Testing Area ====================
" Start autocompletion after 4 chars
let g:ycm_min_num_of_chars_for_completion = 4
let g:ycm_min_num_identifier_candidate_chars = 4
let g:ycm_enable_diagnostic_highlighting = 0
" Don't show YCM's preview window [ I find it really annoying ]
set completeopt-=preview
let g:ycm_add_preview_to_completeopt = 0

"" ==================== General ====================
set number                      "Adds line numbers
set shiftwidth=2                "Determines indentation in normal mode (using '>>' or '<<')
set tabstop=4                   "Changes tabs to 4 spaces
set softtabstop=2               "Let backspace delete indent
set expandtab                   "Expands tabs to spaces, better for formatting
set autoindent                  "Sets up auto indent (copies indentation from line above)
set ls=2                        "Show filename permanently
set backspace=2                 "Makes backspace key behave properly in insert mode
set ruler                       "Adds line and column number in status bar and shows progress through file
set hlsearch                    "Highlight search
set incsearch                   "Highlight dynamically as pattern is typed
set noshowmode                  "Hide the default mode text (e.g. -- INSERT -- below the statusline)
set wildignorecase              "Ignore case when opening files
set cursorline                  "Highlight line the cursor is on
set ignorecase                  "Case insensitive search
set smartcase                   "Case sensitive when search contains upper-case characters
set splitbelow                  "Better split defaults
set splitright                  "Better split defaults
set mouse=                      "Disable mouse mode

let mapleader = ","
let maplocalleader = "\\"

"" ==================== Colors ====================
syntax enable
set background=dark
let base16colorspace=256  " Access colors present in 256 colorspace
colorscheme base16-default-dark

highlight Search guibg=Blue guifg=Black ctermbg=Blue ctermfg=Black
highlight IncSearch guibg=Blue guifg=Black ctermbg=Green ctermfg=Black

"" ==================== Config ====================
set backupdir=~/.config/nvim/backups
set directory=~/.config/nvim/swaps
if exists("&undodir")
    set undodir=~/.config/nvim/undo
endif

au FileType gitcommit set tw=0      " Stop vim line wrap in gitcommit
set wildmode=list:longest,list:full " Simulate zsh tab completion
set scrolloff=4                     " Number of lines from vertical edge to start scrolling

if exists('+colorcolumn')
    " Add column line at 80 characters
    set colorcolumn=100
endif

let g:python3_host_prog = '/usr/local/bin/python3'

"" ==================== FZF ====================
let g:fzf_layout = { 'down': '~20%' }
let g:fzf_statusline = 0 " disable statusline overwriting
let g:fzf_action = {
\  'ctrl-s': 'split',
\  'ctrl-v': 'vsplit'
\}
nnoremap <leader>l :Buffers<CR>
nnoremap <leader>p :GFiles<CR>
nnoremap <c-p> :GFiles<CR>
nnoremap <c-t> :GFiles<CR>

"" ==================== ALE ====================
let g:ale_fixers = {
\  'javascript': ['eslint'],
\}

let g:ale_linters = {
\  'javascript': ['eslint'],
\}

let g:ale_fix_on_save = 1

"" ==================== GitGutter ====================
let g:gitgutter_sign_added = "•"
let g:gitgutter_sign_modified = "•"
let g:gitgutter_sign_removed = "•"
let g:gitgutter_sign_modified_removed = "•"

"" ==================== Vimux ====================
map <Leader>vp :VimuxPromptCommand<CR>
map <Leader>tw :JestWatch<CR>
map <Leader>ta :call RunAllOnWatchJest()<CR>
map <Leader>tf :call RunFocusedOnWatchJest()<CR>
map <Leader>tb :call RunBufferOnWatchJest()<CR>

" yarn jest runner shamelessly stolen from https://github.com/tyewang/vimux-jest-test (and tweaked)
command! Jest :call _run_jest("")
command! JestWatch :call _run_jest(" --watch ")
command! JestOnBuffer :call RunBufferOnJest()
command! JestFocused :call RunFocuedOnJest()

function! RunBufferOnJest()
  call _run_jest(expand("%"))
endfunction

function! _get_focused_test_name()
  let test_name = _jest_test_search('\<describe(\|\<test(\|\<it(\|\<test.only(') "note the single quotes

  if test_name == ""
    echoerr "Couldn't find test name to run focused test."
    return
  endif

  return test_name
endfunction

function! RunFocuedOnJest()
  let test_name = _get_focused_test_name()
  call _run_jest(expand("%") . " -t " . "\"" . test_name . "\"")
endfunction

function! _jest_test_search(fragment)
  let line_num = search(a:fragment, "bs")
  if line_num > 0
    ''
    let test_string = split(split(getline(line_num), "(")[1], ",")[0]
    return strpart(test_string, 1, len(test_string) - 2)
  else
    return ""
  endif
endfunction

function! _run_jest(test)
  call VimuxRunCommand("yarn jest " . a:test)
endfunction

function! RunAllOnWatchJest()
  call _run_on_watch_jest("a")
endfunction

function! RunFocusedOnWatchJest()
  let test_name = _get_focused_test_name()
  call _run_on_watch_jest("t", test_name)
endfunction

function! RunBufferOnWatchJest()
  call _run_on_watch_jest("p", expand("%"))
endfunction

function! _run_on_watch_jest(type, ...)
  call VimuxSendText(a:type)

  if exists("a:1")
    call VimuxSendText(a:1)
    call VimuxSendKeys("Enter")
  endif
endfunction

"" ==================== Lightline ====================
let g:lightline = {
\ 'colorscheme': 'base16',
\ 'active': {
\   'left': [['mode', 'paste'], ['filename', 'modified'], ['gitbranch']],
\   'right': [['lineinfo'], ['percent'], ['readonly', 'linter_warnings', 'linter_errors', 'linter_ok']]
\ },
\ 'component_function': {
\   'gitbranch': 'fugitive#head'
\ },
\ 'component_expand': {
\   'linter_warnings': 'LightlineLinterWarnings',
\   'linter_errors': 'LightlineLinterErrors',
\   'linter_ok': 'LightlineLinterOk',
\ },
\ 'component_type': {
\   'readonly': 'error',
\   'linter_warnings': 'warning',
\   'linter_errors': 'error'
\ }
\ }

function! LightlineLinterWarnings() abort
   let l:counts = ale#statusline#Count(bufnr(''))
   let l:all_errors = l:counts.error + l:counts.style_error
   let l:all_non_errors = l:counts.total - l:all_errors
   return l:counts.total == 0 ? '' : printf('%d ◆', all_non_errors)
endfunction

function! LightlineLinterErrors() abort
   let l:counts = ale#statusline#Count(bufnr(''))
   let l:all_errors = l:counts.error + l:counts.style_error
   return l:counts.total == 0 ? '' : printf('%d ✗', all_errors)
endfunction

function! LightlineLinterOk() abort
   let l:counts = ale#statusline#Count(bufnr(''))
   return l:counts.total == 0 ? '✓' : ''
endfunction

autocmd User ALELint call s:MaybeUpdateLightline()

" Update and show lightline but only if it's visible (e.g., not in Goyo)
function! s:MaybeUpdateLightline()
  if exists('#lightline')
    call lightline#update()
  end
endfunction

"" ==================== Ack ====================
let g:ackprg = 'ag --smart-case --word-regexp --vimgrep'
let g:ackhighlight = 1

"" ==================== NERDTree ====================
let g:NERDTreeUseSimpleIndicator = 1

"" ==================== vim_current_word ====================
let g:vim_current_word#highlight_current_word = 0
let g:vim_current_word#highlight_twins = 1

"" ==================== Fugitive ====================
autocmd BufReadPost fugitive://* set bufhidden=delete       "Stops fugitive files being left in buffer by removing all but currently visible

"" ==================== Key (re)Mappings ====================
" Makes up/down on line wrapped lines work better (more intuitive)
nnoremap j gj
nnoremap k gk

map n <Plug>(is-nohl)<Plug>(anzu-n-with-echo)
map N <Plug>(is-nohl)<Plug>(anzu-N-with-echo)
map <F6> :Gblame<CR>
map <F7> :NERDTreeToggle<CR>

nmap gh <Plug>GitGutterNextHunk
nmap gH <Plug>GitGutterPrevHunk

" Open last file with Ctrl+e
nnoremap <C-e> :e#<CR>
nnoremap <C-s> :w<CR>

" Shows and hides invisible characters
noremap <leader>e :set list!<CR>

" Split resizing
nnoremap <leader>- :res -5<CR>
nnoremap <leader>= :res +5<CR>
nnoremap <leader>. :vertical resize -5<CR>
nnoremap <leader>, :vertical resize +5<CR>
nnoremap <leader>ag :Ack!<CR>
nnoremap <leader>x :cclose<CR>
nnoremap <leader>h :set hlsearch!<CR>
nnoremap <leader>n :set number!<CR>
nnoremap <leader>w :%s/\s\+$//e<CR>:echom "Cleared whitespace"<CR>
nnoremap <leader>evv :vsplit ~/.config/nvim/init.vim<CR>
nnoremap <leader>ev :split ~/.config/nvim/init.vim<CR>
nnoremap <leader>sv :source ~/.config/nvim/init.vim<CR>:echom "Reloaded .vimrc"<CR>
nnoremap <leader>" ea"<esc>hbi"<esc>lel
nnoremap <leader>' ea'<esc>hbi'<esc>lel
nnoremap <leader>nt :NERDTreeToggle<CR>
nnoremap <leader>ff :NERDTreeFind<CR>
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
nnoremap <leader>gm :Gmove<Space>
nnoremap <leader>gb :Git branch<Space>
nnoremap <leader>go :Git checkout<Space>
nnoremap <leader>gps :Dispatch! git push<CR>
nnoremap <leader>gpl :Dispatch! git pull<CR>
