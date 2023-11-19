" Function settings

" Clear search buffer
function! SearchClear()
	call setreg("/", "", "v")
endfunction

" Move cursor to begin/end of match
function! SearchEndMatch()
	call feedkeys("//e\<CR>")
endfunction

" Search for extra whitespaces
function! SearchExtraWhiteSpace()
	call feedkeys("/" . '\s\+$' . "\<CR>")
endfunction

" Copy selection into SnipMate register
function! SnipMateVisualCopy() abort
	let a_save = @a
	try
		normal! gv"ay
		let b:snipmate_visual = @a
	finally
		let @a = a_save
	endtry
endfunction
