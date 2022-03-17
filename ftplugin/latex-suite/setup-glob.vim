" vim:ft=vim:fdm=marker

nmap <silent> <script> <plug> i
imap <silent> <script> <C-o><plug> <Nop>

let s:path = expand('<sfile>:p:h')

" Python {{{
if has('python3')
  let g:tex_pythonVersion = 3
  let g:tex_pythonCmd = 'python3'
  let g:tex_pythonFileCmd = 'py3file'
elseif has('python')
  let g:tex_pythonVersion = 2
  let g:tex_pythonCmd = 'python'
  let g:tex_pythonFileCmd = 'pyfile'
else
  let g:tex_pythonVersion = 0
endif

func! Tex_UsePython()
  return g:tex_pythonVersion && g:tex_usePython
endfunc

" Define the functions in python if available.
if Tex_UsePython()
  exec g:tex_pythonFileCmd . ' ' . fnameescape(expand('<sfile>:p:h'))
	\ . '/pytools.py'
endif
" }}}
" Define functions. {{{
" =========================================================================
" Helper functions for debugging
" =========================================================================
" Tex_Debug: appends the argument into s:debugString {{{
" Description: 
" 
" Do not want a memory leak! Set this to zero so that latex-suite always
" starts out in a non-debugging mode.
function! Tex_Debug(str, ...)
  if !g:tex_debug
    return
  endif
  if a:0 > 0
    let pattern = a:1
  else
    let pattern = ''
  endif

  " If g:tex_debug:tex_og' is given, write debug information into this file 
  " (preferred method).  Otherwise, save it in a variable
  if !empty(g:tex_debug:tex_og)
    exec 'redir! >> '.g:tex_debug:tex_og
    silent! echo pattern.' : '.a:str
    redir END
  else
    if !exists('s:debugString_'.pattern)
      let s:debugString_{pattern} = ''
    endif
    let s:debugString_{pattern} = s:debugString_{pattern}.a:str."\n"

    if !exists('s:debugString_')
      let s:debugString_ = ''
    endif
    let s:debugString_ = s:debugString_ . pattern.' : '.a:str."\n"
  endif
endfunction " }}}
" Tex_PrintDebug: prings s:debugString {{{
" Description: 
" 
function! Tex_PrintDebug(...)
  if a:0 > 0
    let pattern = a:1
  else
    let pattern = ''
  endif
  if exists('s:debugString_'.pattern)
    echo s:debugString_{pattern}
  endif
endfunction " }}}
" Tex_ClearDebug: clears the s:debugString string {{{
" Description: 
" 
function! Tex_ClearDebug(...)
  if a:0 > 0
    let pattern = a:1
  else
    let pattern = ''
  endif
  if exists('s:debugString_'.pattern)
    let s:debugString_{pattern} = ''
  endif
endfunction " }}}
" Tex_ShowVariableValue: debugging help {{{
" provides a way to examine script local variables from outside the script.
" very handy for debugging.
function! Tex_ShowVariableValue(...)
  let i = 1
  while i <= a:0
    exe 'let arg = a:'.i
    if exists('s:'.arg) ||
	  \  exists('*s:'.arg)
      exe 'let val = s:'.arg
      echomsg 's:'.arg.' = '.val
    endif
    let i = i + 1
  endwhile
endfunction

" }}}
" ========================================================================
" Helper functions for grepping
" ======================================================================== 
" Tex_Grep: shorthand for :vimgrep {{{
function! Tex_Grep(string, where)
  exec 'silent! vimgrep! /'.a:string.'/ '.a:where
endfunction

" }}}
" Tex_Grepadd: shorthand for :vimgrepadd {{{
function! Tex_Grepadd(string, where)
  exec 'silent! vimgrepadd! /'.a:string.'/ '.a:where
endfunction

" }}}
" ========================================================================
" Uncategorized helper functions
" ======================================================================== 
" Tex_Strntok: extract the n^th token from a list {{{
" example: Strntok('1,23,3', ',', 2) = 23
fun! Tex_Strntok(s, tok, n)
  return matchstr(a:s . a:tok[0], '\v(\zs([^' . a:tok . ']*)\ze['
	\ . a:tok . ']){' . a:n . '}')
