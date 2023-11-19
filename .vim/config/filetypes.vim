" Global filetype settings

" Filetype detection
filetype plugin indent on

" Default TeX syntax
let g:tex_flavor="latex"
" Default assembly syntax
let g:asmsyntax="nasm"

" Clear snipMate options
let g:snipMate = {}
" Set snipMate parser version
let g:snipMate.snippet_version = 1
" Overriding snippets is enabled
let g:snipMate.override = 1
let g:snipMate.always_choose_first = 1
" Loading order for snippets
packadd own-snippets
packadd vim-snippets

if has("autocmd")
	augroup Development
		autocmd!

		" C and C++
		autocmd Filetype c,cpp call DevelopmentEnvironment()
		autocmd Filetype c,cpp setlocal formatprg=clang-format
		" CMake
		autocmd Filetype cmake call DevelopmentEnvironment()
		" Assembly
		autocmd Filetype asm,nasm call DevelopmentEnvironment()
		" Rust
		autocmd Filetype rust call DevelopmentEnvironment()
		autocmd Filetype rust setlocal formatprg=rustfmt
		autocmd Filetype rust setlocal keywordprg=rusty-man
		autocmd FileType rust nnoremap <Leader>q :RustFmt<CR>
		autocmd FileType rust setlocal colorcolumn=80,120
		" sh
		autocmd Filetype sh call DevelopmentEnvironment()
		" Python
		autocmd Filetype python call DevelopmentEnvironment()
		autocmd FileType python setlocal shiftwidth=4 tabstop=4 expandtab
		" HTML, CSS and JavaScript
		autocmd Filetype html,css,javascript call DevelopmentEnvironment()
		autocmd FileType html,css,javascript setlocal shiftwidth=2 tabstop=2 expandtab
		" VIM script
		autocmd Filetype vim call DevelopmentEnvironment()
		" Base64 file detection
		autocmd BufNewFile,BufRead *.b64,*.base64,*.pem.*.crt setlocal filetype=base64
		" EDL (SGX) file detection
		autocmd BufNewFile,BufRead *.edl setlocal filetype=cpp
	augroup END
endif
