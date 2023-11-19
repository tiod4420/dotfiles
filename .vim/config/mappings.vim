" Mapping settings

" Tab navigation
nnoremap <C-h> :tabprevious<CR>
nnoremap <C-j> :tabclose<CR>
nnoremap <C-k> :tabnew<CR>
nnoremap <C-l> :tabnext<CR>

" Comment/uncomment operator
nnoremap <expr> <Leader>c CommentOperator() . '_'
xnoremap <expr> <Leader>c CommentOperator()
noremap <expr> <Leader>C CommentOperator()

" vimgrep operator
nnoremap <expr> <Leader>g VimGrepOperator() . 'iw'
xnoremap <expr> <Leader>g VimGrepOperator()
noremap <expr> <Leader>G VimGrepOperator()

" snipMate visual buffer copy operator
nnoremap <expr> <Leader>v SnipMateVisualCopy() . 'iw'
xnoremap <expr> <Leader>v SnipMateVisualCopy()
noremap <expr> <Leader>V SnipMateVisualCopy()

" snipMate visual buffer cut operator
nnoremap <expr> <Leader>x SnipMateVisualCut() . 'iw'
xmap <Leader>x <Plug>snipMateVisual
noremap <expr> <Leader>X SnipMateVisualCut()

" Clear search results
nnoremap <Leader>/ :call setreg("/", "", "v")<CR>
" Format the whole file
nnoremap <Leader>q gggqG2<C-O>
" Search and replace local or global declarations
nnoremap <Leader>r :call RefactorDecl('[[', '][')<CR>
nnoremap <Leader>R :call RefactorDecl('gg', 'G')<CR>
" Search for trailing whitespaces
nnoremap <Leader>w /\s\+$<CR>
" Quickfix window navigation
nnoremap <Leader>[ :cprev<CR>
nnoremap <Leader>] :cnext<CR>