endfun
" }}}
" Tex_CountMatches: count number of matches of pat in string {{{
fun! Tex_CountMatches( string, pat )
  let pos = 0
  let cnt = 0
  while pos >= 0
    let pos = matchend(a:string, a:pat, pos)
    let cnt = cnt + 1
  endwhile
  " We have counted one match to much
  return cnt - 1
endfun

" }}}
" Tex_CreatePrompt: creates a prompt string {{{
" Description: Arguments:
"     promptList: This is a string of the form:
"         'item1,item2,item3,item4'
"     cols: the number of columns in the resultant prompt
"     sep: the list seperator token
"
" Example:
" Tex_CreatePrompt('item1,item2,item3,item4', 2, ',')
" returns
" "(1) item1\t(2)item2\n(3)item3\t(4)item4"
"
" This string can be used in the input() function.
func Tex_CreatePrompt(promptList, cols)
  " There is one more item than matches of the seperator
  let num_common = len(a:promptList)

  let i = 1
  let promptStr = ""

  while i <= num_common

    let j = 0
    while j < a:cols && i + j <= num_common
      let com = a:promptList[i+j]
      let promptStr .= '('.(i+j).') '.com."\t".(strlen(com) < 4 ? "\t" : '')
      let j += 1
    endwhile

    let promptStr .= "\n"

    let i += a:cols
  endwhile
  return promptStr
endfunc

" }}}
" Tex_CleanSearchHistory: removes last search item from search history {{{
" Description: This function needs to be globally visible because its
"              called from outside the script during expansion.
function! Tex_CleanSearchHistory()
  call histdel("/", -1)
  let @/ = histget("/", -1)
endfunction
nmap <silent> <script> <plug>cleanHistory
      \ :call Tex_CleanSearchHistory()<CR>

" }}}
" Tex_GetVarValue: gets the value of the variable {{{
" Description: See if a window-local, buffer-local or global variable with 
" the given name
" 	exists and if so, returns the corresponding value. If none exist, 
" 	return
" 	an empty string.
function! Tex_GetVarValue(varname, ...)
  if exists('w:'.a:varname)
    return w:{a:varname}
  elseif exists('b:'.a:varname)
    return b:{a:varname}
  elseif exists('g:'.a:varname)
    return g:{a:varname}
  elseif a:0 > 0
    return a:1
  else
    return ''
  endif
endfunction " }}}
" Tex_GetMainFileName: gets the name of the main file being compiled. {{{
" Description:  returns the full path name of the main file.
"               This function checks for the existence of a .latexmain file
"               which might point to the location of a "main" latex file.
"               If .latexmain exists, then return the full path name of the
"               file being pointed to by it.
"
"               Otherwise, return the full path name of the current buffer.
"
"               You can supply an optional "modifier" argument to the
"               function, which will optionally modify the file name before
"               returning.
" NOTE: From version 1.6 onwards, this function always trims away the 
" .latexmain part of the file name before applying the modifier argument.
function! Tex_GetMainFileName(...)
  if a:0 > 0
    let modifier = a:1
  else
    let modifier = ':p'
  endif

  if b:tex_mainFileXpr =~ '^\/.*'
    " Absolute path.
    let l:fname = glob(b:tex_mainFileXpr)
    if filereadable(l:fname)
      return fnamemodify(l:fname, modifier)
    endif
  else
    " Relative path/name.
    let l:fname = Tex_FindFileAbove(b:tex_mainFileXpr)
    if filereadable(l:fname)
      return fnamemodify(l:fname, modifier)
    endif
  endif
endfunction 

" }}}
" Tex_ChooseFromPrompt: process a user input to a prompt string {{{
" " Description: 
function! Tex_ChooseFromPrompt(dialog, list)
  let inp = input(a:dialog)
  " This is a workaround for a bug(?) in vim, see
  " https://github.com/vim/vim/issues/778
  redraw
  if inp =~ '\d\+'
    return a:list[inp+1]
  else
    return inp
  endif
endfunction
" }}}
" Tex_IncrementNumber: returns an incremented number each time {{{
" Description: 
let s:incnum = 0
function! Tex_IncrementNumber(increm)
  let s:incnum = s:incnum + a:increm
  return s:incnum
endfunction 

" }}}
" Tex_ResetIncrementNumber: increments s:incnum to zero {{{
" Description: 
function! Tex_ResetIncrementNumber(val)
  let s:incnum = a:val
