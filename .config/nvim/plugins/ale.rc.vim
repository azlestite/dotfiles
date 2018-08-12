let g:ale_lint_on_enter = 0
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1

nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

function! s:ale_list()
  let g:ale_open_list = 1
  call ale#Queue(0, 'lint_file')
endfunction

command! ALEList call s:ale_list()
nnoremap ,l  :ALEList<CR>
autocmd MyAutoCmd FileType qf
  \ nnoremap <silent><buffer> q :let g:ale_open_list = 0<CR>:q!<CR>
