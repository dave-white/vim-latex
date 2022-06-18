let vitex#lib#debugflg_brackets = 0x1
let vitex#lib#debugflg_compiler = 0x2
let vitex#lib#debugflg_custmacros = 0x4
let vitex#lib#debugflg_folding = 0x8
let vitex#lib#debugflg_imap = 0x10
let vitex#lib#debugflg_lib = 0x20
let vitex#lib#debugflg_menu = 0x40
let vitex#lib#debugflg_project = 0x80
let vitex#lib#debugflg_smartspace = 0x100
let vitex#lib#debugflg_template = 0x200
let vitex#lib#debugflg_viewer = 0x400
" =========================================================================
" Helper functions for debugging
" =========================================================================
" Debug: appends the argument into s:debugString {{{
" Description: Do not want a memory leak! Set this to zero so that 
" latex-suite always starts out in a non-debugging mode.
func vitex#lib#debug(str, ...)
  if a:0 > 0
    let pattern = a:1
  else
    let pattern = ''
  endif

  " If b:tex_debuglog is given, write debug information into this file 
  " (preferred method); otherwise, save it in a variable.
  if exists("b:tex_debuglog") && !empty(b:tex_debuglog)
    exec 'redir! >> '.b:tex_debuglog
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
endfunc
" }}}
" PrintDebug: prings s:debugString {{{
" Description: 
" 
func vitex#lib#PrintDebug(...)
  if a:0 > 0
    let pattern = a:1
  else
    let pattern = ''
  endif
  if exists('s:debugString_'.pattern)
    echo s:debugString_{pattern}
  endif
endfunc " }}}
" ClearDebug: clears the s:debugString string {{{
" Description: 
" 
func vitex#lib#ClearDebug(...)
  if a:0 > 0
    let pattern = a:1
  else
    let pattern = ''
  endif
  if exists('s:debugString_'.pattern)
    let s:debugString_{pattern} = ''
  endif
endfunc " }}}
" ShowVariableValue: debugging help {{{
" provides a way to examine script local variables from outside the script.
" very handy for debugging.
func vitex#lib#ShowVariableValue(...)
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
endfunc

" }}}
" ========================================================================
" Helper functions for grepping
" ======================================================================== 
" Grep: shorthand for :vimgrep {{{
func vitex#lib#Grep(string, where)
  exec 'silent! vimgrep! /'.a:string.'/ '.a:where
endfunc

" }}}
" Grepadd: shorthand for :vimgrepadd {{{
func vitex#lib#Grepadd(string, where)
  exec 'silent! vimgrepadd! /'.a:string.'/ '.a:where
endfunc

" }}}
" ========================================================================
" Uncategorized helper functions
" ======================================================================== 
" FindFileAbove: Search up the path from current file's directory for {{{ 
" file matching expr.  Return str = absolute path to file matching expr.
func vitex#lib#FindFileAbove(xpr, ...)
  if a:0 < 1
    let curr_dir = fnameescape(expand('%:p:h'))
  else
    let curr_dir = fnameescape(fnamemodify(a:1, ':p:h'))
  endif

  let max_depth = 31
  let last_dir = ""
  let cnt = 0
  while (cnt < max_depth) && (curr_dir != last_dir)
    let cnt += 1
    let fpath = glob(curr_dir.'/'.a:xpr)
    if !empty(fpath)
      return fpath
    else
      let last_dir = curr_dir
      let curr_dir = fnameescape(fnamemodify(curr_dir, ':h'))
    endif
  endwhile
  return ""
endfunc
" }}}
" Strntok: extract the n^th token from a list {{{
" example: Strntok('1,23,3', ',', 2) = 23
func! vitex#lib#Strntok(s, tok, n)
  return matchstr(a:s . a:tok[0], '\v(\zs([^' . a:tok . ']*)\ze['
	\ . a:tok . ']){' . a:n . '}')
endfunc
" }}}
" CountMatches: count number of matches of pat in string {{{
func! vitex#lib#CountMatches( string, pat )
  let pos = 0
  let cnt = 0
  while pos >= 0
    let pos = matchend(a:string, a:pat, pos)
    let cnt = cnt + 1
  endwhile
  " We have counted one match to much
  return cnt - 1
endfunc