endfunction
" }}}
" Tex_FindInDirectory: check if file exists in a directory {{{
" Description:	Checks if file exists in globpath(directory, ...) and cuts 
" off the rest of returned names. This guarantees that sourced file is from 
" $HOME.  If the argument a:rtp is set, we interpret a:directory as a 
"subdirectory of &rtp/ftplugin/latex-suite/.  If an optional argument is 
"given, it specifies how to expand each filename found.  For example, '%:p' 
"will return a list of the complete paths to the files. By default returns 
"trailing path-names without extenions.
" NOTE: This function is very slow when a large number of matches are found 
" because of a while loop which modifies each filename found.  Some speedup 
" was acheived by using a tokenizer approach rather than using Tex_Strntok 
" which would have been more obvious.
"
function! Tex_FindInDirectory(filename, rtp, directory, ...)
  " how to expand each filename. ':p:t:r' modifies each filename to its
  " trailing part without extension.
  let expand = (a:0 > 0 ? a:1 : ':p:t:r')
  " The pattern used... An empty filename should be regarded as '*'
  let pattern = (a:filename != '' ? a:filename : '*')

  if a:rtp
    let filelist = globpath(&rtp, 'ftplugin/latex-suite/'
	  \ . a:directory . '/' . pattern) . "\n"
  else
    let filelist = globpath(a:directory, pattern)."\n"
  endif

  if filelist == "\n"
    return ''
  endif

  if pattern !~ '\*'
    " If we are not looking for a 'real' pattern, we return the first
    " match.
    return fnamemodify(Tex_Strntok(filelist, "\n", 1), expand)
  endif

  " Now cycle through the files modifying each filename in the desired
  " manner.
  let retfilelist = ''
  let i = 1
  while 1
    " Extract the portion till the next newline. Then shorten the 
    " filelist by removing till the newline.
    let nextnewline = stridx(filelist, "\n")
    if nextnewline == -1
      break
    endif
    let filename = strpart(filelist, 0, nextnewline)
    let filelist = strpart(filelist, nextnewline+1)

    " The actual modification.
    if fnamemodify(filename, expand) != ''
      let retfilelist = retfilelist.fnamemodify(filename, expand)
	    \.","
    endif
    let i = i + 1
  endwhile

  return substitute(retfilelist, ',$', '', '')
endfunction

" }}}
" Tex_FindInRtp: check if file exists in &rtp {{{
" Description:	Wrapper around Tex_FindInDirectory, using a:rtp
function! Tex_FindInRtp(filename, directory, ...)
  return call("Tex_FindInDirectory",
	\ [ a:filename, 1, a:directory ] + a:000 )
endfunction

" }}}
" Tex_GetErrorList: returns vim's clist {{{
" Description: returns the contents of the error list available via the 
"			   :clist command.
function! Tex_GetErrorList()
  let _a = @a
  redir @a | silent! clist | redir END
  let errlist = @a
  call setreg("a", _a, "c")

  if errlist =~ 'E42: '
    let errlist = ''
  endif

  return errlist
endfunction " }}}
" Tex_GetTempName: get the name of a temporary file in specified {{{ 
" directory.
" Description: Unlike vim's native tempname(), this function returns the 
" name of a temporary file in the directory specified. This enables us to 
" create temporary files in a specified directory.
function! Tex_GetTempName(dirname)
  let prefix = 'latexSuiteTemp'
  let slash = (a:dirname =~ '\\$\|/$' ? '' : '/')
  let i = 0
  while filereadable(a:dirname.slash.prefix.i.'.tex') && i < 1000
    let i = i + 1
  endwhile
  if filereadable(a:dirname.slash.prefix.i.'.tex')
    echoerr "Temporary file could not be created in ".a:dirname
    return ''
  endif
  return expand(a:dirname.slash.prefix.i.'.tex', ':p')
endfunction
" }}}
" Tex_MakeMap: creates a mapping from lhs to rhs if rhs is not already {{{
" mapped.
function! Tex_MakeMap(lhs, rhs, mode, extraargs)
  if !hasmapto(a:rhs, a:mode)
    exec a:mode.'map '.a:extraargs.' '.a:lhs.' '.a:rhs
  endif
endfunction " }}}
" Tex_CD: cds to given directory escaping spaces if necessary {{{
function! Tex_CD(dirname)
  exec 'cd '.fnameescape(a:dirname)
