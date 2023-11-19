let s:gitMarkerStart = '^<<<<<<< .*$'
let s:gitMarkerThird = '^||||||| .*$'
let s:gitMarkerSeparator = '^=======$'
let s:gitMarkerEnd = '^>>>>>>> .*$'

" Enable Git conflicts features
function! git_conflict#EnableSyntax()
	call <SID>SyntaxHighlight()

	if exists("g:loaded_matchit")
		call <SID>Matchit()
	endif
endfunction

" Jumps to next conflict
function! git_conflict#SearchNext(...)
	let l:flags = (a:0 == 1) ? a:1 : ""

	let l:pos = search(s:gitMarkerStart, 'n' . l:flags)
	if 0 != l:pos
		" Needed to add position to jump list
		execute 'normal! ' . l:pos . 'gg'
	endif
endfunction

" Highlight markers
function! s:SyntaxHighlight()
	" Conflicts syntax
	execute "syntax match gitConflictStart '" . s:gitMarkerStart . "'"
	execute "syntax match gitConflictThird '" . s:gitMarkerThird . "'"
	execute "syntax match gitConflictSeparator '" . s:gitMarkerSeparator . "'"
	execute "syntax match gitConflictEnd '" . s:gitMarkerEnd . "'"

	" Conflict highlight
	if hlexists("GitGutterAdd")
		highlight link gitConflictStart GitGutterAdd
		highlight link gitConflictThird GitGutterChange
		highlight link gitConflictSeparator GitGutterDelete
		highlight link gitConflictEnd GitGutterDelete
	else
		highlight gitConflictStart ctermfg=DarkGreen
		highlight gitConflictThird ctermfg=DarkBlue
		highlight gitConflictSeparator ctermfg=DarkRed
		highlight gitConflictEnd ctermfg=DarkRed
	endif
endfunction

" Matchit patterns
function! s:Matchit()
	let l:match_words = join([ s:gitMarkerStart, s:gitMarkerThird, s:gitMarkerSeparator, s:gitMarkerEnd ], ':')

	if get(b:, "match_words", "") != ""
		let b:match_words = join([ b:match_words, l:match_words ], ',')
	else
		let b:match_words = l:match_words
	endif
endfunction
