" Global shortcut mappings

" Redraw screen
nnoremap <Leader>r :redraw!<CR>

" Tab navigation
nnoremap <C-h> :tabprevious<CR>
nnoremap <C-j> :tabclose<CR>
nnoremap <C-k> :tabnew<CR>
nnoremap <C-l> :tabnext<CR>

" Split window navigation
nnoremap <Leader>v <C-w>v
nnoremap <Leader>s <C-w>s
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>h <C-w>h
nnoremap <Leader>l <C-w>l
nnoremap <Leader>= <C-w>=

" Split window resize
nnoremap <Up> <C-w>-
nnoremap <Down> <C-w>+
nnoremap <Left> <C-w><
nnoremap <Right> <C-w>>

" Clear search results
nnoremap <Leader>/ :call ClearSearch()<CR>
" Search with cursor on end of word
nnoremap <Leader>e //e<CR>
" Toogle extra whitespaces
nnoremap <Leader>w :call ExtraWhiteSpaceSearch()<CR>