endfunction " }}}
" Tex_FindFile: finds a file in the vim's 'path' {{{
function! Tex_FindFile(fname, path, suffixesadd)
  if exists('*findfile')
    let _suffixesadd = &suffixesadd
    let &suffixesadd = a:suffixesadd
    let retval = findfile(a:fname, a:path)
    let &suffixesadd = _suffixesadd
    if retval != ''
      " Convert to full path and return
      return fnamemodify(retval, ':p')
    endif
  else
    " split a new window so we do not screw with the current buffer. We
    " want to use the same filename each time so that multiple scratch
    " buffers are not created.
    let retval = ''
    silent! split __HOPEFULLY_THIS_FILE_DOES_NOT_EXIST__
    let _suffixesadd = &suffixesadd
    let _path = &path
    let &suffixesadd = a:suffixesadd
    let &path = a:path
    exec 'silent! find '.a:fname
    if bufname('%') != '__HOPEFULLY_THIS_FILE_DOES_NOT_EXIST__'
      let retval = expand('%:p')
    endif
    silent! bdelete!
    let &suffixesadd = _suffixesadd
    let &path = _path
  endif
  return retval
endfunction " }}}
" Tex_GetPos: gets position of cursor {{{
function! Tex_GetPos()
  if exists('*getcurpos')
    return getcurpos()
  elseif exists('*getpos')
    return getpos('.')
  else
    return line('.').' | normal! '.virtcol('.').'|'
  endif
endfunction " }}}
" Tex_SetPos: sets position of cursor {{{
function! Tex_SetPos(pos)
  if exists('*setpos')
    call setpos('.', a:pos)
  else
    exec a:pos
  endif
endfunction " }}}
" s:RemoveLastHistoryItem: removes last search item from search history {{{
" Description: Execute this string to clean up the search history.
let s:RemoveLastHistoryItem = ':call histdel("/", -1)'
      \.'|let@/=g:tex_lastSearchPattern'

