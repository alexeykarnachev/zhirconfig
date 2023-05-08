lua require('plugins')

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

" Persistent undo
set undofile
set undodir=$HOME/.nvim/undo
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

" Colorscheme
set background=dark " or light if you want light mode
colorscheme gruvbox

" Nerdtree
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
" delays and poor user experience
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-n> coc#refresh()

" Vim plug
call plug#begin()
    Plug 'tikhomirov/vim-glsl'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'junegunn/fzf.vim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'timonv/vim-cargo'
    Plug 'preservim/nerdtree'
call plug#end()

