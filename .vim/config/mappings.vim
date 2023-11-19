" Mapping settings

" Tab navigation
nnoremap <C-h> :tabprevious<CR>
nnoremap <C-j> :tabclose<CR>
nnoremap <C-k> :tabnew<CR>
nnoremap <C-l> :tabnext<CR>

" Search and replace local or global declaration
nnoremap <Leader>r :call RefactorDecl('[[', '][')<CR>
nnoremap <Leader>R :call RefactorDecl('gg', 'G')<CR>

" Comment/uncomment operator
nnoremap <expr> <Leader>c CommentOperator()
nnoremap <expr> <Leader>cc CommentOperator() .. '_'
xnoremap <expr> <Leader>c CommentOperator()

" snipMate visual buffer copy operator
noremap <expr> <Leader>v SnipMateVisualCopy()
noremap <expr> <Leader>vv SnipMateVisualCopy() .. 'iw'
xnoremap <expr> <Leader>v SnipMateVisualCopy()

" snipMate visual buffer cut operator
noremap <expr> <Leader>x SnipMateVisualCut()
noremap <expr> <Leader>xx SnipMateVisualCut() .. 'iw'
xmap <Leader>x <Plug>snipMateVisual

" Clear search results
nnoremap <Leader>/ :call setreg("/", "", "v")<CR>
" Move cursor to begin/end of match
nnoremap <Leader>e //\e<CR>
" Display path of the file
nnoremap <Leader>p <C-G>
" Call format program for whole file
nnoremap <Leader>q gggqG2<C-O>
" Search for extra whitespaces
nnoremap <Leader>w /\s\+$<CR>
