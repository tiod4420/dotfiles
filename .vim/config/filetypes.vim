" Filetype settings

" Filetype detection
filetype plugin indent on

" Default assembly syntax
let g:asmsyntax="nasm"
" Default TeX syntax
let g:tex_flavor="latex"

if !has("autocmd")
	finish
endif

augroup Filetypes
	autocmd!

	" Extra whitespace
	autocmd FileType c,cpp,cmake,rust,sh syntax match ExtraWhiteSpace "\s\+$" containedin=ALL
	autocmd FileType asm,nasm,java,python,vim syntax match ExtraWhiteSpace "\s\+$" containedin=ALL
	autocmd FileType html,css,javascript syntax match ExtraWhiteSpace "\s\+$" containedin=ALL

	" Comment string
	autocmd FileType c,cpp,java,javascript,rust let b:comment_str = '//'
	autocmd FileType cmake,python,sh let b:comment_str = '#'
	autocmd FileType asm,nasm let b:comment_str = ';'
	autocmd FileType vim let b:comment_str = '"'

	" C and C++ specific rules
	autocmd FileType c,cpp setlocal formatprg=clang-format
	autocmd BufNewFile,BufRead *.edl setlocal filetype=cpp
	" HTML, CSS and JavaScript specific rules
	autocmd FileType html,css,javascript setlocal shiftwidth=2 tabstop=2 expandtab
	" Python specific rules
	autocmd FileType python setlocal shiftwidth=4 tabstop=4 expandtab
	" Rust specific rules
	autocmd FileType rust setlocal colorcolumn=80,120 formatprg=rustfmt keywordprg=rusty-man
	autocmd FileType rust nnoremap <Leader>q :RustFmt<CR>
	autocmd BufNewFile,BufRead *.lalrpop setlocal filetype=rust
augroup END
