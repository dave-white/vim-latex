" ============================================================================
" 	     File: texviewer.vim
"      Author: Mikolaj Machowski
"     Created: Sun Jan 26 06:00 PM 2003
" Description: make a viewer for various purposes: \cite{, \ref{
"     License: Vim Charityware License
"              Part of vim-latexSuite: http://vim-latex.sourceforge.net
" ============================================================================
" Tex_SetTexViewerMaps: sets maps for this ftplugin {{{

func! Tex_SetTexViewerMaps()
  inoremap <silent> <Plug>Tex_Completion <Esc>:call Tex_Complete("default","text")<CR>
  if !hasmapto('<Plug>Tex_Completion', 'i')
	if has('gui_running')
	  imap <buffer> <silent> <F9> <Plug>Tex_Completion
	else
	  imap <buffer> <F9> <Plug>Tex_Completion
	endif
  endif
endfunc

augroup LatexSuite
  au LatexSuite User LatexSuiteFileType 
		\ call Tex_Debug('texviewer.vim: Catching LatexSuiteFileType event', 'view') | 
		\ call Tex_SetTexViewerMaps()
augroup END

command -nargs=1 TLook    call Tex_Complete(<q-args>, 'tex')
command -nargs=1 TLookAll call Tex_Complete(<q-args>, 'all')
command -nargs=1 TLookBib call Tex_Complete(<q-args>, 'bib')

" }}}

" ==============================================================================
" Main completion function
" ==============================================================================
" Tex_Complete: main function {{{
" Description:
func! Tex_Complete(what, where)

  " Get info about current window and position of cursor in file
  let s:winnum = winnr()
  let s:pos = Tex_GetPos()

  " Change to the directory of the file being edited before running all the
  " :grep commands. We will change back to the original directory after we
  " finish with the grep.
  let s:origdir = fnameescape(getcwd())
  exe 'cd '.fnameescape(expand('%:p:h'))

  unlet! s:type
  unlet! s:typeoption

  if Tex_GetVarValue('Tex_WriteBeforeCompletion') == 1
	wall
  endif

  if a:where == "text"
	" What to do after <F9> depending on context
	let s:curline = strpart(getline('.'), 0, col('.'))
	let s:prefix = matchstr(s:curline, '.*{\zs.\{-}\(}\|$\)')
	" a command is of the type
	" \includegraphics[option=value]{file name}
	" Thus
	" 	s:curline = '\includegraphics[option=value]{file name'
	" (with possibly some junk before \includegraphics)
	" from which we need to extract
	" 	s:type = 'includegraphics'
	" 	s:typeoption = '[option=value]'
	let pattern = '.*\\\(\w\{-}\)\(\[.\{-}\]\)*{\([^ [\]\t]\+\)\?$'
	if s:curline =~ pattern
	  let s:type = substitute(s:curline, pattern, '\1', 'e')
	  let s:typeoption = substitute(s:curline, pattern, '\2', 'e')
	  call Tex_Debug('Tex_Complete: s:type = '.s:type.', typeoption = '.s:typeoption, 'view')
	endif

	if exists("s:type") && s:type =~ 'ref'
	  if Tex_GetVarValue('Tex_UseOutlineCompletion') == 1
		call Tex_Debug("Tex_Complete: using outline search method", "view")
		call Tex_StartOutlineCompletion()

	  elseif Tex_GetVarValue('Tex_UseSimpleLabelSearch') == 1
		call Tex_Debug("Tex_Complete: searching for \\labels with prefix '" . s:prefix . '"in all .tex files in the present directory', "view")
		call Tex_Grep('\\\%(nl\)\?label{'.s:prefix, '*.tex')
		call <SID>Tex_SetupCWindow()

	  elseif Tex_GetVarValue('Tex_ProjectSourceFiles') != ''
		call Tex_Debug('Tex_Complete: searching for \\labels in all Tex_ProjectSourceFiles', 'view')
		exec 'cd '.fnameescape(Tex_GetMainFileName(':p:h'))
		call Tex_Grep('\\\%(nl\)\?label{'.s:prefix, Tex_GetVarValue('Tex_ProjectSourceFiles'))
		call <SID>Tex_SetupCWindow()

	  else
		call Tex_Debug("Tex_Complete: calling Tex_GrepHelper", "view")
		" Clear the quickfix list
		cexpr []
		call Tex_GrepHelper(s:prefix, 'label')
		call <SID>Tex_SetupCWindow()
	  endif

	  redraw!

	elseif exists("s:type") && s:type =~ '[Cc]ite'

	  let s:prefix = matchstr(s:prefix, '\([^,]\+,\)*\zs\([^,]\+\)\ze$')
	  call Tex_Debug(":tex_complete: using s:prefix = ".s:prefix, "view")

	  if Tex_UsePython()
			\ && Tex_GetVarValue('Tex_UseCiteCompletionVer2') == 1

		exe 'cd '.s:origdir
		silent! call Tex_StartCiteCompletion()
		call Tex_EchoBibShortcuts()

	  elseif Tex_GetVarValue('Tex_UseJabref') == 1

		exe 'cd '.s:origdir
		let g:Remote_WaitingForCite = 1
		let citation = input('Enter citation from jabref (<enter> to leave blank): ')
		let g:Remote_WaitingForCite = 0
		call Tex_CompleteWord(citation, strlen(s:prefix))

	  else
		" Clear the quickfix list
		cexpr []
		if g:tex_rememberCiteSearch && exists('s:citeSearchHistory')
		  call <SID>Tex_SetupCWindow(s:citeSearchHistory)
		else
		  call Tex_GrepHelper(s:prefix, 'bib')
		  redraw!
		  call <SID>Tex_SetupCWindow()
		endif
		if g:tex_rememberCiteSearch && &ft == 'qf'
		  let _a = @a
		  silent! normal! ggVG"ay
		  let s:citeSearchHistory = @a
		  let @a = _a
		endif
	  endif

	elseif exists("s:type") && s:type =~ 'includegraphics'
	  call Tex_SetupFileCompletion(
			\ '', 
			\ '^\.\\|\.tex$\\|\.bib$\\|\.bbl$\\|\.zip$\\|\.gz$', 
			\ 'noext', 
			\ Tex_GetVarValue('Tex_ImageDir', '.'), 
			\ Tex_GetVarValue('Tex_ImageDir', ''))

	elseif exists("s:type") && s:type == 'bibliography'
	  call Tex_SetupFileCompletion(
			\ '\.b..$',
			\ '',
			\ 'noext',
			\ '.', 
			\ '')

	elseif exists("s:type") && s:type =~ 'include\(only\)\='
	  call Tex_SetupFileCompletion(
			\ '\.t..$', 
			\ '',
			\ 'noext',
			\ '.', 
			\ '')

	elseif exists("s:type") && s:type == 'input'
	  call Tex_SetupFileCompletion(
			\ '', 
			\ '',
			\ 'ext',
			\ '.', 
			\ '')

	elseif exists('s:type') && exists("g:tex_completion_".s:type)
	  call <SID>Tex_CompleteRefCiteCustom('plugin_'.s:type)

	else
	  let s:word = expand('<cword>')
	  if s:word == ''
		call Tex_SwitchToInsertMode()
		return
	  endif
	  call Tex_Debug("Tex_Grep('\<'".s:word."'\>', '*.tex')", 'view')
	  call Tex_Grep('\<'.s:word.'\>', '*.tex')

	  call <SID>Tex_SetupCWindow()
	endif

  elseif a:where == 'tex'
	" Process :TLook command
	call Tex_Grep(a:what, "*.tex")
	call <SID>Tex_SetupCWindow()

  elseif a:where == 'bib'
	" Process :TLookBib command
	call Tex_Grep(a:what, "*.bib")
	call Tex_Grepadd(a:what, "*.bbl")
	call <SID>Tex_SetupCWindow()

  elseif a:where == 'all'
	" Process :TLookAll command
	call Tex_Grep(a:what, "*")
	call <SID>Tex_SetupCWindow()
  endif

