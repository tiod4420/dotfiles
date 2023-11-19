" Global filetype settings

" Filetype detection
filetype plugin indent on

" Default extra whitespace highlight
let g:ews_flags="est"
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
" Loading order for snippets
packadd own-snippets
packadd vim-snippets

if has("autocmd")
	augroup Development
		autocmd!

		" sh
		autocmd Filetype sh call DevelopmentEnvironment("syntax", "est")
		" C and C++
		autocmd Filetype c,cpp call DevelopmentEnvironment("syntax", "est", "clang-format")
		" Assembly
		autocmd Filetype nasm call DevelopmentEnvironment("manual", "esi")
		" Python
		autocmd Filetype python call DevelopmentEnvironment("indent", "e")
		" Rust
		autocmd Filetype rust call DevelopmentEnvironment("syntax", "est", "rustfmt")
		" Other C-syntax languages
		autocmd Filetype java,kotlin,thrift call DevelopmentEnvironment("syntax", "est")
		" Objective-C and derivated
		autocmd Filetype objc,objcpp call DevelopmentEnvironment("syntax", "est", "clang-format")

		" Base64 file detection
		autocmd BufNewFile,BufRead *.b64,*.base64,*.pem.*.crt setlocal filetype=base64
	augroup END
endif
