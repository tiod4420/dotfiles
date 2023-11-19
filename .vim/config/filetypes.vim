" Filetype settings

" Filetype detection
filetype plugin indent on

" Default assembly syntax
let g:asmsyntax="nasm"
" Header (.h) files are C files
let g:c_syntax_for_h=1
" Default TeX syntax
let g:tex_flavor="latex"
" snipMate options
let g:snipMate = { 'snippet_version': 1 }

if !has("autocmd")
	finish
endif

function s:AddDevelopment(language, comment_str, ...)
	let l:auft = "autocmd FileType " . a:language . " "
	let l:options = (a:0 == 1) ? a:1 : {}

	augroup Development

	execute l:auft . "syntax match ExtraWhiteSpace \"" . '\s\+$' . "\" containedin=ALL"
	execute l:auft . "let b:comment_str = '" . a:comment_str . "'"

	" Additional file extensions
	if has_key(l:options, "files")
		execute "autocmd BufNewFile,BufRead " . l:options["files"] . " setlocal filetype=" . a:language
	endif

	if has_key(l:options, "colorcolumn")
		execute l:auft . "setlocal colorcolumn=" . l:options["colorcolumn"]
	endif

	if has_key(l:options, "expandtab")
		execute l:auft . "setlocal expandtab"
		execute l:auft . "setlocal shiftwidth=" . l:options["expandtab"]["shiftwidth"]
		execute l:auft . "setlocal tabstop=" . l:options["expandtab"]["tabstop"]
	endif

	if has_key(l:options, "formatprg")
		execute l:auft . "setlocal formatprg=" . l:options["formatprg"]
	endif

	if has_key(l:options, "keywordprg")
		execute l:auft . "setlocal keywordprg=" . l:options["keywordprg"]
	endif

	if has_key(l:options, "vimgrep_ft")
		if len(l:options["vimgrep_ft"])
			let l:vimgrep_ft = join(map(l:options["vimgrep_ft"], { _, val -> "**/*." . v:val }), " ")
			execute l:auft . "let b:vimgrep_ft=\"" . l:vimgrep_ft . "\""
		endif
	endif

	" Additional command
	if has_key(l:options, "extra")
		execute l:auft . l:options["extra"]
	endif

	augroup end
endfunction

" Flush existing rules
augroup Development
	autocmd!
augroup end

" Add rules
call <SID>AddDevelopment("c", '//', {
			\ "formatprg": "clang-format",
			\ "vimgrep_ft": [ "c", "h" ]
			\ })

call <SID>AddDevelopment("cpp", '//', {
			\ "files": "*.edl",
			\ "formatprg": "clang-format",
			\ "vimgrep_ft": [ "cpp", "h", "cxx", "hpp", "c" ]
			\ })

call <SID>AddDevelopment("rust", '//', {
			\ "files": "*.lalrpop",
			\ "colorcolumn":"80,120",
			\ "formatprg": "rustfmt",
			\ "extra": "nnoremap <buffer> <Leader>q :RustFmt<CR>",
			\ })

call <SID>AddDevelopment("python", '#', {
			\ "files": "*.sage",
			\ "expandtab": { "shiftwidth": 4, "tabstop": 4 },
			\ "keywordprg": "pydoc",
			\ })

call <SID>AddDevelopment("html,css,javascript", '//', {
			\ "expandtab": { "shiftwidth": 2, "tabstop": 2 },
			\ })

call <SID>AddDevelopment("java,kotlin", '//', {
			\ "expandtab": { "shiftwidth": 4, "tabstop": 4 },
			\ })

call <SID>AddDevelopment("groovy", '//', {
			\ "files": "Jenkinsfile",
			\ "expandtab": { "shiftwidth": 4, "tabstop": 4 },
			\ })

call <SID>AddDevelopment("asm,nasm", ';')
call <SID>AddDevelopment("sh,bash", '#')
call <SID>AddDevelopment("vim", '"')
call <SID>AddDevelopment("cmake,tmux,toml", '#')