" }}}
" VEnclose: encloses the visually selected region with given arguments {{{
" Description: allows for differing action based on visual line wise
"              selection or visual characterwise selection. preserves the
"              marks and search history.
function! VEnclose(vstart, vend, VStart, VEnd)
  " it is characterwise if
  " 1. characterwise selection and valid values for vstart and vend.
  " OR
  " 2. linewise selection and invalid values for VStart and VEnd
  if (visualmode() ==# 'v' && (a:vstart != '' || a:vend != ''))
	\ || (a:VStart == '' && a:VEnd == '')

    let newline = ""
    let _r = @r

    let normcmd = "normal! \<C-\>\<C-n>`<v`>\"_s"

    exe "normal! \<C-\>\<C-n>`<v`>\"ry"
    if @r =~ "\n$"
      let newline = "\n"
      let @r = substitute(@r, "\n$", '', '')
    endif

    " In exclusive selection, we need to select an extra character.
    if &selection == 'exclusive'
      let movement = 8
    else
      let movement = 7
    endif
    let normcmd = normcmd.
	  \ a:vstart."!!mark!!".a:vend.newline.
	  \ "\<C-\>\<C-N>?!!mark!!\<CR>v"
	  \ . movement .
	  \ . "l\"_s\<C-r>r\<C-\>\<C-n>"

    " this little if statement is because till very recently, vim used 
    " to report col("'>") > length of selected line when `> is $. on 
    " some systems it reports a -ve number.
    if col("'>") < 0 || col("'>") > strlen(getline("'>"))
      let lastcol = strlen(getline("'>"))
    else
      let lastcol = col("'>")
    endif
    if lastcol - col("'<") != 0
      let len = lastcol - col("'<")
    else
      let len = ''
    endif

    " the next normal! is for restoring the marks.
    let normcmd = normcmd."`<v".len."l\<C-\>\<C-N>"

    " First remember what the search pattern was. 
    " s:RemoveLastHistoryItem
    " will reset @/ to this pattern so we do not create new 
    " highlighting.
    let g:tex_lastSearchPattern = @/

    silent! exe normcmd
    " this is to restore the r register.
    call setreg("r", _r, "c")
    " and finally, this is to restore the search history.
    execute s:RemoveLastHistoryItem

  else

    exec 'normal! `<O'.a:VStart."\<C-\>\<C-n>"
    exec 'normal! `>o'.a:VEnd."\<C-\>\<C-n>"
    if &indentexpr != ''
      silent! normal! `<kV`>j=
    endif
    silent! normal! `>
  endif
endfunction

" }}}
" ExecMap: adds the ability to correct an normal/visual mode mapping.  {{{
" Author: Hari Krishna Dara <hari_vim@yahoo.com>
" Reads a normal mode mapping at the command line and executes it with the
" given prefix. Press <BS> to correct and <Esc> to cancel.
nnoremap <silent> <script> <plug><+SelectRegion+> `<v`>

func! ExecMap(prefix, mode)
  " Temporarily remove the mapping, otherwise it will interfere with the
  " mapcheck call below:
  let myMap = maparg(a:prefix, a:mode)
  exec a:mode."unmap ".a:prefix

  " Generate a line with spaces to clear the previous message.
  let i = 1
  let clearLine = "\r"
  while i < &columns
    let clearLine = clearLine . ' '
    let i = i + 1
  endwhile

  let mapCmd = a:prefix
  let foundMap = 0
  let breakLoop = 0
  echon "\rEnter Map: " . mapCmd
  while !breakLoop
    let char = getchar()
    if char !~ '^\d\+$'
      if char == "\<BS>"
	let mapCmd = s:MultiByteWOLastCharacter(mapCmd)
      endif
    else " It is the ascii code.
      let char = nr2char(char)
      if char == "\<Esc>"
	let breakLoop = 1
      else
	let mapCmd = mapCmd . char
	if maparg(mapCmd, a:mode) != ""
	  let foundMap = 1
	  let breakLoop = 1
	elseif mapcheck(mapCmd, a:mode) == ""
	  let mapCmd = s:MultiByteWOLastCharacter(mapCmd)
	endif
      endif
    endif
    echon clearLine
    echon "\rEnter Map: " . mapCmd
  endwhile
  if foundMap
    if a:mode == 'v'
      " use a plug to select the region instead of using something 
      " like `<v`> to avoid problems caused by some of the characters 
      " in '`<v`>' being mapped.
      let gotoc = "\<plug><+SelectRegion+>"
    else
      let gotoc = ''
    endif
    exec "normal! ".gotoc.mapCmd
  endif
  exec a:mode.'noremap '.a:prefix.' '.myMap
endfunc
" }}}
" s:MultiByteWOLastCharacter: Return string without last multibyte {{{
" character.
func! s:MultiByteWOLastCharacter(str)
  return substitute(a:str, ".$", "", "")
endfunc
" }}}
" =========================================================================
" These functions are used to immitate certain operating system type 
" functions (like reading the contents of a file), which are not available 
" in vim.  For example, in Vim, its not possible to read the contents of a 
" file without opening a buffer on it, which means that over time, lots of 
" buffers can open up needlessly.
"
" If python is available (and allowed), then these functions utilize python
" library functions without making calls to external programs.
" =========================================================================
" Tex_GotoTempFile: open a temp file. reuse from next time on {{{
function! Tex_GotoTempFile()
  if !exists('s:tempFileName')
    let s:tempFileName = tempname()
  endif
  exec 'silent! split '.s:tempFileName
endfunction " }}}
" Tex_IsPresentInFile: finds if a regexp, is present in filename {{{

if executable('awk')

  func! Tex_IsPresentInFile(regex, file)
    let l:awkCmd = "awk "
    let l:awkCmd .= "'BEGIN { ret = 0 } "
    let l:awkCmd .= "/".a:regex."/ "
    let l:awkCmd .= "{ ret = 1; exit } "
    let l:awkCmd .= "END { print ret }' "
    let l:awkCmd .= a:file
    return str2nr(system(l:awkCmd))
  endfunc

elseif Tex_UsePython()
  func! Tex_IsPresentInFile(regexp, filename)
    exec g:tex_pythonCmd . ' isPresentInFile(r"'.a:regexp.'", r"'
	  \.a:filename.'")'

    return retval
  endfunc
else
  func! Tex_IsPresentInFile(regexp, filename)
    call Tex_GotoTempFile()

    silent! 1,$ d _
    let _report = &report
    let _sc = &sc
    set report=9999999 nosc
    exec 'silent! 0r! '.g:tex_catCmd.' '.a:filename
    set nomod
    let &report = _report
    let &sc = _sc

    " Use very magic to digest usual regular expressions.
    if search('\v' . a:regexp, 'w')
      let retval = 1
    else
      let retval = 0
    endif
    silent! bd
    return retval
  endfunc
endif
" }}}
" }}}
" Source vim files. {{{
" source texproject.vim before other files
exe 'source '.fnameescape(s:path.'/texproject.vim')
exe 'source '.fnameescape(s:path.'/texmenuconf.vim')
exe 'source '.fnameescape(s:path.'/envmacros.vim')
exe 'source '.fnameescape(s:path.'/elementmacros.vim')
" source utf-8 or plain math menus
if exists("g:tex_useUtfMenus") && g:tex_useUtfMenus != 0
      \ && has("gui_running")
  exe 'source '.fnameescape(s:path.'/mathmacros-utf.vim')
else
  exe 'source '.fnameescape(s:path.'/mathmacros.vim')
endif
exe 'source '.fnameescape(s:path.'/compiler.vim')
exe 'source '.fnameescape(s:path.'/folding.vim')
exe 'source '.fnameescape(s:path.'/templates.vim')
exe 'source '.fnameescape(s:path.'/custommacros.vim')
exe 'source '.fnameescape(s:path.'/bibtex.vim')
" source advanced math functions
exe 'source '.fnameescape(s:path.'/brackets.vim')
exe 'source '.fnameescape(s:path.'/smartspace.vim')
if g:tex_diacritics != 0
  exe 'source '.fnameescape(s:path.'/diacritics.vim')
endif
exe 'source '.fnameescape(s:path.'/texviewer.vim')
exe 'source '.fnameescape(s:path.'/version.vim')
" }}}
" =========================================================================
" Settings for taglist.vim plugin
" =========================================================================
" Sets Tlist_Ctags_Cmd for taglist.vim and regexps for ctags {{{
if g:tex_tagListSupport
  if !exists("g:tlist_tex_settings")
    let g:tlist_tex_settings = 'tex;s:section;c:chapter;l:label;r:ref'
  endif

  if exists("Tlist_Ctags_Cmd")
    let s:tex_ctags = Tlist_Ctags_Cmd
  else
    let s:tex_ctags = 'ctags' " Configurable in texrc?
  endif

  if g:tex_internalTagDfns == 1
    let Tlist_Ctags_Cmd = s:tex_ctags
	  \." --langdef=tex --langmap=tex:.tex.ltx.latex"
	  \.' --regex-tex="/\\\\begin{abstract}'
	  \.'/Abstract/s,abstract/"'
	  \.' --regex-tex="/\\\\part[ \t]*\*?\{[ \t]*([^}]*)\}/\1/s,part/"'
	  \.' --regex-tex="/\\\\chapter[ \t]*\*?\{[ \t]*([^}]*)\}/\1/s,chapter/"'
	  \.' --regex-tex="/\\\\section[ \t]*\*?\{[ \t]*([^}]*)\}/\1/s,section/"'
	  \.' --regex-tex="/\\\\subsection[ \t]*\*?\{[ \t]*([^}]*)\}/+ \1/s,subsection/"'
	  \.' --regex-tex="/\\\\subsubsection[ \t]*\*?\{[ \t]*([^}]*)\}/+  \1/s,subsubsection/"'
	  \.' --regex-tex="/\\\\paragraph[ \t]*\*?\{[ \t]*([^}]*)\}/+   \1/s,paragraph/"'
	  \.' --regex-tex="/\\\\subparagraph[ \t]*\*?\{[ \t]*([^}]*)\}/+    \1/s,subparagraph/"'
	  \.' --regex-tex="/\\\\begin{thebibliography}/BIBLIOGRAPHY/s,thebibliography/"'
	  \.' --regex-tex="/\\\\tableofcontents/TABLE OF CONTENTS/s,tableofcontents/"'
	  \.' --regex-tex="/\\\\frontmatter/FRONTMATTER/s,frontmatter/"'
	  \.' --regex-tex="/\\\\mainmatter/MAINMATTER/s,mainmatter/"'
	  \.' --regex-tex="/\\\\backmatter/BACKMATTER/s,backmatter/"'
	  \.' --regex-tex="/\\\\appendix/APPENDIX/s,appendix/"'
	  \.' --regex-tex="/\\\\label[ \t]*\*?\{[ \t]*([^}]*)\}/\1/l,label/"'
	  \.' --regex-tex="/\\\\ref[ \t]*\*?\{[ \t]*([^}]*)\}/\1/r,ref/"'
  endif
endif
" }}}

" commands to completion
let g:tex_completion_explorer = ','

