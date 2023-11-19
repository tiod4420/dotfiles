" Mapping settings

" Tab navigation
nnoremap <C-h> :tabprevious<CR>
nnoremap <C-j> :tabclose<CR>
nnoremap <C-k> :tabnew<CR>
nnoremap <C-l> :tabnext<CR>

" Clear search results
nnoremap <Leader>/ :call SearchClear()<CR>
" Toggle move to end of match
nnoremap <Leader>e :call SearchEndMatch()<CR>
" Display path of the file
nnoremap <Leader>p <C-G>
" Call format program for whole file
nnoremap <Leader>q gggqG2<C-O>
" Search and Replace local variable
nnoremap <Leader>r :let b:refactor = '\V\<<C-R><C-w>\>'<CR>[[V%:s/<C-R>=b:refactor<CR>//gcI<left><left><left><left>
" Search and Replace global variable
nnoremap <Leader>R :let b:refactor = '\V\<<C-R><C-w>\>'<CR>gg:%s/<C-R>=b:refactor<CR>//gcI<left><left><left><left>
" Copy visual selection to snipMate buffer
xnoremap <Leader>v :<C-U>call SnipMateVisualCopy()<CR>
" Search for extra whitespaces
nnoremap <Leader>w :call SearchExtraWhiteSpace()<CR>
" Cut visual selection to snipMate buffer
xmap <Leader>x <Plug>snipMateVisual
