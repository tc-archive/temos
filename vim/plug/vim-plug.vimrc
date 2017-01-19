"== vim-plug plugins ==========================================================

call plug#begin()

"--- general ------------------------------------------------------------------

"--- sensible vim defaults
Plug 'tpope/vim-sensible'

"--- colour schemes
Plug 'dandorman/vim-colors'
Plug 'jnurmine/Zenburn'

"--- vim status bar
"# Plug 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Plug 'bling/vim-airline'

"--- fuzzy match file search
Plug 'ctrlpvim/ctrlp.vim'

"--- filesystem browser
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'jistr/vim-nerdtree-tabs'
Plug 'christoomey/vim-tmux-navigator'

"--- multi-language syntax checking
Plug 'scrooloose/syntastic'

"--- code folding
Plug 'tmhedberg/SimpylFold'

"--- code completion
Plug 'Valloric/YouCompleteMe', { 'for': ['c', 'cpp', 'go'] , 'do': './install.sh' }
autocmd! User YouCompleteMe if !has('vim_starting') | call youcompleteme#Enable() | endif

"--- git integration
Plug 'tpope/vim-fugitive'


"--- language specific -------------------------------------------------------

"--- clojure
Plug 'guns/vim-clojure-static'
Plug 'kien/rainbow_parentheses.vim', {'for': 'clojure'}
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

"--- docker
Plug 'ekalinin/Dockerfile.vim'

"--- elixir
Plug 'elixir-lang/vim-elixir'

"--- golang
Plug 'fatih/vim-go'

"--- javascript
Plug 'lukaszb/vim-web-indent'
Plug 'pangloss/vim-javascript'
Plug 'jelera/vim-javascript-syntax'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'Shutnik/jshint2.vim'
Plug 'mxw/vim-jsx'
Plug 'claco/jasmine.vim'

"--- json
Plug 'elzr/vim-json'

"--- python
Plug 'nvie/vim-flake8'
Plug 'vim-scripts/indentpython.vim'

"--- ruby
Plug 'vim-ruby/vim-ruby'

"--- rust
Plug 'rust-lang/rust.vim'

"--- web development
Plug 'othree/html5.vim'
Plug 'hail2u/vim-css3-syntax'
Plug 'cakebaker/scss-syntax.vim'
Plug 'aaronjensen/vim-sass-status'
Plug 'groenewege/vim-less'
Plug 'tpope/vim-haml'

call plug#end()

"== general config ============================================================

"--- au command to detect bad whitespace
au BufRead,BufNewFile
  \ *.c, *.cpp, *.h,
  \ *.clj, *.edn,
  \ *.erl,
  \ *.ex, *.exs,
  \ *.go,
  \ *.hs, *.cabal,
  \ *.py, *.pyw,
  \ *.rb
  \ match BadWhitespace /\s\+$/

"--- set clipboard
set clipboard=unnamed


"== editor configuration  ======================================================

filetype plugin indent on

"--- show existing tab with 4 spaces width
set tabstop=4

"--- when indenting with '>', use 4 spaces width
set shiftwidth=4

"--- on pressing tab, insert 4 spaces
set expandtab

"--- paste options
set pastetoggle=<F2>


"== ui Look  and feel ==========================================================

set number      " line numbering
set t_Co=256    " Force 256 colors
set t_ut=       " improve screen clearing by using the background color

if has('gui_running')
  set background=dark
  colorscheme zenburn
else
  colorscheme molokai
endif

"# let python_highlight_all=1
"# syntax on
syntax enable
set enc=utf-8
set term=screen-256color
let $TERM='screen-256color'

set cul           " highlight current line
set cuc           " highlight current column


"== pane spliting config =====================================================

set splitbelow
set splitright


"== pane spliting config =====================================================

" --- format the specified json. requires python
command FmtJson :%!python -m json.tool


"== key binding config =======================================================

"--- vim split pane navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

"--- tmux split pane navigations
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> {Left-mapping} :TmuxNavigateLeft<cr>
nnoremap <silent> {Down-Mapping} :TmuxNavigateDown<cr>
nnoremap <silent> {Up-Mapping} :TmuxNavigateUp<cr>
nnoremap <silent> {Right-Mapping} :TmuxNavigateRight<cr>
nnoremap <silent> {Previous-Mapping} :TmuxNavigatePrevious<cr>

"== nerdtree config ==========================================================

nmap <silent> <F5> :NERDTreeToggle<CR>
let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree

"# map <Leader>n <plug>NERDTreeTabsToggle<CR>
nmap <silent> <F6> :NERDTreeTabsToggle<CR>
let g:nerdtree_tabs_open_on_gui__startup=1
let g:nerdtree_tabs_open_on_console_startup=1

"== autocomplete config =======================================================

"--- close autocomplete tip when finished
let g:ycm_autoclose_preview_window_after_completion=1

"--- map <space-g> to navigate to declaration
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>


"== code folding config =======================================================

set foldmethod=indent
set foldlevel=99

let g:SimpylFold_docstring_preview=1

"--- use space bar to toggle folding
nnoremap <space> za


"== syntastic config ==========================================================

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_loc_list_height=5
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0


"== python config =============================================================

"--- enable python virtualenv support
py << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
  project_base_dir = os.environ['VIRTUAL_ENV']
  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
  execfile(activate_this, dict(__file__=activate_this))
EOF

"--- configure indentation : pep8
au BufNewFile,BufRead *.py
    \ set tabstop=4
    \ set softtabstop=4
    \ set shiftwidth=4
    \ set textwidth=79
    \ set expandtab
    \ set autoindent
    \ set fileformat=unix


"== web dev config ============================================================

"--- configure indentation
au BufNewFile,BufRead *.js, *.html, *.css
    \ set tabstop=2
    \ set softtabstop=2
    \ set shiftwidth=2
