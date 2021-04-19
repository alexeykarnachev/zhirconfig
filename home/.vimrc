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

" Customize status bar
" Show full file path
set statusline+=%F

" Colorscheme workaround
let g:gruvbox_contrast_dark = "medium"
let g:gruvbox_contrast_light = "medium"
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

" Key mappings
nnoremap <Leader>t :NERDTreeToggle<CR>
nnoremap <Leader><F1> :noh<CR>
nnoremap <silent> <Leader><F5> :call ToggleBackground()<cr>

map <Leader><F8> <ESC>:call SyntasticToggle()<CR>
function! SyntasticToggle()
  let g:wi = getloclist(2, {'winid' : 1})
  if g:wi != {}
    lclose
  else
    Errors
  endif
endfunction

map <c-x> <Nop>
map <c-a> <Nop>

" Jedi settings
let g:jedi#popup_on_dot = 0
let g:jedi#completions_command = "<C-Space>"
let g:jedi#usages_command = "<Leader>u"
let g:jedi#show_call_signatures = "0"
autocmd FileType python setlocal completeopt-=preview

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
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_python_flake8_args = "--max-line-length=120 --ignore=E111,E501,E302,E225,E303,E722,W291,W293"

" Add comments by # key in V-mode
vnoremap <silent> # :s/^/#/<cr>:noh<cr>
vnoremap <silent> -# :s/^#//<cr>:noh<cr>

