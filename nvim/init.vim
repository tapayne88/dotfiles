let s:vim_path = expand('~/.vim')
let s:vimrc = expand('~/.vimrc')
if has("nvim")
  let s:vim_path = expand('~/.config/nvim')
  let s:vimrc = expand('~/.config/nvim/init.vim')
endif

function! DownloadVimPlug()
  execute '!curl -fLo '.s:vim_path.'/autoload/plug.vim --create-dirs'
    \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endfunction

if empty(glob(s:vim_path.'/autoload/plug.vim'))
  silent call DownloadVimPlug()
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"" ==================== Vim Plug ====================
call plug#begin(s:vim_path.'/plugged')

let nerdTreeCommands = ['NERDTreeFind', 'NERDTreeToggle']
let vimTestCommands = ['TestNearest', 'TestFile', 'TestSuite', 'TestLast', 'TestVisit']

" Core Bundles
Plug 'arcticicestudio/nord-vim'
Plug 'scrooloose/nerdtree', { 'on': nerdTreeCommands }
Plug 'Xuyuanp/nerdtree-git-plugin',
  \ { 'on': nerdTreeCommands }
Plug 'bogado/file-line'                     " Handle filenames with line numbers i.e. :20
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
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  \| Plug 'junegunn/fzf.vim'
Plug 'mileszs/ack.vim'                      " ag searching
Plug 'w0rp/ale'                             " Linting
Plug 'itchyny/lightline.vim'                " Status line plugin
Plug 'maximbaz/lightline-ale'               " Linting status for lightline
Plug 'sheerun/vim-polyglot'                 " Syntax highlighting
Plug 'dominikduda/vim_current_word'         " highlight other occurrences of word
Plug 'benmills/vimux'                       " Easily interact with tmux from vim
Plug 'wincent/loupe'                        " more searching configuration
Plug 'janko-m/vim-test',
  \ { 'on': vimTestCommands }               " easy testing
Plug 'terryma/vim-multiple-cursors'         " multiple cursors
Plug 'tweekmonster/startuptime.vim',
  \ { 'on': 'StartupTime' }                 " easier vim startup time profiling
Plug 'peitalin/vim-jsx-typescript'
Plug 'mhartington/nvim-typescript',
  \ { 'do': './install.sh'
  \ , 'for': 'typescript' }                 " typescript definitions
Plug 'iamcco/markdown-preview.nvim',
  \ { 'do': ':call mkdp#util#install()'
  \ , 'for': 'markdown', 'on': 'MarkdownPreview' }
Plug 'rhysd/git-messenger.vim',
  \ { 'on': 'GitMessenger' }

call plug#end()

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
set lazyredraw                  "Improve scrolling performance with cursorline
set ignorecase                  "Case insensitive search
set smartcase                   "Case sensitive when search contains upper-case characters
set splitbelow                  "Better split defaults
set splitright                  "Better split defaults
set mouse=                      "Disable mouse mode
set updatetime=100              "Reduce vim's update delay for vim-gutter
set spelllang=en                "Set vim's spell check language

let mapleader = ","
let maplocalleader = "\\"

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

"" ==================== Config ====================
let &backupdir = s:vim_path.'/backups'
let &directory = s:vim_path.'/swaps'
if exists("&undodir")
  let &undodir = s:vim_path.'/undo'
endif

" au FileType gitcommit set tw=0      " Stop vim line wrap in gitcommit
set wildmode=list:longest,list:full " Simulate zsh tab completion
set scrolloff=4                     " Number of lines from vertical edge to start scrolling

if exists('+colorcolumn')
    " Add column line at 100 characters
    set colorcolumn=100
endif

" disable sleuth for markdown files due to slowdown caused in combination with
" vim-polyglot
autocmd FileType markdown let b:sleuth_automatic = 0

"" ==================== FZF ====================
let g:fzf_layout = { 'down': '~20%' }
let g:fzf_statusline = 0 " disable statusline overwriting
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
  return fzf#run(fzf#wrap({
  \ 'source': 'git ls-files `pwd` && git ls-files --others --exclude-standard `pwd`',
  \ 'options': '--multi'
  \ }))
endfunction

nnoremap <leader>l :Buffers<CR>
nnoremap <leader>t :call MyGitFiles()<CR>
nnoremap <leader>f :Ag<CR>
nnoremap <c-t> :call MyGitFiles()<CR>
nnoremap <c-f> :Ag<CR>
nnoremap <leader>fw :call fzf#vim#ag(expand('<cword>'))<CR>