endfunc 
" }}}
" Tex_CompleteWord: inserts a word at the chosen location {{{
" Description: This function is meant to be called when the user press
" 	``<enter>`` in one of the [Error List] windows which shows the list of
" 	matches. completeword is the rest of the word which needs to be inserted.
" 	prefixlength characters are deleted before completeword is inserted
func! Tex_CompleteWord(completeword, prefixlength)
  " Set cursor to window and position recorded when completion was invoked.
  exe s:winnum.' wincmd w'
  call Tex_SetPos(s:pos)

  " Complete word, check if add closing }
  if a:prefixlength > 0
	if a:prefixlength > 1
	  exe 'normal! '.(a:prefixlength-1).'h'
	endif
	exe 'normal! '.a:prefixlength.'s'.a:completeword."\<Esc>"
  else
	exe 'normal! a'.a:completeword."\<Esc>"
  endif

  if getline('.')[col('.')-1] !~ '{' && getline('.')[col('.')] !~ '}'
	exe "normal! a}\<Esc>"
  endif

  " Return to Insert mode
  call Tex_SwitchToInsertMode()
endfunc
" }}}

" ==============================================================================
" File name completion helper functions
" ============================================================================== 
" Tex_SetupFileCompletion:  {{{
" Description: 
func! Tex_SetupFileCompletion(accept, reject, ext, dir, root)
  call FB_SetVar('FB_AllowRegexp', a:accept)
  call FB_SetVar('FB_RejectRegexp', a:reject)
  call FB_SetVar('FB_CallBackFunction', 'Tex_CompleteFileName')
  call FB_SetVar('FB_CallBackFunctionArgs', '"'.a:ext.'", "'.a:root.'"')

  call FB_OpenFileBrowser(a:dir)
endfunc
" }}}
" Tex_CompleteFileName:  {{{
" Description: 
func! Tex_CompleteFileName(filename, ext, root)
  let root = (a:root == '' ? Tex_GetMainFileName(':p:h') : a:root)

  call Tex_Debug('+Tex_CompleteFileName: getting filename '.a:filename, 'view')

  if a:ext == 'noext'
	let completeword = fnamemodify(a:filename, ':r')
  else
	let completeword = a:filename
  endif
  let completeword = Tex_RelPath(completeword, root)

  call Tex_Debug(":tex_completeFileName: completing with ".completeword, "view")
  call Tex_CompleteWord(completeword, strlen(s:prefix))
endfunc
" }}}
" Tex_Common: common part of strings {{{
func! s:Tex_Common(path1, path2)
  " Assume the caller handles 'ignorecase'
  if a:path1 == a:path2
	return a:path1
  endif
  let n = 0
  while a:path1[n] == a:path2[n]
	let n = n+1
  endwhile
  return strpart(a:path1, 0, n)
