set number
set relativenumber

" Cursor shape change workaround (+ mode change timeout):
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
set ttimeout		" time out for key codes
set ttimeoutlen=1	" wait up to 1ms after Esc for special key

" Tab auto indent:
filetype plugin indent on
set tabstop=4 " show existing tab with 4 spaces width
set shiftwidth=4 " when indenting with '>', use 4 spaces width
set expandtab " On pressing tab, insert 4 spaces

" Colorscheme:
let g:gruvbox_contrast_dark = "hard"
colorscheme gruvbox
set bg=dark

" Disable comments autopaste
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Auto open quickfix
augroup myvimrc
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l*    lwindow
augroup END

" Ctags
set tags=$HOME/ctags/tags

" Persistent undo
set undofile
set undodir=$HOME/.vim/undo
set undolevels=5000
set undoreload=10000
