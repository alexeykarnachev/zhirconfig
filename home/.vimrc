syntax on
set number
set noswapfile
set hlsearch
set incsearch

execute pathogen#infect()

" Make SPACE be a leader key workaround
nnoremap <SPASE> <Nop>
map <SPACE> "\"
let mapleader=" "

" Colorscheme workaround
colorscheme gruvbox
set bg=dark

function! ToggleBackground()
    if (&background == "light")
      set background=dark 
    else
       set background=light 
    endif
endfunction

" Cursor shape change workaround (+ mode change timeout)
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
set ttimeout		" time out for key codes
set ttimeoutlen=1	" wait up to 1ms after Esc for special key

nnoremap <Leader>t :NERDTreeToggle<CR>
nnoremap <Leader><F1> :noh<CR>
nnoremap <silent> <Leader><F5> :call ToggleBackground()<cr>

" Jedi settings
let g:jedi#popup_on_dot = 0
let g:jedi#completions_command = "<C-Space>"
let g:jedi#usages_command = "<Leader>u"

filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

" Navigate between window split panes
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

" Add dockerfile syntax
autocmd BufNewFile,BufRead Dockerfile* set syntax=dockerfile

" Syntactic options
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_flake8_args = "--max-line-length=120"