endfunc
" }}}
" Tex_NormalizePath:  {{{
" Description: 
func! Tex_NormalizePath(path)
  let retpath = a:path
  if has("win32") || has("win16") || has("dos32") || has("dos16")
	let retpath = substitute(retpath, '\\', '/', 'ge')
  endif
  if isdirectory(retpath) && retpath !~ '/$'
	let retpath = retpath.'/'
  endif
  return retpath
endfunc
" }}}
" Tex_RelPath: ultimate file name {{{
func! Tex_RelPath(explfilename,texfilename)
  let path1 = Tex_NormalizePath(a:explfilename)
  let path2 = Tex_NormalizePath(a:texfilename)

  let n = matchend(<SID>Tex_Common(path1, path2), '.*/')
  let path1 = strpart(path1, n)
  let path2 = strpart(path2, n)
  if path2 !~ '/'
	let subrelpath = ''
  else
	let subrelpath = substitute(path2, '[^/]\{-}/', '../', 'ge')
	let subrelpath = substitute(subrelpath, '[^/]*$', '', 'ge')
  endif
  let relpath = subrelpath.path1
  return escape(Tex_NormalizePath(relpath), ' ')
endfunc
" }}}

" ==============================================================================
" Helper functions for dealing with the 'quickfix' and 'preview' windows.
" ==============================================================================
" Tex_SetupCWindow: set maps and local settings for cwindow {{{
" Description: Set local maps jkJKq<cr> for cwindow. Also size and basic
" settings
"
func! s:Tex_SetupCWindow(...)
  call Tex_Debug('+Tex_SetupCWindow', 'view')
  cclose
  exe 'copen '. g:tex_viewerCwindowHeight
  " If called with an argument, it means we want to re-use some search
  " history from last time. Therefore, just paste it here and proceed.
  if a:0 == 1
	set modifiable
	% d _
	silent! 0put!=a:1
	$ d _
  endif
  setlocal nonumber
  setlocal nowrap

  let s:scrollOffVal = &scrolloff
  call <SID>Tex_SyncPreviewWindow()

  " If everything went well, then we should be situated in the quickfix
  " window. If there were problems, (no matches etc), then we will not be.
  " Therefore return.
  if &ft != 'qf'
	call Tex_Debug('not in quickfix window, quitting', 'view')
	return
  endif

  nnoremap <buffer> <silent> j j:call <SID>Tex_SyncPreviewWindow()<CR>
  nnoremap <buffer> <silent> k k:call <SID>Tex_SyncPreviewWindow()<CR>
  nnoremap <buffer> <silent> <up> <up>:call <SID>Tex_SyncPreviewWindow()<CR>
  nnoremap <buffer> <silent> <down> <down>:call <SID>Tex_SyncPreviewWindow()<CR>

  " Change behaviour of <cr> only for 'ref' and 'cite' context. 
  if exists("s:type") && s:type =~ 'ref\|cite'
	exec 'nnoremap <buffer> <silent> <cr> '
		  \ .':set scrolloff='.s:scrollOffVal.'<CR>'
		  \ .':cd '.s:origdir.'<CR>'
		  \ .':silent! call <SID>Tex_CompleteRefCiteCustom("'.s:type.'")<CR>'

  else
	" In other contexts jump to place described in cwindow and close small
	" windows
	exec 'nnoremap <buffer> <silent> <cr> '
		  \ .':set scrolloff='.s:scrollOffVal.'<CR>'
		  \ .':cd '.s:origdir.'<CR>'
		  \ .':call <SID>Tex_GoToLocation()<cr>'

  endif

  " Scroll the preview window while in the quickfix window
  nnoremap <buffer> <silent> J :wincmd j<cr><c-e>:wincmd k<cr>
  nnoremap <buffer> <silent> K :wincmd j<cr><c-y>:wincmd k<cr>

  " Exit the quickfix window without doing anything.
  exe 'nnoremap <buffer> <silent> q '
		\ .':set scrolloff='.s:scrollOffVal.'<CR>'
		\ .':cd '.s:origdir.'<CR>'
		\ .':call Tex_CloseSmallWindows()<CR>'

endfunc
" }}}
" Tex_CompleteRefCiteCustom: complete/insert name for current item {{{
" Description: handle completion of items depending on current context
"
func! s:Tex_CompleteRefCiteCustom(type)

  let prefixlength=strlen(s:prefix)
  if a:type =~ 'cite'
	" Look for a '\bibitem'
	let bibkey = matchstr(getline('.'), '\\bibitem\s*\%(\[.\{-}\]\)\?\s*{\zs.\{-}\ze}')
	if bibkey == ""
	  " Look for a '@article{bibkey,'
	  let bibkey = matchstr(getline('.'), '@\w*{\zs.*\ze,')
	endif

	let completeword = bibkey

  elseif a:type =~ 'ref'
	let label = matchstr(getline('.'), '\\\%(nl\)\?label{\zs.\{-}\ze}')
	let completeword = label

  elseif a:type =~ '^plugin_'
	let type = substitute(a:type, '^plugin_', '', '')
	let completeword = <SID>Tex_DoCompletion(type)
	" use old behaviour for plugins because of backward compatibility
	let prefixlength=0

  endif

  call Tex_CloseSmallWindows()
  call Tex_Debug(":tex_completeRefCiteCustom: completing with ".completeword, "view")
  call Tex_CompleteWord(completeword, prefixlength)
