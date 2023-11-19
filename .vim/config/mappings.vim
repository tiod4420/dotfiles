" Global shortcut mappings

" Redraw screen
nnoremap <Leader>r :redraw!<CR>

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