command! -bang -nargs=* Ag
  \ call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)

"" ==================== Ack ====================
let g:ackprg = 'ag --smart-case --word-regexp --vimgrep'
let g:ackhighlight = 1
nnoremap <leader>ag :Ack!<CR>

"" ==================== ALE ====================
let g:ale_fixers = {
\  'javascript': ['prettier', 'eslint'],
\  'typescript': ['prettier', 'eslint'],
\}

let g:ale_linters = {
\  'javascript': ['eslint'],
\  'typescript': ['eslint', 'tslint', 'tsserver'],
\}

let g:ale_fix_on_save = 1
let g:polyglot_disabled = ['markdown', 'md']
nnoremap <leader>at :call ToggleAleOnSaveBuffer()<CR>

function! ToggleAleOnSaveBuffer()
  let l:fix_on_save = 0
  if exists("b:ale_fix_on_save")
    let l:fix_on_save = b:ale_fix_on_save == 1 ? 0 : 1
  endif

  let b:ale_fix_on_save = l:fix_on_save
  echom 'b:ale_fix_on_save=' . l:fix_on_save
endfunction

"" ==================== GitGutter ====================
" let g:gitgutter_sign_added = "•"
" let g:gitgutter_sign_modified = "•"
" let g:gitgutter_sign_removed = "•"
" let g:gitgutter_sign_modified_removed = "•"

" nmap gh <Plug>GitGutterNextHunk
" nmap gH <Plug>GitGutterPrevHunk

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

let g:lightline = {
\ 'colorscheme': 'nord',
\ 'active': {
\   'left': [['mode', 'paste'], ['filename', 'modified'], ['gitbranch']],
\   'right': [['lineinfo'], ['percent'], ['readonly', 'linter_warnings', 'linter_errors', 'linter_ok']]
\ },
\ 'component_function': {
\   'gitbranch': 'fugitive#head'
\ },
\ 'component_expand': {
\   'linter_checking': 'lightline#ale#checking',
\   'linter_warnings': 'lightline#ale#warnings',
\   'linter_errors': 'lightline#ale#errors',
\   'linter_ok': 'lightline#ale#ok',
\ },
\ 'component_type': {
\   'readonly': 'error',
\   'linter_warnings': 'warning',
\   'linter_errors': 'error'
\ }
\ }

"" ==================== nvim-typescript ====================
nnoremap <leader>df :TSDefPreview<CR>
nnoremap <leader>st :TSType<CR>
" autocmd! CursorHold *.ts,*.tsx TSType    " below is useful but blocks TS errors

"" ==================== NERDTree ====================
let g:NERDTreeUseSimpleIndicator = 1

"" ==================== vim_current_word ====================
let g:vim_current_word#highlight_current_word = 0
let g:vim_current_word#highlight_twins = 1

"" ==================== Fugitive ====================
autocmd BufReadPost fugitive://* set bufhidden=delete       "Stops fugitive files being left in buffer by removing all but currently visible

"" ==================== Key (re)Mappings ====================
" Automatically resize vim splits on resize
autocmd VimResized * execute "normal! \<c-w>="

" Makes up/down on line wrapped lines work better (more intuitive)
nnoremap j gj
nnoremap k gk

" Open last file with Ctrl+e
nnoremap <C-e> :e#<CR>

" Shows and hides invisible characters
noremap <leader>e :set list!<CR>

" Split resizing
nnoremap <leader>- :res -5<CR>
nnoremap <leader>= :res +5<CR>
nnoremap <leader>. :vertical resize -20<CR>
nnoremap <leader>, :vertical resize +20<CR>
nnoremap <leader>x :cclose<CR>
nnoremap <leader>h :set hlsearch!<CR>
nnoremap <leader>n :set number!<CR>
nnoremap <leader>w :%s/\s\+$//e<CR>:echom "Cleared whitespace"<CR>
nnoremap <leader>evv :vsplit $MYVIMRC<CR>
nnoremap <leader>ev :split $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>:echom 'Reloaded '. $MYVIMRC<CR>
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
nnoremap <leader>gm :GitMessenger<CR>
nnoremap <leader>gb :Git branch<Space>
nnoremap <leader>go :Git checkout<Space>
nnoremap <leader>gps :Dispatch! git push<CR>
nnoremap <leader>gpl :Dispatch! git pull<CR>

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
