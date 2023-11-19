" Global function definitions

" Function to clear the search buffer
function! ClearSearch()
	call setreg("/", "", "v")
endfunction

" Make a search pattern for what to highlight (one or more characters):
" 	e  whitespace at end of line
" 	i  spaces used for indenting
" 	s  spaces before a tab
" 	t  tabs not at start of line
function! ExtraWhiteSpaceMakePattern(flags)
	let result = ""
	let patterns = { 'e' : '\s\+$', 'i' : '^\t*\zs \+',
				\ 's' : ' \+\ze\t', 't' : '[^\t]\zs\t\+' }
	let default = ''
	let list = []

	for c in split(a:flags, '\zs')
		let res = get(patterns, c, default)
		call add(list, res)
	endfor

	if len(list) > 0
		let result = join(list, '\|')
	endif

	return result 
endfunction

" Get Extra Whitespaces flags for the current buffer
function! ExtraWhiteSpaceGetFlags(...)
	if exists("b:ews_flags")
		return b:ews_flags
	elseif exists("g:ews_flags")
		return g:ews_flags
	else
		if a:0 != 0
			return a:1
		else
			return ""
endfunction

" Toggle function for display of extra whitespaces
function! ExtraWhiteSpaceShowToggle()
	if ! exists("b:ews_show")
		let b:ews_show = 0
	endif

	if ! b:ews_show
		" Create syntax pattern
		let flags = ExtraWhiteSpaceGetFlags()
		let regex = ExtraWhiteSpaceMakePattern(flags)
		" Set syntax
		execute 'syntax match ExtraWhiteSpace "' . regex . '" containedin=ALL'
	else
		" Remove syntax
		syntax clear ExtraWhiteSpace
	endif

	let b:ews_show = ! b:ews_show
endfunction

" Toggle function for search of extra whitespaces
function! ExtraWhiteSpaceSearchToggle()
	if ! exists("b:ews_search")
		let b:ews_search = 0
	endif

	" Create search pattern
	let flags = ExtraWhiteSpaceGetFlags()
	let regex = ExtraWhiteSpaceMakePattern(flags)

	" Check if a new search has been done without toggling off
	if b:ews_search && getreg("/") != regex
		let b:ews_search = 0
	endif

	if ! b:ews_search
		" Save current search
		let b:ews_reg = getreg("/")
		let b:ews_regtype = getregtype("/")

		" Set search
		call setreg("/", regex, "v")
	else
		if exists("b:ews_reg") | let l:ews_reg = b:ews_reg | else | let l:ews_reg = "" | endif
		if exists("b:ews_regtype") | let l:ews_regtype = b:ews_regtype | else | let l:ews_regtype = "v" | endif

		" Restore search
		call setreg("/", l:ews_reg, l:ews_reg)
	endif

	let b:ews_search = ! b:ews_search
endfunction

" Encode the buffer to hex
function! HexEnc()
	if 1 == executable("xxd")
		" Save options
		let b:hex_binary = &binary
		let b:hex_filetype = &filetype

		" Set options
		setlocal binary
		let &filetype ="xxd"

		" Set toggle status
		let b:hex_toggle = 1

		" Encode to hex
		%! xxd -g1
	endif
endfunction

" Decode the buffer from hex
function! HexDec()
	if 1 == executable("xxd")
		" Restore options
		if exists("b:hex_binary") | let &binary = b:hex_binary | endif
		if exists("b:hex_filetype") | let &filetype = b:hex_filetype | endif

		" Set toggle status
		let b:hex_toggle = 0

		" Decode from hex
		%! xxd -r
	endif
endfunction

" Toggle from binary to hex
function! HexToggle()
	if ! exists("b:hex_toggle")
		let b:hex_toggle = 0
	endif

	if ! b:hex_toggle
		call HexEnc()
	else
		call HexDec()
	endif
endfunction

" Dump a file as C array
function! BinaryDump(file)
	if 1 == executable("xxd") && filereadable(expand(a:file))
		execute ":r! xxd -i " . expand(a:file)
	endif
endfunction

" Encode the buffer to Base64
function! Base64Enc()
	if 1 == executable("openssl")
		" Save options
		let b:b64_binary = &binary
		let b:b64_filetype = &filetype

		" Set options
		setlocal nobinary
		let &filetype="base64"

		" Set toggle state
		let b:b64_toggle = 1

		" Encode to Base64
		%! openssl base64
	endif
endfunction

" Decode the buffer from Base64
function! Base64Dec()
	if 1 == executable("openssl")
		" Restore options
		if exists("b:b64_binary") | let &binary = b:b64_binary | endif
		if exists("b:b64_filetype") | let &filetype = b:b64_filetype | endif

		" Set toggle state
		let b:b64_toggle = 0

		" Decode from Base64
		%! openssl base64 -d
	endif
endfunction

" Toggle from Base64 to binary
function! Base64Toggle()
	if ! exists("b:b64_toggle")
		let b:b64_toggle = 0
	endif

	if ! b:b64_toggle
		call Base64Enc()
	else
		call Base64Dec()
	endif
endfunction

" Enable some development mode display
function! DevelopmentEnvironment(...)
	" Set default value
	let l:fold_method = "manual"
	let l:ews_flags = ExtraWhiteSpaceGetFlags("est")
	let l:num_column = 81
	let l:format_program = ""
	" Set parameters if exists
	if a:0 > 0 | let l:fold_method = a:1 | endif
	if a:0 > 1 | let l:ews_flags = a:2 | endif
	if a:0 > 2 | let l:format_program = a:3 | endif

	" Set auto indentation
	setlocal autoindent
	" Set column space
	execute "setlocal colorcolumn=" . l:num_column
	" Show extra white spaces
	let b:ews_flags = l:ews_flags
	call ExtraWhiteSpaceShowToggle()
	" Set folding method
	execute "setlocal foldmethod=" . l:fold_method
	setlocal nofoldenable
	" Set formatting program if executable
	if 1 == executable(expand(l:format_program))
		execute "setlocal formatprg=" . expand(l:format_program)
	endif
endfunction