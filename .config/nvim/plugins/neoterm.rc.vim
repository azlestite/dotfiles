" prefix
nnoremap [neoterm] <Nop>
nmap <Space>t [neoterm]

" change to normal mode
tnoremap <silent> <Esc> <C-\><C-n>
" Useful maps
" hide/close terminal
nnoremap <silent> [neoterm]h :call neoterm#close()<CR>
" clear terminal
nnoremap <silent> [neoterm]c :call neoterm#clear()<CR>
" kills the current job (send a <c-c>)
nnoremap <silent> [neoterm]k :call neoterm#kill()<CR>

nnoremap <silent> [neoterm]o :Ttoggle<CR>

" REPL
let g:neoterm_repl_python = get(g:, 'python3_host_prog', 'python3')
nnoremap <silent> [neoterm]t :TREPLSendFile<CR>
nnoremap <silent> [neoterm]l :TREPLSendLine<CR>
vnoremap <silent> [neoterm]t :TREPLSendSelection<CR>
