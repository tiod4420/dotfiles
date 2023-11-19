" Global function definitions

" Function to clear the search buffer
function! ClearSearch()
	call setreg("/", "", "v")
endfunction

" Enable some development mode display
function! DevelopmentEnvironment(...)
	" Set auto indentation
	setlocal autoindent
	" Show extra white spaces
	syntax match ExtraWhiteSpace "\s\+$" containedin=ALL
endfunction

" Search for extra whitespaces
function! ExtraWhiteSpaceSearch()
	call feedkeys("/\s\+$n")
endfunction
