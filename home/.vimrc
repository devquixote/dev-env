""""""""""""""""""""""""""""""""""""""
" Set up Vundler and various plugins "
""""""""""""""""""""""""""""""""""""""
set nocompatible              " be iMproved, required
filetype off                  " required
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

" Install individual plugins using vundler
Plugin 'tomtom/tlib_vim'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'garbas/vim-snipmate'
Plugin 'honza/vim-snippets'
Plugin 'vim-syntastic/syntastic.git'
Plugin 'scrooloose/nerdtree'

call vundle#end()

"""""""""""""""""""""
" Easier Buffer Nav "
"""""""""""""""""""""
map <C-k> <C-W><Up>
map <C-j> <C-W><Down>
map <C-h> <C-W><Left>
map <C-l> <C-W><Right>

""""""""""""""""""""""""""""""""""""""
" Setup colors & syntax highlighting "
""""""""""""""""""""""""""""""""""""""
syntax on
set number
color jellybeans
set t_Co=256

""""""""""""""
" Setup tabs "
""""""""""""""
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set nowrap

"""""""""""""""""""
" Setup syntastic "
"""""""""""""""""""
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=1
let g:syntastic_check_on_open=0
let g:syntastic_check_on_wq=0
let g:syntastic_sh_shellcheck_args = "-x"

highlight Fixit ctermbg=darkred guibg=darkred
match Fixit /\%81v.\+/
2match Fixit /\s\+$/

""""""""""""""
" Map F-keys "
""""""""""""""
map <F1> :NERDTreeToggle<CR>
nmap <F11> :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
nmap <F12> :help myprefs<CR>

"""""""""""""""""""""""""""""""""""""""""""
" Send onsave to dev tmux session for TDD "
"""""""""""""""""""""""""""""""""""""""""""
autocmd BufWritePost * call system('tmux send-keys -t dev:work.1 "onsave" Enter')

filetype plugin indent on

"
let mapleader = "\<Space>"
set guifont=Monaco:h13
set hlsearch
set showmatch
set mouse=a
set nobackup
set nowb
set noswapfile
set modeline
set modelines=5