" }}}
" CreatePrompt: creates a prompt string {{{
" Description: Arguments:
"     promptList: This is a string of the form:
"         'item1,item2,item3,item4'
"     cols: the number of columns in the resultant prompt
"     sep: the list seperator token
"
" Example:
" CreatePrompt('item1,item2,item3,item4', 2, ',')
" returns
" "(1) item1\t(2)item2\n(3)item3\t(4)item4"
"
" This string can be used in the input() function.
func vitex#lib#CreatePrompt(promptList, cols)
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
" CleanSearchHistory: removes last search item from search history {{{
" Description: This function needs to be globally visible because its
"              called from outside the script during expansion.
func vitex#lib#CleanSearchHistory()
  call histdel("/", -1)
  let @/ = histget("/", -1)
endfunc
nmap <silent> <script> <plug>cleanHistory
      \ :call vitex#lib#CleanSearchHistory()<CR>

" }}}
" GetVarValue: gets the value of the variable {{{
" Description: See if a window-local, buffer-local or global variable with 
" the given name
" 	exists and if so, returns the corresponding value. If none exist, 
" 	return
" 	an empty string.
func vitex#lib#GetVarValue(varname, ...)
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
endfunc " }}}
" GetMainFileName: gets the name of the main file being compiled. {{{
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
func vitex#lib#GetMainFileName(...)
  if a:0 > 0
    let modifier = a:1
  else
    let modifier = ':p'
  endif

  if b:tex_mainfxpr =~ '^\/.*'
    " Absolute path.
    let l:fname = glob(b:tex_mainfxpr)
    if filereadable(l:fname)
      return fnamemodify(l:fname, modifier)
    endif
  else
    " Relative path/name.
    let l:fname = vitex#lib#FindFileAbove(b:tex_mainfxpr)
    if filereadable(l:fname)
      return fnamemodify(l:fname, modifier)
    endif
  endif
endfunc 

" }}}
" ChooseFromPrompt: process a user input to a prompt string {{{
" " Description: 
func vitex#lib#ChooseFromPrompt(dialog, list)
  let inp = input(a:dialog)
  " This is a workaround for a bug(?) in vim, see
  " https://github.com/vim/vim/issues/778
  redraw
  if inp =~ '\d\+'
    return a:list[inp+1]
  else
    return inp
  endif
endfunc
" }}}
" IncrementNumber: returns an incremented number each time {{{
" Description: 
let s:incnum = 0
func vitex#lib#IncrementNumber(increm)
  let s:incnum = s:incnum + a:increm
  return s:incnum
endfunc 

" }}}
" ResetIncrementNumber: increments s:incnum to zero {{{
" Description: 
func vitex#lib#ResetIncrementNumber(val)
  let s:incnum = a:val
endfunc
" }}}
" FindInDirectory: check if file exists in a directory {{{
" Description:	Checks if file exists in globpath(directory, ...) and cuts 
" off the rest of returned names. This guarantees that sourced file is from 
" $HOME.  If the argument a:rtp is set, we interpret a:directory as a 
"subdirectory of &rtp/ftplugin/latex-suite/.  If an optional argument is 
"given, it specifies how to expand each filename found.  For example, '%:p' 
"will return a list of the complete paths to the files. By default returns 
"trailing path-names without extenions.
" NOTE: This function is very slow when a large number of matches are found 
" because of a while loop which modifies each filename found.  Some speedup 
" was acheived by using a tokenizer approach rather than using Strntok 
" which would have been more obvious.
"
func vitex#lib#FindInDirectory(filename, rtp, directory, ...)
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
    return fnamemodify(Strntok(filelist, "\n", 1), expand)
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
endfunc

" }}}
" FindInRtp: check if file exists in &rtp {{{
" Description:	Wrapper around FindInDirectory, using a:rtp
func vitex#lib#FindInRtp(filename, directory, ...)
  return call("vitex#lib#FindInDirectory",
	\ [ a:filename, 1, a:directory ] + a:000 )
endfunc

" }}}
" GetErrorList: returns vim's clist {{{
" Description: returns the contents of the error list available via the 
"			   :clist command.
func vitex#lib#GetErrorList()
  let _a = @a
  redir @a | silent! clist | redir END
  let errlist = @a
  call setreg("a", _a, "c")

  if errlist =~ 'E42: '
    let errlist = ''
  endif

  return errlist
