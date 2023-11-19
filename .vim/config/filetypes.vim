" Filetype settings

" Filetype detection
filetype plugin indent on

" Default TeX syntax
let g:tex_flavor="latex"
" Default assembly syntax
let g:asmsyntax="nasm"

if !has("autocmd")
	finish
endif

augroup Filetypes
	autocmd!

	autocmd Filetype asm,nasm,c,cpp,cmake,rust,html,css,javascript,python,sh,vim
				\ syntax match ExtraWhiteSpace "\s\+$" containedin=ALL

	" C and C++
	autocmd Filetype c,cpp setlocal formatprg=clang-format
	" EDL (SGX) file detection
	autocmd BufNewFile,BufRead *.edl setlocal filetype=cpp
	" HTML, CSS and JavaScript
	autocmd FileType html,css,javascript setlocal shiftwidth=2 tabstop=2 expandtab
	" Python
	autocmd FileType python setlocal shiftwidth=4 tabstop=4 expandtab
	" Rust
	autocmd Filetype rust setlocal formatprg=rustfmt
	autocmd Filetype rust setlocal keywordprg=rusty-man
	autocmd FileType rust setlocal colorcolumn=80,120
	autocmd FileType rust nnoremap <Leader>q :RustFmt<CR>
	autocmd BufNewFile,BufRead *.lalrpop setlocal filetype=rust
augroup END
