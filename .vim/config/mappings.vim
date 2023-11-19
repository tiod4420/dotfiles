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
" Toogle extra whitespaces
nnoremap <Leader>w :call ExtraWhiteSpaceSearch()<CR>
" Display all snippets available
nmap <Leader>m i<Plug>snipMateShow

" Search and Replace local variable
nnoremap <Leader>o gd[{V%:s///gcI<left><left><left><left>
" Search and Replace global variable
nnoremap <Leader>O gD:%s///gcI<left><left><left><left>
