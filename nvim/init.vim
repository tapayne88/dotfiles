"" ==================== Vim Plug ====================
call plug#begin('~/.config/nvim/plugged')

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
Plug 'vim-airline/vim-airline'              " Modified pretty statusline
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-surround'                   " Adds 'cs' command to change surround e.g. cs'<p> - would change 'this' => <p>this</p>
Plug 'tpope/vim-dispatch'                   " Async vim compiler plugins (used to run mocha test below)
Plug 'sjl/splice.vim'                       " Vim three-way merges
Plug 'wesQ3/vim-windowswap'                 " Swap panes positions
Plug 'jaawerth/nrun.vim'                    " Run locally install npm stuff

" Language Stuff
Plug 'neomake/neomake'                      " General syntax checking
Plug 'jaawerth/neomake-local-eslint-first'  " Local eslint
Plug 'jelera/vim-javascript-syntax'         " Javascript
Plug 'mxw/vim-jsx'                          " JSX
Plug 'leafgarland/typescript-vim'           " Typescript
Plug 'lambdatoast/elm.vim'                  " Elm js stuff
Plug 'derekwyatt/vim-scala'                 " Scala syntax

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
set ignorecase                  "Case insensitive search
set smartcase                   "Case sensitive when search contains upper-case characters
set splitbelow                  "Better split defaults
set splitright                  "Better split defaults
set mouse=                      "Disable mouse mode

"" ==================== Colors ====================
syntax enable
set background=dark
let base16colorspace=256  " Access colors present in 256 colorspace
colorscheme base16-default-dark
let g:airline_theme='base16'
let g:airline_extensions=[]
"" ==================== Colors ====================

let mapleader = ","
let maplocalleader = "-"

" Centralise backups, swapsfiles and undo history
set backupdir=~/.config/nvim/backups
set directory=~/.config/nvim/swaps
if exists("&undodir")
    set undodir=~/.config/nvim/undo
endif

"" ==================== NeoMake ====================
let g:neomake_open_list=2
let g:neomake_list_height=5
if findfile('.eslintrc', '.;') !=# ''
    let g:neomake_javascript_enabled_makers = ['eslint']
    autocmd BufReadPost,BufWritePost * Neomake
endif

"noremap <leader>q :something<CR>

" let g:neomake_javascript_jest_maker = {
"     \ 'exe': 'npm test',
"     \ 'args': [],
"     \ 'errorformat': '%A%f: line %l\, col %v\, %m \(%t%*\d\)',
"     \ }
" let g:neomake_javascript_enabled_makers = ['jest']


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
" Shows and hides invisible characters
noremap <leader>e :set list!<CR>
" Toggle search highlighting
nnoremap <leader>h :set hlsearch!<CR>
" Displays files in buffer and quickly swap with regex matching or number
nnoremap <leader>l :ls<CR>:b<space>
" Toggle line numbers
nnoremap <leader>n :set number!<CR>

nnoremap <leader>w :%s/\s\+$//e<CR>:echom "Cleared whitespace"<CR>

" Split resizing
nnoremap <leader>- :res -5<CR>
nnoremap <leader>= :res +5<CR>
nnoremap <leader>. :vertical resize -5<CR>
nnoremap <leader>, :vertical resize +5<CR>

" GitGutter Navigate
nmap gh <Plug>GitGutterNextHunk
nmap gH <Plug>GitGutterPrevHunk

" Editing neovim config
nnoremap <leader>evv :vsplit ~/.config/nvim/init.vim<CR>
nnoremap <leader>ev :split ~/.config/nvim/init.vim<CR>
nnoremap <leader>sv :source ~/.config/nvim/init.vim<CR>:echom "Reloaded init.vim"<CR>

"Wrapping with quotes
nnoremap <leader>" ea"<esc>hbi"<esc>lel
nnoremap <leader>' ea'<esc>hbi'<esc>lel

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