endfunc
" }}}
" Tex_SyncPreviewWindow: synchronize quickfix and preview window {{{
" Description: Usually quickfix engine takes care about most of these things
" but we discard it for better control of events.
"
func! s:Tex_SyncPreviewWindow()
  call Tex_Debug('+Tex_SyncPreviewWindow', 'view')

  let viewfile = matchstr(getline('.'), '^\f*\ze|\d')
  let viewline = matchstr(getline('.'), '|\zs\d\+\ze')

  " Hilight current line in cwindow
  " Normally hightlighting is done with quickfix engine but we use something
  " different and have to do it separately
  syntax clear
  runtime syntax/qf.vim
  exe 'syn match vTodo /\%'. line('.') .'l.*/'
  hi link vTodo Todo

  " Close preview window and open it again in new place
  pclose
  exe 'silent! bot pedit +'.viewline.' '.viewfile

  " Vanilla 6.1 has bug. This additional setting of cwindow height prevents
  " resizing of this window
  exe g:tex_viewerCwindowHeight.' wincmd _'

  " Handle situation if there is no item beginning with s:prefix.
  " Unfortunately, because we know it late we have to close everything and
  " return as in complete process 
  if v:errmsg =~ 'E32\>'
	exe s:winnum.' wincmd w'
	call Tex_SetPos(s:pos)
	pclose!
	cclose
	if exists("s:prefix")
	  echomsg 'No bibkey, label or word beginning with "'.s:prefix.'"'
	endif
	call Tex_SwitchToInsertMode()
	let v:errmsg = ''
	call Tex_Debug('Tex_SyncPreviewWindow: got error E32, no matches found, quitting', 'view')
	return 0
  endif

  " Move to preview window. Really is it under cwindow?
  wincmd j

  " Settings of preview window
  exe g:tex_viewerPreviewHeight.' wincmd _'
  setlocal nofoldenable

  if exists('s:type') && s:type =~ 'cite'
	" In cite context place bibkey at the top of preview window.
	setlocal scrolloff=0
	normal! zt
  else
	" In other contexts in the middle. Highlight this line?
	setlocal scrolloff=100
	normal! z.
  endif

  " Return to cwindow
  wincmd p

endfunc
" }}}
" Tex_CloseSmallWindows: {{{
" Description:
"
func! Tex_CloseSmallWindows()
  pclose!
  cclose
  exe s:winnum.' wincmd w'
  call Tex_SetPos(s:pos)
endfunc
" }}}
" Tex_GoToLocation: Go to chosen location {{{
" Description: Get number of current line and go to this number
"
func! s:Tex_GoToLocation()
  pclose!
  let errmsg = v:errmsg
  let v:errmsg = ''
  exe 'silent! cc ' . line('.')
  " If the current buffer is modified, then split
  if v:errmsg =~ '^E37:'
	split
	exe 'silent! cc ' . line('.')
  endif
  cclose
  let v:errmsg = errmsg
endfunc
" }}}

" ==============================================================================
" Functions for finding \\label's or \\bibitem's in the main file.
" ============================================================================== 
" Tex_GrepHelper: grep main filename for \\bibitem's or \\label's {{{
" Description: 
func! Tex_GrepHelper(prefix, what)
  let _path = &path
  let _suffixesadd = &suffixesadd
  let _hidden = &hidden

  let mainfname = Tex_GetMainFileName(':p')
  " If we are already editing the file, then use :split without any
  " arguments so it works even if the file is modified.
  " FIXME: If mainfname is being presently edited in another window and
  "        is 'modified', then the second split statement will not work.
  "        We will need to travel to that window and back.
  if mainfname == expand('%:p')
	split
  else
	exec 'split '.fnameescape(mainfname)
  endif

  let pos = Tex_GetPos()
  if a:what =~ 'bib'
	call Tex_ScanFileForCite(a:prefix)
  else
	call Tex_ScanFileForLabels(a:prefix)
  endif
  call Tex_SetPos(pos)

  q
  let &path = _path
  let &suffixesadd = _suffixesadd

