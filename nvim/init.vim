"" ==================== Vim Plug ====================
call plug#begin('~/.config/nvim/plugged')

" Core Bundles
Plug 'altercation/vim-colors-solarized'
Plug 'scrooloose/nerdtree'                  " NerdTree (press F7)
Plug 'Xuyuanp/nerdtree-git-plugin'          " NerdTree Plugin for git stuff
Plug 'bogado/file-line'                     " Handle filenames with line numbers i.e. :20
Plug 'airblade/vim-gitgutter'               " + & - in column for changed lines
Plug 'tpope/vim-fugitive'                   " Git integration ':Gstatus' etc.
Plug 'tpope/vim-characterize'               " Adds 'ga' command to show character code
Plug 'tpope/vim-commentary'                 " Adds 'gc' & 'gcc' commands for commenting lines
Plug 'tpope/vim-eunuch'                     " Adds unix commands like ':Move' etc.
Plug 'itchyny/lightline.vim'                " Modified pretty statusline
Plug 'tpope/vim-surround'                   " Adds 'cs' command to change surround e.g. cs'<p> - would change 'this' => <p>this</p>
Plug 'tpope/vim-dispatch'                   " Async vim compiler plugins (used to run mocha test below)
Plug 'sjl/splice.vim'                       " Vim three-way merges
Plug 'wesQ3/vim-windowswap'                 " Swap panes positions
Plug 'kien/ctrlp.vim'                       " Fuzzy finder

" Language Stuff
Plug 'neomake/neomake'                      " General syntax checking
"Plug 'benjie/neomake-local-eslint.vim'      " Local eslint
Plug 'jelera/vim-javascript-syntax'         " Javascript
Plug 'mxw/vim-jsx'                          " JSX
Plug 'leafgarland/typescript-vim'           " Typescript
Plug 'lambdatoast/elm.vim'                  " Elm js stuff
Plug 'derekwyatt/vim-scala'                 " Scala syntax

" My forks
" Plug 'tapayne88/vim-phpunit'
" Plug 'tapayne88/vim-mochajs'

call plug#end()

"" ==================== Testing Area ====================
let g:NERDTreeUseSimpleIndicator = 1


"" ==================== General ====================
set number                      "Adds line numbers
set shiftwidth=4                "Determines indentation in normal mode (using '>>' or '<<')
set tabstop=8                   "Changes tabs to 4 spaces
set softtabstop=4               "Let backspace delete indent
set expandtab                   "Expands tabs to spaces, better for formatting
set autoindent                  "Sets up auto indent (copies indentation from line above)
set ls=2                        "Show filename perminently
set autoindent                  "Sets up auto indent (copies indentation from line above)
set backspace=2                 "Makes backspace key behave properly in insert mode
set ruler                       "Adds line and column number in status bar and shows progress through file
set hlsearch                    "Highlight search
set incsearch                   "Highlight dynamically as pattern is typed
set noshowmode                  "Hide the default mode text (e.g. -- INSERT -- below the statusline)
set wildignorecase              "Ignore case when opening files
set cursorline                  "Highlight line the cursor is on
set t_Co=16                     "Set to 16 for best compatibility with solarized
set ignorecase                  "Case insensitive search
set smartcase                   "Case sensitive when search contains upper-case characters

syntax enable
set background=dark
let g:solarized_termtrans=1
colorscheme solarized

" Better split defaults
set splitbelow
set splitright

let mapleader = ","
let maplocalleader = "-"

" Centralise backups, swapsfiles and undo history
set backupdir=~/.config/nvim/backups
set directory=~/.config/nvim/swaps
if exists("&undodir")
    set undodir=~/.config/nvim/undo
endif

"" ==================== Lightline ====================
let g:lightline = {
      \ 'colorscheme': '16color',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'git' ], [ 'filename' ] ],
      \   'right': [ [ 'percent', 'syntastic', 'lineinfo' ], [ 'fileinfo' ], ['filetype'] ]
      \ },
      \ 'component_function': {
      \     'git': 'MyGit',
      \     'filename': 'MyFilename',
      \     'fileinfo': 'MyFileInfo'
      \ }
    \}

function! MyFileInfo()
    return &fileencoding.'['.&fileformat.']'
endfunction

function! MyReadonly()
    if &filetype == "help"
        return ""
    elseif &readonly
        return ""
    else
        return ""
    endif
endfunction

function! MyModified()
    if &filetype == "help"
        return ""
    elseif &modified
        return "±"
    elseif &modifiable
        return ""
    else
        return ""
    endif
endfunction

function! MyFilename()
    return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
         \ ('' != expand('%:.') ? expand('%:.') : '[No Name]') .
         \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyGit()
    let hunk_symbols = ['+', '~', '-']
    let string = ''
    let hunks = exists('*GitGutterGetHunkSummary') ? GitGutterGetHunkSummary() : []

    if !empty(hunks)
        for i in [0, 1, 2]
            let string .= printf('%s%s ', hunk_symbols[i], hunks[i])
        endfor
    endif

    return exists("*fugitive#head") ? string."⎇  ".fugitive#head(7) : ""
endfunction


"" ==================== Fugitive ====================
autocmd BufReadPost fugitive://* set bufhidden=delete       "Stops fugitive files being left in buffer by removing all but currently visible


"" ==================== Key (re)Mappings ====================
" Makes up/down on line wrapped lines work better (more intuitive)
nnoremap j gj
nnoremap k gk
" Best tab navigation shorcuts
nnoremap <C-h> gT
nnoremap <C-l> gt
" Open last file with Ctrl+e
nnoremap <C-e> :e#<CR>
"Shows and hides invisible characters
noremap <leader>e :set list!<CR>

" Split resizing
nnoremap <leader>- :res -5<CR>
nnoremap <leader>= :res +5<CR>
nnoremap <leader>. :vertical resize -5<CR>
nnoremap <leader>, :vertical resize +5<CR>

" GitGutter Navigate
nmap gh <Plug>GitGutterNextHunk
nmap gH <Plug>GitGutterPrevHunk


"Toggle search highlighting
nnoremap <leader>h :set hlsearch!<CR>
"Displays files in buffer and quickly swap with regex matching or number
nnoremap <leader>l :ls<CR>:b<space>
"Toggle line numbers
nnoremap <leader>n :set number!<CR>
"Toggle line number mode
nnoremap <F3> :NumbersToggle<CR>
nnoremap <leader>evv :vsplit ~/.config/nvim/init.vim<CR>
nnoremap <leader>ev :split ~/.config/nvim/init.vim<CR>
nnoremap <leader>sv :source ~/.config/nvim/init.vim<CR>:echom "Reloaded init.vim"<CR>

nnoremap <leader>" ea"<esc>hbi"<esc>lel
nnoremap <leader>' ea'<esc>hbi'<esc>lel

nnoremap <leader>w :%s/\s\+$//e<CR>:echom "Cleared whitespace"<CR>

nnoremap <leader>ga :Git add %:p<CR><CR>
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gc :Gcommit -v -q<CR>
nnoremap <leader>gt :Gcommit -v -q %:p<CR>
nnoremap <leader>gd :Gdiff<CR>
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

map <F6> :Gblame<CR>
map <F7> :NERDTreeToggle<CR>


"" ==================== Misc ====================
" Miscellaneous config

au FileType gitcommit set tw=0      " Stop vim line wrap in gitcommit
set wildmode=list:longest,list:full " Simulate zsh tab completion
set scrolloff=4                     " Number of lines from vertical edge to start scrolling

if exists('+colorcolumn')
    " Add column line at 80 characters
    set colorcolumn=100
endif
