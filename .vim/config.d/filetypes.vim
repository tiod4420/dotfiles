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
	augroup Programming
		autocmd!

		" sh
		autocmd Filetype sh call EnableProgrammingMode("syntax", "est")
		" C and C++
		autocmd Filetype c,cpp call EnableProgrammingMode("syntax", "est")
		" Assembly
		autocmd Filetype nasm call EnableProgrammingMode("manual", "esi")
		" Python
		autocmd Filetype python call EnableProgrammingMode("indent", "e", 100)
		" Other C-syntax languages
		autocmd Filetype java,rust,thrift call EnableProgrammingMode("syntax", "est", 100)
		" Objective-C and derivated
		autocmd Filetype objc,objcpp call EnableProgrammingMode("syntax", "est", 100)

		" Base64 file detection
		autocmd BufNewFile,BufRead *.b64,*.base64,*.pem.*.crt setlocal filetype=base64
	augroup END
endif