endfunc
" }}}
" Tex_ScanFileForCite: search for \bibitem's in .bib or .bbl or tex files {{{
" Description: 
" Search for bibliographic entries in the presently edited file in the
" following manner:
" 1. First see if the file has a \bibliography command.
"    If YES:
"    	1. If a .bib file corresponding to the \bibliography command can be
"    	   found, then search for '@.*'.a:prefix inside it.
"    	2. Otherwise, if a .bbl file corresponding to the \bibliography command
"    	   can be found, then search for '\bibitem'.a:prefix inside it.
" 2. Next see if the file has a \thebibliography environment
"    If YES:
"    	1. Search for '\bibitem'.a:prefix in this file.
"
" If neither a \bibliography or \begin{thebibliography} are found, then repeat
" steps 1 and 2 for every file \input'ed into this file. Abort any searching
" as soon as the first \bibliography or \begin{thebibliography} is found.
func! Tex_ScanFileForCite(prefix)
  call Tex_Debug('+Tex_ScanFileForCite: searching for bibkeys.', 'view')
  let bibfiles = Tex_FindBibFiles( "", 0 )

  if bibfiles =~ '\S'
	let i = 1
	while 1
	  let bibname = Tex_Strntok(bibfiles, "\n", i)
	  if bibname == ''
		break
	  endif

	  " first try to find if a .bib file exists. If so do not search in
	  " the corresponding .bbl file. (because the .bbl file will most
	  " probably be generated automatically from the .bib file with
	  " bibtex).
	  let fname = Tex_FindFile(bibname, '.,'.g:tex_bIBINPUTS, '.bib')
	  if fname != ''
		call Tex_Debug('finding .bib file ['.bufname('%').']', 'view')
		exec 'split '.fnameescape(fname)
		call Tex_Grepadd('@.*{'.a:prefix, "%")
		q
	  else
		let fname = Tex_FindFile(bibname, '.,'.g:tex_bIBINPUTS, '.bbl')
		if fname != ''
		  exec 'split '.fnameescape(fname)
		  call Tex_Debug('finding .bbl file ['.bufname('.').']', 'view')
		  call Tex_Grepadd('\\bibitem{'.a:prefix, "%")
		  q
		else
		  " Assume that file is a full path - can also be a remote
		  " file or url, such as http://..., which is useful for
		  " use with zotero.
		  exec 'split "'.fnameescape(bibname).'"'
		  call Tex_Debug('opening bibliography file', 'view')
		  call Tex_Grepadd('@.*{'.a:prefix, "%")
		  q
		endif
	  endif

	  let i = i + 1
	endwhile

	return 1
  endif

  let foundCiteFile = 0

  " If we have a thebibliography environment, then again assume that this is
  " the only file which defines the bib-keys. And convey this information
  " upwards by returning 1.
  if search('^\s*\\begin{thebibliography}', 'w')
	call Tex_Debug('got a thebibliography environment in '.bufname('%'), 'view')

	let foundCiteFile = 1

	split
	exec 'lcd'.fnameescape(expand('%:p:h'))
	call Tex_Debug("Tex_Grepadd('\\bibitem\s*[\[|{]'".a:prefix.", \"%\")", 'view')
	call Tex_Grepadd('\\bibitem\s*[\[|{]'.a:prefix, "%")
	q

	return 1
  endif

  " If we have not found any \bibliography or \thebibliography environment
  " in this file, search for these environments in all the files which this
  " file includes.

  exec 0
  let wrap = 'w'
  while search('^\s*\\\(input\|include\)', wrap)
	let wrap = 'W'

	let filename = matchstr(getline('.'), '\\\(input\|include\){\zs.\{-}\ze}')

	let foundfile = Tex_FindFile(filename, '.,'.Tex_GetVarValue('Tex_TEXINPUTS'), '.tex')
	if foundfile != ''
	  exec 'split '.fnameescape(foundfile)
	  call Tex_Debug('scanning recursively in ['.foundfile.']', 'view')
	  let foundCiteFile = Tex_ScanFileForCite(a:prefix)
	  q
	endif

	if foundCiteFile
	  return 1
	endif
  endwhile


  return 0
endfunc
" }}}
" Tex_ScanFileForLabels: greps present file and included files for \\label's {{{
" Description: 
" Grep the presently edited file for \\label's. If the present file \include's
" or \input's other files, then recursively scan those as well, i.e we support
" arbitrary levels of \input'ed-ness.
func! Tex_ScanFileForLabels(prefix)
  call Tex_Debug("+Tex_ScanFileForLabels: grepping in file [".bufname('%')."]", "view")

  exec 'lcd'.fnameescape(expand('%:p:h'))
  call Tex_Grepadd('\\\%(nl\)\?label{'.a:prefix, "%")

  " Then recursively grep for all \include'd or \input'ed files.
  exec 0
  let wrap = 'w'
  while search('^\s*\\\(input\|include\)', wrap)
	let wrap = 'W'

	let filename = matchstr(getline('.'), '\\\(input\|include\){\zs.\{-}\ze}')
	let foundfile = Tex_FindFile(filename, '.,'.Tex_GetVarValue('Tex_TEXINPUTS'), '.tex')
	if foundfile != ''
	  exec 'split '.fnameescape(foundfile)
	  call Tex_Debug('Tex_ScanFileForLabels: scanning recursively in ['.foundfile.']', 'view')
	  call Tex_ScanFileForLabels(a:prefix)
	  q
	endif
  endwhile

endfunc
" }}}

" ==============================================================================
" Functions for custom command completion
" ==============================================================================
" Tex_completion_{var}: similar variables can be set in package files {{{
let g:tex_completion_bibliographystyle = 'abbr,alpha,plain,unsrt'
let g:tex_completion_addtocontents = 'lof}{,lot}{,toc}{'
let g:tex_completion_addcontentsline = 'lof}{figure}{,lot}{table}{,toc}{chapter}{,toc}{part}{,'.
	  \ 'toc}{section}{,toc}{subsection}{,toc}{paragraph}{,'.
	  \ 'toc}{subparagraph}{'
" }}}
" Tex_PromptForCompletion: prompts for a completion {{{
" Description: 
func! s:Tex_PromptForCompletion(texcommand,ask)

  let common_completion_prompt = 
		\ Tex_CreatePrompt(g:tex_completion_{a:texcommand}, 2, ',') . "\n" .
		\ 'Enter number or completion: '

  let inp = input(a:ask."\n".common_completion_prompt)
  if inp =~ '^[0-9]\+$'
	let completion = Tex_Strntok(g:tex_completion_{a:texcommand}, ',', inp)
  else
	let completion = inp
  endif

  return completion
endfunc
" }}}
" Tex_DoCompletion: fast insertion of completion {{{
" Description:
"
func! s:Tex_DoCompletion(texcommand)
  let completion = <SID>Tex_PromptForCompletion(a:texcommand, 'Choose a completion to insert: ')
  if completion != ''
	return completion
  else
	return ''
  endif
endfunc
" }}}

