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
function CommentOperator(type = '')
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
			silent execute "noautocmd keepjumps normal! '[_\<C-V>']I" .. b:comment_str .. ' '
		else
			silent execute "'[,']" .. 's/' .. l:regex_str .. '\?/\1/e'
		endif
	finally
		call <SID>RestoreEnv(l:saved)
	endtry
endfunction

" Copy char/line/block into SnipMate register
function SnipMateVisualCopy(type = '')
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

		silent execute 'noautocmd keepjumps normal! ' .. get(commands, a:type, '')
		let b:snipmate_visual = @"
	finally
		call <SID>RestoreEnv(l:saved)
	endtry
endfunction

" Cut char/line/block into SnipMate register
function SnipMateVisualCut(type = '')
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

		silent execute 'noautocmd keepjumps normal! ' .. get(commands, a:type, '')
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

	silent execute 'noautocmd keepjumps normal! ' .. a:start .. 'm<' .. a:end .. 'm>'
	silent execute 'noautocmd keepjumps' .. "'<,'>" .. 's/\V\<' .. l:old_word .. '\>/' .. l:new_word .. '/gcI'

	call <SID>RestoreEnv(l:saved)
endfunction

function VimGrepOperator(type = '')
	const commands = #{
		\ line: "'[V']y",
		\ char: "`[v`]y",
		\ block: "`[\<c-v>`]y"
	\ }

	if a:type == ''
		set opfunc=VimGrepOperator
		return 'g@'
	endif

	let l:saved = <SID>SaveEnv()
	try
		set clipboard= selection=inclusive

		silent execute 'noautocmd keepjumps normal! ' .. get(commands, a:type, '')
		let l:pattern = escape(@", '\/')

		if exists("b:vimgrep_ft") && b:vimgrep_ft->len()
			let l:files = '**/*.{' .. b:vimgrep_ft->join(",") .. '}'
		else
			let l:files = &filetype->len() ? '**/*.%:e' : '%'
		endif

		silent execute 'vimgrep /\C\<' .. l:pattern .. '\>/j ' .. l:files
		copen
	finally
		call <SID>RestoreEnv(l:saved)
	endtry
endfunction
