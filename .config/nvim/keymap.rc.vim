let mapleader = "\<Space>"

nnoremap <Leader>w :<C-u>w<CR>
nnoremap <Leader>q :<C-u>q<CR>

inoremap <silent> jj <Esc>
inoremap <silent> っｊ <Esc>

" motion
nnoremap j gj
nnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk

nnoremap gj j
nnoremap gk k

nnoremap <Leader>h ^
nnoremap <Leader>l $l

nnoremap <Tab> %
vnoremap <Tab> %

" window
nnoremap <Leader><Tab> <C-w>w

" buffer
nnoremap <Leader>bp :<C-u>bp<CR>
nnoremap <Leader>bn :<C-u>bn<CR>
nnoremap <Leader>bb :<C-u>b#<CR>
nnoremap <leader>bd :<C-u>bd<CR>

" search
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz
nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch<CR>

" vimrc
nnoremap ,ev :tabe $MYVIMRC<CR>
nnoremap <Leader>s :<C-u>source $MYVIMRC<CR>

nnoremap Y y$

" tag jump
nnoremap <C-]> g<C-]>

" tig
nnoremap ,gg :<C-u>tabnew<CR>:terminal tig<CR>i