" ==============================================================================
" Functions for presenting an outlined version for completion
" ============================================================================== 
" Tex_StartOutlineCompletion: sets up an outline window {{{

" get the place where this plugin resides for setting cpt and dict options.
" these lines need to be outside the function.
let s:path = expand('<sfile>:p:h')
if Tex_UsePython()
  exec g:tex_pythonCmd . " import sys, re"
  exec g:tex_pythonCmd . " sys.path += [r'". s:path . "']"
  exec g:tex_pythonCmd . " import outline"
endif

func! Tex_StartOutlineCompletion()
  let mainfname = Tex_GetMainFileName(':p')

  " open the buffer
  let _report = &report
  let _cmdheight=&cmdheight
  let _lazyredraw = &lazyredraw
  set report=1000
  set cmdheight=1
  set lazyredraw

  bot split __OUTLINE__
  exec Tex_GetVarValue('Tex_OutlineWindowHeight', 15).' wincmd _'

  setlocal modifiable
  setlocal noswapfile
  setlocal buftype=nowrite
  setlocal bufhidden=delete
  setlocal nowrap
  setlocal foldmethod=marker
  setlocal foldmarker=<<<,>>>

  if Tex_UsePython()
	exec g:tex_pythonCmd . ' retval = outline.main(r"""' . mainfname . '""", """' . s:prefix . '""")'
	exec g:tex_pythonCmd . ' vim.current.buffer[:] = retval.splitlines()'
  else
	" delete everything in it to the blackhole
	% d _

	let retval = system(shellescape(s:path.'/outline.py').' '.shellescape(mainfname).' '.shellescape(s:prefix))
	0put!=retval
  endif

  0

  call Tex_SetupOutlineSyntax()

  exec 'nnoremap <buffer> <silent> <cr> '
		\ .':cd '.s:origdir.'<CR>'
		\ .':call Tex_FinishOutlineCompletion()<CR>'
  exec 'nnoremap <buffer> <silent> q '
		\ .':cd '.s:origdir.'<CR>'
		\ .':close<CR>'
		\ .':call Tex_SwitchToInsertMode()<CR>'

  " once the buffer is initialized, go back to the original settings.
  setlocal nomodifiable
  setlocal nomodified
  let &report = _report
  let &cmdheight = _cmdheight
  let &lazyredraw = _lazyredraw

endfunc
" }}}
" Tex_SetupOutlineSyntax: sets up the syntax items for the outline {{{
" Description: 
func! Tex_SetupOutlineSyntax()
  syn match outlineFileName "<\f\+>$" contained
  syn match foldMarkers "<<<\d$" contained
  syn match firstSemiColon '^:' contained
  syn match firstAngle '^>' contained

  syn match sectionNames '\(\d\.\)\+ .*' contains=foldMarkers
  syn match previousLine '^:.*' contains=firstSemiColon
  syn match labelLine '^>.*' contains=firstAngle,outlineFileName

  hi def link outlineFileName Ignore
  hi def link foldMarkers Ignore
  hi def link firstSemiColon Ignore
  hi def link firstAngle Ignore

  hi def link sectionNames Type
  hi def link previousLine Special
  hi def link labelLine Comment
endfunc
" }}}
" Tex_FinishOutlineCompletion: inserts the reference back in the text {{{
func! Tex_FinishOutlineCompletion()
  if getline('.') !~ '^[>:]'
	return
  endif

  if getline('.') =~ '^>'
	let ref_complete = matchstr(getline('.'), '^>\s\+\zs\S\+\ze')
  elseif getline('.') =~ '^:'
	let ref_complete = matchstr(getline(line('.')-1), '^>\s\+\zs\S\+\ze')
  endif

  close
  call Tex_CompleteWord(ref_complete, strlen(s:prefix))
endfunc
" }}}

