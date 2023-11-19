" Function definitions

" Save clipboard, selection, unnamed register and visual marks
function s:SaveEnv()
	let l:dic = {
		\ "clipboard": &clipboard,
		\ "selection": &selection,
		\ "unnamed_register": { "value": getreg('"', 1, 1), "type": getregtype('"')},
		\ "visual_marks": { "start": getpos("'<'"), "end": getpos("'>") },
	\ }

	return l:dic
endfunction

" Restore clipboard, selection, unnamed register and visual marks
function s:RestoreEnv(dic)
	let &clipboard = a:dic["clipboard"]
	let &selection = a:dic["selection"]
	call setreg('"', a:dic["unnamed_register"]["value"], a:dic["unnamed_register"]["type"])
	call setpos("'<", a:dic["visual_marks"]["start"])
	call setpos("'>", a:dic["visual_marks"]["end"])
endfunction

" Search for word inside file or directory
function VimGrepOperator(...)
	if a:0 == 0
		set opfunc=VimGrepOperator
		return 'g@'
	elseif a:1 == "block"
		return
	else
		let l:type = a:1
	endif

	let l:saved = <SID>SaveEnv()
	try
		set clipboard= selection=inclusive

		if l:type == "char"
			silent execute 'noautocmd keepjumps normal! `[v`]y'
			let l:pattern = [ @" ]
			" Search exact keyword if possible
			let l:marker = (l:pattern[0] =~# '^\k\k*$') ? { "begin": '\<', "end": '\>' } : { "begin": '', "end": '' }
		elseif l:type == "line"
			let l:pattern = getline(line("'["), line("']"))
			" Search exact lines
			let l:marker = { "begin": '^', "end": '$' }
		endif

		" Normalize strings for search pattern
		let l:pattern = join(map(l:pattern, { key, val -> escape(val, '\/') }), "\n")
		let l:pattern = substitute(l:pattern, "\t", '\\t', "g")
		let l:pattern = substitute(l:pattern, "\n", '\\n', "g")

		if exists("b:vimgrep_ft") && len(b:vimgrep_ft)
			" Recursive search for defined filetypes if possible
			let l:files = '**/*.{' . join(b:vimgrep_ft, ",") . '}'
		else
			" Recursive search for current file extension if possible
			" Otherwise, just for the current file
			let l:files = len(&filetype) ? '**/*.%:e' : '%'
		endif

		silent execute 'vimgrep /\C' . l:marker["begin"] . l:pattern . l:marker["end"] . '/j ' . l:files
		copen
	finally
		call <SID>RestoreEnv(l:saved)
	endtry
endfunction

" Comment or uncomment the char/line/block provided
function CommentOperator(...)
	if !exists('b:comment_str')
		return
	endif

	if a:0 == 0
		set opfunc=CommentOperator
		return 'g@'
	endif

	let l:saved = <SID>SaveEnv()
	try
		set clipboard= selection=inclusive

		let l:regex_str = '^\(\s*\)' . escape(b:comment_str, '/') . '\s'
		if getline(".") !~ l:regex_str
			silent execute "noautocmd keepjumps normal! '[_\<C-V>']I" . b:comment_str . ' '
		else
			silent execute "'[,']" . 's/' . l:regex_str . '\?/\1/e'
		endif
	finally
		call <SID>RestoreEnv(l:saved)
	endtry
endfunction

" Copy char/line/block into SnipMate register
function SnipMateVisualCopy(...)
	let l:commands = {
		\ "line": "'[V']y",
		\ "char": "`[v`]y",
		\ "block": "`[\<c-v>`]y"
	\ }

	if a:0 == 0
		set opfunc=SnipMateVisualCopy
		return 'g@'
	else
		let l:type = a:1
	endif

	let l:saved = <SID>SaveEnv()
	try
		set clipboard= selection=inclusive

		silent execute 'noautocmd keepjumps normal! ' . l:commands[l:type]
		let b:snipmate_visual = @"
	finally
		call <SID>RestoreEnv(l:saved)
	endtry
endfunction

" Cut char/line/block into SnipMate register
function SnipMateVisualCut(...)
	let l:commands = {
		\ "line": "'[V']d",
		\ "char": "`[v`]d",
		\ "block": "`[\<c-v>`]d"
	\ }

	if a:0 == 0
		set opfunc=SnipMateVisualCut
		return 'g@'
	else
		let l:type = a:1
	endif

	let l:saved = <SID>SaveEnv()
	try
		set clipboard= selection=inclusive

		silent execute 'noautocmd keepjumps normal! ' . l:commands[l:type]
		let b:snipmate_visual = @"
	finally
		call <SID>RestoreEnv(l:saved)
	endtry
endfunction

" Search and replace local or global declaration
function RefactorDecl(start, end)
	let l:saved = <SID>SaveEnv()

	silent execute 'noautocmd keepjumps normal! yiw'
	let l:old_word = @"

	call inputsave()
	let l:new_word = input("New name: ")
	normal :<ESC>
	call inputrestore()

	silent execute 'noautocmd keepjumps normal! ' . a:start . 'm<' . a:end . 'm>'
	silent execute 'noautocmd keepjumps' . "'<,'>" . 's/\V\<' . l:old_word . '\>/' . l:new_word . '/gcI'

	call <SID>RestoreEnv(l:saved)
endfunction
