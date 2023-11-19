" Function definitions

" Save clipboard, selection, unnamed register and visual marks
function s:SaveEnv()
	const l:dic = #{
		\ clipboard: &clipboard,
		\ selection: &selection,
		\ unnamed_register: getreginfo('"'),
		\ visual_marks: { "start": getpos("'<'"), "end": getpos("'>") },
	\ }

	return l:dic
endfunction

" Restore clipboard, selection, unnamed register and visual marks
function s:RestoreEnv(dic)
	let &clipboard = a:dic["clipboard"]
	let &selection = a:dic["selection"]
	call setreg('"', a:dic["unnamed_register"])
	call setpos("'<", a:dic["visual_marks"]["start"])
	call setpos("'>", a:dic["visual_marks"]["end"])
endfunction

" Comment or uncomment the char/line/block provided
function CommentOperator(type = '') abort
	if !exists('b:comment_str')
		return
	endif

	if a:type == ''
		set opfunc=CommentOperator
		return 'g@'
	endif

	let l:saved = <SID>SaveEnv()
	try
		set clipboard= selection=inclusive

		let l:regex_str = '^\(\s*\)' .. escape(b:comment_str, '/') .. '\s'
		if getline(".") !~ l:regex_str
			silent exe "noautocmd keepjumps normal! '[_\<C-V>']I" .. b:comment_str .. ' '
		else
			silent exe "'[,']" .. 's/' .. l:regex_str .. '\?/\1/e'
		endif
	finally
		call <SID>RestoreEnv(l:saved)
	endtry
endfunction

" Copy char/line/block into SnipMate register
function SnipMateVisualCopy(type = '') abort
	const commands = #{
		\ line: "'[V']y",
		\ char: "`[v`]y",
		\ block: "`[\<c-v>`]y"
	\ }

	if a:type == ''
		set opfunc=SnipMateVisualCopy
		return 'g@'
	endif

	let l:saved = <SID>SaveEnv()
	try
		set clipboard= selection=inclusive

		silent exe 'noautocmd keepjumps normal! ' .. get(commands, a:type, '')
		let b:snipmate_visual = @"
	finally
		call <SID>RestoreEnv(l:saved)
	endtry
endfunction

" Cut char/line/block into SnipMate register
function SnipMateVisualCut(type = '') abort
	const commands = #{
		\ line: "'[V']d",
		\ char: "`[v`]d",
		\ block: "`[\<c-v>`]d"
	\ }

	if a:type == ''
		set opfunc=SnipMateVisualCut
		return 'g@'
	endif

	let l:saved = <SID>SaveEnv()
	try
		set clipboard= selection=inclusive

		silent exe 'noautocmd keepjumps normal! ' .. get(commands, a:type, '')
		let b:snipmate_visual = @"
	finally
		call <SID>RestoreEnv(l:saved)
	endtry
endfunction