" ==============================================================================
" Functions for presenting a nicer list of bibtex entries
" ============================================================================== 
" Tex_FindBibFiles: finds all .bib files used by the current or main file {{{
" Description: 
"   a:filename : we look in this file. If this string is empty, look in the currently edited file
"   a:recursive: look into included/inputed files
func! Tex_FindBibFiles( currfile, recursive )
  call Tex_Debug(":tex_findBibFiles: ", "view")

  if a:currfile !=# ""
	split
	exec 'silent! e '.fnameescape(a:currfile)
  endif

  " No bibfiles found yet
  let bibfiles = ''

  " Position the cursor at the start of the file
  call setpos('.', [0,1,1,0])

  while 1
	let line_start = search('\%(\\\@<!\%(\\\\\)*%.*\)\@<!\\\%(\%(no\)\?bibliography\|addbibresource\%(\[.*\]\)\?\)\zs{', 'W')
	if line_start == 0
	  break
	endif

	call Tex_Debug('Tex_FindBibFiles: found bibliography command in '.bufname('%'), 'view')

	" extract the bibliography filenames from the command.
	" First, look for the closing brace
	let line_end = search('\%(\\\@<!\%(\\\\\)*%.*\)\@<!}', 'nWc')

	call Tex_Debug(":tex_findBibFiles: bib command from line " . line_start . " to line " . line_end, "view")

	" Now, extract all these lines
	" In the first line, start at the bib-command (current column)
	let lines = strpart(getline(line_start), getpos('.')[2])
	for line_nr in range(line_start+1, line_end)
	  " Strip comments and concatenate
	  let lines .= substitute(getline(line_nr), '\\\@<!\%(\\\\\)*\zs%.*$','','')
	endfor
	call Tex_Debug(":tex_findBibFiles: concatenated bib command: \"" . lines . "\"", "view")

	" Finally, extract the file names
	let bibnames = matchstr(lines, '^\zs.\{-}\ze}')
	let bibnames = substitute(bibnames, '\s', '', 'g')

	call Tex_Debug(':tex_findBibFiles: trying to search through ['.bibnames.']', 'view')

	let i = 1
	while 1
	  let bibname = Tex_Strntok(bibnames, ',', i)
	  if bibname == ''
		break
	  endif
	  let fname = Tex_FindFile(bibname, '.,'.g:tex_bIBINPUTS, '.bib')
	  if fname != ''
		let bibfiles = bibfiles.fname."\n"
	  endif
	  let i = i + 1
	endwhile

	if getline('.') =~# '\%(\\\@<!\%(\\\\\)*%.*\)\@<!\\\%(no\)\?bibliography{'
	  " Only one \[no]bibliography allowed by LaTeX
	  break
	endif
  endwhile

  call Tex_Debug(":tex_findBibFiles: in this file: [".bibfiles."]", "view")

  if a:recursive
	" Now, search recursively

	" Position the cursor at the start of the file
	call setpos('.', [0,1,1,0])

	" Accept a match at the very beginning of the file
	let flags = 'cW'

	while search('^\s*\\\%(input\|include\)', flags)
	  let flags = 'W'
	  let filename = matchstr(getline('.'), '^\s*\\\%(input\|include\){\zs.\{-}\ze}')
	  let foundfile = Tex_FindFile(filename, '.,'.Tex_GetVarValue('Tex_TEXINPUTS'), '.tex')
	  if foundfile != ''
		call Tex_Debug(':tex_findBibFiles: scanning recursively in ['.foundfile.']', 'view')
		let bibfiles .= Tex_FindBibFiles( foundfile, a:recursive )
	  endif
	endwhile
  endif

  call Tex_Debug(":tex_findBibFiles: with included files: [".bibfiles."]", "view")

  if a:currfile !=# ""
	q
  endif

  return bibfiles

endfunc
" }}}
" Tex_StartBibtexOutline: sets up an outline window {{{

" get the place where this plugin resides for setting cpt and dict options.
" these lines need to be outside the function.
if Tex_UsePython()
  exec g:tex_pythonCmd . " import sys, re"
  exec g:tex_pythonCmd . " sys.path += [r'". s:path . "']"
  exec g:tex_pythonCmd . " import bibtools"
endif

func! Tex_StartCiteCompletion()
  let bibfiles = Tex_FindBibFiles( Tex_GetMainFileName(':p'), 1 )
  if bibfiles !~ '\S'
	call Tex_Debug(':tex_startCiteCompletion: No bibfiles found.', 'view')
	call Tex_SwitchToInsertMode()
	return
  endif

  bot split __OUTLINE__
  exec Tex_GetVarValue('Tex_OutlineWindowHeight', 15).' wincmd _'

  exec g:tex_pythonCmd . ' Tex_BibFile = bibtools.BibFile(r"""'.bibfiles.'""")'
  exec g:tex_pythonCmd . ' Tex_BibFile.addfilter(r"key ^'.s:prefix.'")'

  call Tex_DisplayBibList()
  "call Tex_EchoBibShortcuts()

  nnoremap <buffer> <Plug>Tex_JumpToNextBibEntry :call search('^\S.*\]$', 'W')<CR>z.:call Tex_EchoBibShortcuts()<CR>
  nnoremap <buffer> <Plug>Tex_JumpToPrevBibEntry :call search('^\S.*\]$', 'bW')<CR>z.:call Tex_EchoBibShortcuts()<CR>
  nnoremap <buffer> <Plug>Tex_FilterBibEntries   :call Tex_HandleBibShortcuts('filter')<CR>
  nnoremap <buffer> <Plug>Tex_RemoveBibFilters   :call Tex_HandleBibShortcuts('remove_filters')<CR>
  nnoremap <buffer> <Plug>Tex_SortBibEntries	  :call Tex_HandleBibShortcuts('sort')<CR>
  nnoremap <buffer> <Plug>Tex_CompleteCiteEntry  :call Tex_CompleteCiteEntry()<CR>

  nmap <buffer> <silent> n 		<Plug>Tex_JumpToNextBibEntry
  nmap <buffer> <silent> p 		<Plug>Tex_JumpToPrevBibEntry
  nmap <buffer> <silent> f		<Plug>Tex_FilterBibEntries
  nmap <buffer> <silent> s		<Plug>Tex_SortBibEntries
  nmap <buffer> <silent> a		<Plug>Tex_RemoveBibFilters
  nmap <buffer> <silent> q		:close<CR>:call Tex_SwitchToInsertMode()<CR>
  nmap <buffer> <silent> <CR>		<Plug>Tex_CompleteCiteEntry

endfunc
" }}}
" Tex_DisplayBibList: displays the list of bibtex entries {{{
" Description: 
func! Tex_DisplayBibList()
  " open the buffer
  let _report = &report
  let _cmdheight=&cmdheight
  let _lazyredraw = &lazyredraw
  set report=1000
  set cmdheight=1
  set lazyredraw

  setlocal modifiable
  setlocal noswapfile
  setlocal buftype=nowrite
  setlocal bufhidden=delete
  setlocal nowrap
  setlocal foldmethod=marker
  setlocal foldmarker=<<<,>>>


  " delete everything in it to the blackhole
  % d _

  exec g:tex_pythonCmd . ' vim.current.buffer[:] = Tex_BibFile.__str__().splitlines()'

  call Tex_SetupBibSyntax()

  0

  " once the buffer is initialized, go back to the original settings.
  setlocal nomodifiable
  setlocal nomodified
  let &report = _report
  let &cmdheight = _cmdheight
  let &lazyredraw = _lazyredraw

