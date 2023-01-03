" Disable comments autopaste
autocmd BufNewFile,BufRead * setlocal formatoptions-=cro
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

set number
set relativenumber
set ruler

" Backspace behaviour
set backspace=indent,eol,start

" Cursor shape change workaround (+ mode change timeout)
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
set ttimeout		" time out for key codes
set ttimeoutlen=1	" wait up to 1ms after Esc for special key

" Tab auto indent
set autoindent
set cindent
set tabstop=4 " show existing tab with 4 spaces width
set shiftwidth=4 " when indenting with '>', use 4 spaces width
set expandtab " On pressing tab, insert 4 spaces

" Colorscheme
let g:gruvbox_contrast_dark = "hard"
colorscheme gruvbox
set bg=dark
syntax on

set tags=$HOME/ctags/tags

augroup myvimrc
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l*    lwindow
augroup END

" Persistent undo
set undofile
set undodir=$HOME/.vim/undo

set undolevels=5000
set undoreload=10000

" Highlight search matches
set is hls
nnoremap <silent> <Esc> :nohlsearch<Bar>:echo<CR>

" Files explorer settings
let g:netrw_bufsettings = 'noma nomod number relativenumber nobl nowrap ro'

" Show command line autocomplete options
set wildmenu

" Leader mappings
let mapleader = " "
nnoremap <Space> <NOP>
nnoremap <Leader>r :Rg<CR>
nnoremap <Leader>m :Marks<CR>
nnoremap <expr> <Leader>f ':FZF ' . input('') . '<CR>'

" Vim plug
call plug#begin()
    Plug 'junegunn/fzf.vim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
call plug#end()

" Disable comments autopaste
autocmd BufNewFile,BufRead * setlocal formatoptions-=cro
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
