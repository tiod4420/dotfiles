" Global shortcut mappings

" Map leader
let mapleader="\\"

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
" Toogle extra whitespaces
nnoremap <Leader>ws :call ExtraWhiteSpaceSearchToggle()<CR>
" Toggle NERDTree (tabs)
nmap <Leader>n <plug>NERDTreeTabsToggle<CR>
" Toggle hex
nnoremap <Leader>x :call HexToggle()<CR>
" Toggle base64
nnoremap <Leader>b :call Base64Toggle()<CR>
" Formatting program
nmap <Leader>= gq

" User command to encode the buffer to hex
command -nargs=0 HexEnc :call HexEnc()
" User command to decode the buffer from hex
command -nargs=0 HexDec :call HexDec()
" User command to toggle from binary to hex
command -nargs=0 HexToggle :call HexToggle()
" User command to dump a file as C array
command -nargs=1 -complete=file_in_path BinaryDump :call BinaryDump(<f-args>)
" User command to encode the buffer to Base64
command -nargs=0 Base64Enc :call Base64Enc()
" User command to decode the buffer from Base64
command -nargs=0 Base64Dec :call Base64Dec()
" User command to toggle from Base64 to binary
command -nargs=0 Base64Toggle :call Base64Toggle()