endfunc
" }}}
" Tex_EchoBibShortcuts: echos all the shortcuts in the status line {{{
" Description:
func! Tex_EchoBibShortcuts()
  echomsg '(a) all (f) filter (s) sort (n) next (p) previous (q) quit (<CR>) choose'
endfunc
" }}}
" Tex_SetupBibSyntax: sets up the syntax items for the outline {{{
" Description: 
func! Tex_SetupBibSyntax()
  syn match BibTitleHeader "^TI" contained
  syn match BibAuthorHeader "^AU" contained
  syn match BibLocationHeader "^IN" contained
  syn match BibMiscHeader "^MI" contained

  syn match BibKeyLine '^\S.*\]$' contains=BibKey
  syn match BibTitle "^TI .*" contains=BibTitleHeader
  syn match BibAuthor "^AU .*" contains=BibAuthorHeader
  syn match BibLocation "^IN .*" contains=BibLocationHeader
  syn match BibMisc "^MI .*" contains=BibMiscHeader

  hi def link BibTitleHeader Ignore
  hi def link BibAuthorHeader Ignore
  hi def link BibLocationHeader Ignore
  hi def link BibMiscHeader Ignore

  hi def link BibKeyLine Visual
  hi def link BibTitle Type
  hi def link BibAuthor Special
  hi def link BibLocation Comment
  hi def link BibMisc Comment
endfunc
" }}}
" Tex_HandleBibShortcuts: handles user keypresses {{{
" Description: 
func! Tex_HandleBibShortcuts(command)

  if a:command == 'filter' || a:command == 'sort'

	let fieldprompt = 
		  \ "Field acronyms: (`:let g:tex_echoBibFields = 0` to avoid this message)\n" .
		  \ " [t] title         [a] author        [b] booktitle     \n" .
		  \ " [j] journal       [y] year          [p] bibtype       \n" .
		  \ " (you can also enter the complete field name)    \n"

	let fieldprompt = Tex_GetVarValue('Tex_BibFieldPrompt', fieldprompt)

	if Tex_GetVarValue('Tex_EchoBibFields', 1) == 1
	  echo fieldprompt
	endif

	if a:command == 'filter'
	  let inp = input('Enter '.a:command.' criterion [field<space>value]: ')
	  if inp !~ '\v^\S+\s+\S.*'
		echohl WarningMsg
		echomsg 'Invalid filter specification. Use "field<space>value"'
		echohl None
		return
	  endif
	else
	  let inp = input('Enter '.a:command.' criterion [field]: ')
	endif

	if inp != ''
	  " If the field is specified as a single character, then replace
	  " it with the corresponding 'full form'.
	  if inp =~ '^[a-z]\>'
		if Tex_GetVarValue('Tex_BibAcronym_'.inp[0]) != ''
		  let inp = substitute(inp, '.', Tex_GetVarValue('Tex_BibAcronym_'.inp[0]), '')
		elseif fieldprompt =~ '\['.inp[0].'\]'
		  let full = matchstr(fieldprompt, '\['.inp[0].'\] \zs\w\+\ze')
		  let inp = substitute(inp, '.', full, '')
		endif
	  endif
	  call Tex_Debug(":tex_handleBibShortcuts: using inp = [".inp."]", "view")
	  if a:command == 'filter'
		exec g:tex_pythonCmd . ' Tex_BibFile.addfilter(r"'.inp.'")'
	  elseif a:command == 'sort'
		exec g:tex_pythonCmd . " Tex_BibFile.addsortfield(r\"".inp."\")"
		exec g:tex_pythonCmd . ' Tex_BibFile.sort()'
	  endif
	  silent! call Tex_DisplayBibList()
	endif

  elseif a:command == 'remove_filters'

	exec g:tex_pythonCmd . ' Tex_BibFile.rmfilters()'
	exec g:tex_pythonCmd . ' Tex_BibFile.addfilter(r"key ^'.s:prefix.'")'
	call Tex_DisplayBibList()

  endif

endfunc
" }}}
" Tex_CompleteCiteEntry: completes cite entry {{{
" Description: 
func! Tex_CompleteCiteEntry()
  normal! $
  call search('\[\S\+\]$', 'bc')

  if getline('.') !~ '\[\S\+\]$'
	return
  endif

  let ref = matchstr(getline('.'), '\[\zs\S\+\ze\]$')
  close
  call Tex_Debug(":tex_completeCiteEntry: completing with ".ref, "view")
  call Tex_CompleteWord(ref, strlen(s:prefix))
endfunc
" }}}

" Tex_SwitchToInsertMode: Switch to insert mode {{{
" Description: This is usually called when completion is finished
func! Tex_SwitchToInsertMode()
  call Tex_Debug(":tex_switchToInsertMode: ", "view")
  if col('.') == strlen(getline('.'))
	startinsert!
  else
	normal! l
	startinsert
  endif
endfunc
" }}}

com! -nargs=0 TClearCiteHist unlet! s:citeSearchHistory

" vim:fdm=marker:nowrap:noet:ff=unix
