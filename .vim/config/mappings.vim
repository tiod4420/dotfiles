" Mapping settings

" Tab navigation
nnoremap <C-h> :tabprevious<CR>
nnoremap <C-j> :tabclose<CR>
nnoremap <C-k> :tabnew<CR>
nnoremap <C-l> :tabnext<CR>

" Move tabs
nnoremap <Leader>[ :tabmove -1<CR>
nnoremap <Leader>] :tabmove +1<CR>

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
" Toggle paste mode
nnoremap <Leader>p :set paste!<CR>
" Format the whole file
nnoremap <Leader>q gggqG2<C-O>
" Search and replace local or global declarations
nnoremap <Leader>r :call RefactorDecl('[[', '][')<CR>
nnoremap <Leader>R :call RefactorDecl('gg', 'G')<CR>
" Search for todos in the file
nnoremap <Leader>t /TODO<CR>
" Search for trailing whitespaces
nnoremap <Leader>w /\s\+$<CR>
