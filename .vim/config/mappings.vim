" Global shortcut mappings

" Tab navigation
nnoremap <C-h> :tabprevious<CR>
nnoremap <C-j> :tabclose<CR>
nnoremap <C-k> :tabnew<CR>
nnoremap <C-l> :tabnext<CR>

" Clear search results
nnoremap <Leader>/ :call ClearSearch()<CR>
" Search with cursor on end of word
nnoremap <Leader>e //e<CR>
" Display path of the file
nnoremap <Leader>p <C-G>
" Call format program for whole file
nnoremap <Leader>q gggqG
" Search and Replace local variable
nnoremap <Leader>r :let refactor = '\V\<<C-R><C-w>\>'<CR>[[V%:s/<C-R>=refactor<CR>//gcI<left><left><left><left>
" Search and Replace global variable
nnoremap <Leader>R :let refactor = '\V\<<C-R><C-w>\>'<CR>gg:%s/<C-R>=refactor<CR>//gcI<left><left><left><left>
" Display all snippets available
nmap <Leader>s i<Plug>snipMateShow
" Toogle extra whitespaces
nnoremap <Leader>w :call ExtraWhiteSpaceSearch()<CR>