endfunc " }}}
" GetTempName: get the name of a temporary file in specified {{{ 
" directory.
" Description: Unlike vim's native tempname(), this function returns the 
" name of a temporary file in the directory specified. This enables us to 
" create temporary files in a specified directory.
func vitex#lib#GetTempName(dirname)
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
endfunc
" }}}
" FindFile: finds a file in the vim's 'path' {{{
func vitex#lib#FindFile(fname, path, suffixesadd)
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
endfunc " }}}
" GetPos: gets position of cursor {{{
func vitex#lib#GetPos()
  if exists('*getcurpos')
    return getcurpos()
  elseif exists('*getpos')
    return getpos('.')
  else
    return line('.').' | normal! '.virtcol('.').'|'
  endif
endfunc " }}}
" SetPos: sets position of cursor {{{
func vitex#lib#SetPos(pos)
  if exists('*setpos')
    call setpos('.', a:pos)
  else
    exec a:pos
  endif
endfunc " }}}
" s:RemoveLastHistoryItem: removes last search item from search history {{{
" Description: Execute this string to clean up the search history.
let s:RemoveLastHistoryItem = ':call histdel("/", -1)'
      \.'|let@/=b:tex_lastSearchPattern'

" }}}
" VEnclose: encloses the visually selected region with given arguments {{{
" Description: allows for differing action based on visual line wise
"              selection or visual characterwise selection. preserves the
"              marks and search history.
func! VEnclose(vstart, vend, VStart, VEnd)
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
    let b:tex_lastSearchPattern = @/

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
endfunc

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
" GotoTempFile: open a temp file. reuse from next time on {{{
func vitex#lib#GotoTempFile()
  if !exists('s:tempFileName')
    let s:tempFileName = tempname()
  endif
  exec 'silent! split '.s:tempFileName
endfunc " }}}
" FileContains: finds if a regexp, is present in filename {{{

if b:tex_usepython

  func vitex#lib#FileContains(regex, fpath)
    exec b:tex_pythonCmd . ' isPresentInFile(r"'.a:regex.'", r"'
	  \.a:fpath.'")'

    return retval
  endfunc
  
elseif executable('awk')

  func vitex#lib#FileContains(regex, fpath)
    let l:awkCmd = "awk "
    let l:awkCmd .= "'BEGIN { ret = 0 } "
    let l:awkCmd .= "/".a:regex."/ "
    let l:awkCmd .= "{ ret = 1; exit } "
    let l:awkCmd .= "END { print ret }' "
    let l:awkCmd .= a:fpath
    return str2nr(system(l:awkCmd))
  endfunc

else

  func vitex#lib#FileContains(regex, fpath)
    let ln_lst = readfile(a:fpath)
    let idx = 0
    let found = 0
    while (idx < len(ln_lst)) && !found
      let idx += 1
      if ln_lst[idx] =~ a:regex
	found = 1
      endif
    endwhile
    return found
  endfunc

endif
" }}}

" Tex_Version: returns a string which gives the current version number of 
" latex-suite
" Description: Each time a bug fix/addition is done in any source file in 
" latex-suite, not just this file, the number below has to be incremented 
" by the author.  This will ensure that there is a single 'global' version 
" number for all of latex-suite. If a change is done in the doc/ directory, 
" i.e an addition/change in the documentation, then this number should NOT 
" be incremented. Latex-suite will follow a 3-tier system of versioning 
" just as Vim. A version number will be of the form: X.Y.ZZ 'X'	will only 
" be incremented for a major over-haul or feature addition. 'Y'	will be 
" incremented for significant changes which do not qualify as major. 'ZZ'
" will be incremented for bug-fixes and very trivial additions such as 
" adding an option etc. Once ZZ reaches 50, then Y will be incremented and 
" ZZ will be reset to 01. Each time we have a version number of the form 
" X.Y.01, then we'll make a release on vim.sf.net and also create a cvs tag 
" at that point. We'll try to "stabilize" that version by releasing a few 
" pre-releases and then keep that as a stable point.

func vitex#lib#version()
  return "dave-white/vim-latex: version 0.1.0"
endfunc 

" vim:ft=vim:fdm=marker
