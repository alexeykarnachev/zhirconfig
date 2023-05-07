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
nnoremap <expr> <Leader>r ':Rg ' . '<CR>'
nnoremap <expr> <Leader>f ':FZF ' . input('Search in: ' . getcwd() . '/') . '<CR>'
nnoremap <Leader>m :Marks<CR>
nnoremap <Leader>g :grep -r <C-R><C-W> .<CR>

" Autocompletion and gotos
set completeopt-=preview
let g:ycm_auto_hover=''
let g:ycm_goto_buffer_command = 'same-buffer'
nmap <leader>h <plug>(YCMHover)
nnoremap <leader>d :YcmCompleter GoTo<CR>
" Don't use return key for the newline insertion when the selection list is active
inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"

" Vim plug
call plug#begin()
    Plug 'junegunn/fzf.vim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'ziglang/zig.vim'
    Plug 'habamax/vim-godot'
    Plug 'timonv/vim-cargo'
    Plug 'jdonaldson/vaxe'
    Plug 'Valloric/YouCompleteMe'
    let g:zig_fmt_autosave = 0
call plug#end()

" Open manpage in a vsplit window
function! Man()
    let keyword = expand('<cword>')
    let output = system('man ' . keyword . ' | col -b')
    rightbelow vsplit new
    setlocal buftype=nofile bufhidden=hide noswapfile
    call setline(1, split(output, "\n"))
endfunction
nnoremap K :call Man()<CR>

" Godot
func! GodotSettings() abort
    nnoremap <buffer> <F4> :GodotRunLast<CR>
    nnoremap <buffer> <F5> :GodotRun<CR>
    nnoremap <buffer> <F6> :GodotRunCurrent<CR>
    nnoremap <buffer> <F7> :GodotRunFZF<CR>
endfunc
augroup godot | au!
    au FileType gdscript call GodotSettings()
augroup end

" Disable comments autopaste
autocmd BufNewFile,BufRead * setlocal formatoptions-=cro
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
