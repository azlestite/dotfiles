set encoding=utf-8
scriptencoding utf-8

filetype off

source ~/.config/nvim/keymap.rc.vim

" ------------------------------
" General
" ------------------------------
" reset augroup
augroup MyAutoCmd
  autocmd!
augroup END

let g:python_host_prog = expand('~/.anyenv/envs/pyenv/versions/2.7.17/bin/python')
let g:python3_host_prog = expand('~/.anyenv/envs/pyenv/versions/3.8.1/bin/python')

set fileencoding=utf-8
set fileencodings=utf-8,iso-2022-jp,euc-jp,cp932
set fileformats=unix,dos,mac

set nobackup
set nowritebackup
set noswapfile
set noundofile
set autoread
set hidden
set confirm

set cmdheight=2
set showcmd
set wildmenu wildmode=list:longest,full
set history=1000

set ttimeoutlen=10

" ------------------------------
" Display
" ------------------------------
syntax enable
set t_Co=256

if has('termguicolors')
  set termguicolors
endif

let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

set title
set number
set cursorline
set scrolloff=5
set ruler
set colorcolumn=80
set list
set listchars=tab:»-,trail:-,nbsp:%,eol:↲,extends:»,precedes:«
set display=lastline,uhex
set wrap

function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=reverse ctermfg=DarkMagenta gui=reverse guifg=DarkMagenta
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    autocmd ColorScheme * call ZenkakuSpace()
    autocmd VimEnter,WinEnter,BufRead * match ZenkakuSpace /　/
  augroup END
  call ZenkakuSpace()
endif

set laststatus=2
set showtabline=2
set noshowmode
"set ambiwidth=double

" ------------------------------
" Edit
" ------------------------------
set backspace=indent,eol,start
set virtualedit=onemore,block
set whichwrap=b,s,h,l,<,>,[,],~
set showmatch
set matchtime=1
set matchpairs+=<:>
set visualbell t_vb=
set noerrorbells

set autoindent
set smartindent
set expandtab
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2

augroup FileTypeIndent
  autocmd!
  autocmd BufNewFile,BufRead *.py setlocal tabstop=4 softtabstop=4 shiftwidth=4
augroup END

set clipboard+=unnamedplus
set formatoptions+=mM

augroup AutoCommentOff
    autocmd!
    autocmd BufEnter * setlocal formatoptions-=r
    autocmd BufEnter * setlocal formatoptions-=o
augroup END

function! s:remove_dust()
  let cursor = getpos('.')

  %s/\s\+$//ge
  while getline('$') == ''
    $delete _
  endwhile

  call setpos('.', cursor)
  unlet cursor
endfunction

function! s:mkdir(dir, force)
  if !isdirectory(a:dir) &&
    \ (a:force ||
      \ input(printf('"%s" not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
    call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
  endif
endfunction

augroup MyAutoCmd
  autocmd BufWritePre * call s:remove_dust()
  autocmd BufWritePre * call s:mkdir(expand('<afile>:p:h'), v:cmdbang)
augroup END

" ------------------------------
" Search
" ------------------------------
set ignorecase
set smartcase
set incsearch
set hlsearch
set wrapscan
set keywordprg=:help

" ------------------------------
" Plugin
" ------------------------------
" automatically install dein and plugins {{{

let s:cache_home = empty($XDG_CACHE_HOME) ? expand('~/.cache') : $XDG_CACHE_HOME
let s:dein_dir = s:cache_home . '/nvim/dein'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
  endif

  execute 'set runtimepath^=' . s:dein_repo_dir
endif

let s:toml = fnamemodify(expand('<sfile>'), ':h') . '/dein.toml'
let s:lazy_toml = fnamemodify(expand('<sfile>'), ':h') . '/dein_lazy.toml'

" dein setting
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  call dein#load_toml(s:toml, {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

" install not installed plugins on startup
if has('vim_starting') && dein#check_install()
  call dein#install()
endif
" }}}

filetype plugin indent on

filetype on
