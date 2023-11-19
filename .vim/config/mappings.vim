" Mapping settings

" Tab navigation
nnoremap <C-h> :tabprevious<CR>
nnoremap <C-j> :tabclose<CR>
nnoremap <C-k> :tabnew<CR>
nnoremap <C-l> :tabnext<CR>

" Clear search results
nnoremap <Leader>/ :call setreg("/", "", "v")<CR>
" Move cursor to begin/end of match
nnoremap <Leader>e //\e<CR>
" Display path of the file
nnoremap <Leader>p <C-G>
" Call format program for whole file
nnoremap <Leader>q gggqG2<C-O>
" Search and Replace local variable
nnoremap <Leader>r :let b:refactor = '\V\<<C-R><C-w>\>'<CR>[[V%:s/<C-R>=b:refactor<CR>//gcI<left><left><left><left>
" Search and Replace global variable
nnoremap <Leader>R :let b:refactor = '\V\<<C-R><C-w>\>'<CR>gg:%s/<C-R>=b:refactor<CR>//gcI<left><left><left><left>
" Search for extra whitespaces
nnoremap <Leader>w /\s\+$<CR>

" Comment/Uncomment operator
nnoremap <expr> <Leader>c CommentOperator()
nnoremap <expr> <Leader>cc CommentOperator() .. '_'
xnoremap <expr> <Leader>c CommentOperator()

" snipMate visual buffer copy operator
noremap <expr> <Leader>v SnipMateVisualCopy()
xnoremap <expr> <Leader>v SnipMateVisualCopy()
" snipMate visual buffer cut operator
noremap <expr> <Leader>x SnipMateVisualCut()
xmap <Leader>x <Plug>snipMateVisual
