"===========================================================================
" 	     File: custommacros.vim
"      Author: Mikolaj Machowski
" 	  Version: 1.0 
"     Created: Tue Apr 23 05:00 PM 2002 PST
" 
"  Description: functions for processing custom macros in the
"               latex-suite/macros directory
"===========================================================================

let s:macrodir = fnameescape(expand('<sfile>:p:h'))."/macros/"

" }}}
" SetCustomMacrosMenu: sets up the menu for Macros {{{
func! vitex#custmacros#SetCustomMacrosMenu()
  let flist = vitex#lib#FindInRtp('', 'macros')
  exe 'amenu '.b:tex_macroMenuLoc
	\.'&New :call vitex#custmacros#NewMacro("FFFromMMMenu")<CR>'
  exe 'amenu '.b:tex_macroMenuLoc.'&Redraw :call RedrawMacro()<CR>'

  let i = 1
  while 1
    let fname = vitex#lib#Strntok(flist, ',', i)
    if fname == ''
      break
    endif
    exe "amenu ".b:tex_macroMenuLoc."&Delete.&".i.":<tab>".fname
	  \." :call vitex#custmacros#DeleteMacro('".fname."')<CR>"
    exe "amenu ".b:tex_macroMenuLoc."&Edit.&".i.":<tab>".fname
	  \."   :call vitex#custmacros#EditMacro('".fname."')<CR>"
    exe "imenu ".b:tex_macroMenuLoc."&".i.":<tab>".fname
	  \." <C-r>=vitex#custmacros#ReadMacro('".fname."')<CR>"
    exe "nmenu ".b:tex_macroMenuLoc."&".i.":<tab>".fname
	  \." i<C-r>=vitex#custmacros#ReadMacro('".fname."')<CR>"
    let i += 1
  endwhile
endfunc 

" }}}
" NewMacro: opens new file in macros directory {{{
func! vitex#custmacros#NewMacro(...)
  " Allow for calling :TMacroNew without argument or from menu and prompt
  " for name.
  if a:0 > 0
    let newmacroname = a:1
  else
    let newmacroname = input("Name of new macro: ")
    if newmacroname == ''
      return
    endif
  endif

  if newmacroname == "FFFromMMMenu"
    " Check if NewMacro was called from menu and prompt for insert macro
    " name
    let newmacroname = input("Name of new macro: ")
    if newmacroname == ''
      return
    endif
  elseif vitex#lib#FindInRtp(newmacroname, 'macros') != ''
    " If macro with this name already exists, prompt for another name.
    exe "echomsg 'Macro ".newmacroname." already exists. Try another name.'"
    let newmacroname = input("Name of new macro: ")
    if newmacroname == ''
      return
    endif
  endif
  exec 'split '.fnameescape(s:macrodir.newmacroname)
  setlocal filetype=tex
endfunc

" }}}
" RedrawMacro: refreshes macro menu {{{
func! RedrawMacro()
  aunmenu TeX-Suite.Macros
  call s:SetCustomMacrosMenu()
endfunc

" }}}
" ChooseMacro: choose a macro file {{{
" " Description: 
func! s:ChooseMacro(ask)
  let filelist = vitex#lib#FindInRtp('', 'macros')
  let filename = vitex#lib#ChooseFromPrompt(
	\ a:ask."\n" . 
	\ vitex#lib#CreatePrompt(filelist, 2, ',') .
	\ "\nEnter number or filename :",
	\ filelist, ',')
  return filename
endfunc 

" }}}
" DeleteMacro: deletes macro file {{{
func! vitex#custmacros#DeleteMacro(...)
  if a:0 > 0
    let filename = a:1
  else
    let filename = s:ChooseMacro('Choose a macro file for deletion :')
  endif

  if !filereadable(s:macrodir.filename)
    " When file is not in local directory decline to remove it.
    call confirm('This file is not in your local directory: '.filename."\n".
	  \ 'It will not be deleted.' , '&OK', 1)

  else
    let ch = confirm('Really delete '.filename.' ?', "&Yes\n&No", 2)
    if ch == 1
      call delete(s:macrodir.filename)
    endif
    call RedrawMacro()
  endif
endfunc

" }}}
" EditMacro: edits macro file {{{
func! vitex#custmacros#EditMacro(...)
  if a:0 > 0
    let filename = a:1
  else
    let filename = s:ChooseMacro('Choose a macro file to edit:')
  endif

  if filereadable(s:macrodir.filename)
    " If file exists in local directory open it. 
    exec 'split '.fnameescape(s:macrodir.filename)
  else
    " But if file doesn't exist in local dir it probably is in user
    " restricted area. Instead opening try to copy it to local dir.
    " Pity VimL doesn't have mkdir() function :)
    let ch = confirm("You are trying to edit file which is probably read-only.\n".
	  \ "It will be copied to your local LaTeX-Suite macros directory\n".
	  \ "and you will be operating on local copy with suffix -local.\n".
	  \ "It will succeed only if ftplugin/latex-suite/macros dir exists.\n".
	  \ "Do you agree?", "&Yes\n&No", 1)
    if ch == 1
      " But there is possibility we already created local modification.
      " Check it and offer opening this file.
      if filereadable(s:macrodir.filename.'-local')
	let ch = confirm('Local version of '.filename." already exists.\n".
	      \ 'Do you want to open it or overwrite with original version?',
	      \ "&Open\nOver&write\n&Cancel", 1)
	if ch == 1
	  exec 'split '.fnameescape(s:macrodir.filename.'-local')
	elseif ch == 2
	  new
	  exe '0read '.vitex#lib#FindInRtp(filename, 'macros', ':p')
	  " This is possible macro was edited before, wipe it out.
	  if bufexists(s:macrodir.filename.'-local')
	    exe 'bwipe '.s:macrodir.filename.'-local'
	  endif
	  exe 'write! '.s:macrodir.filename.'-local'
	else
	  return
	endif
      else
	" If file doesn't exist, open new file, read in system macro and
	" save it in local macro dir with suffix -local
	new
	exe '0read '.vitex#lib#FindInRtp(filename, 'macros', ':p')
	exe 'write '.s:macrodir.filename.'-local'
      endif
    endif

  endif
  setlocal filetype=tex
endfunc

" }}}
" ReadMacro: reads in a macro from a macro file.  {{{
"            allowing for placement via placeholders.
func! vitex#custmacros#ReadMacro(...)

  if a:0 > 0
    let filename = a:1
  else
    let filename = s:ChooseMacro('Choose a macro file for insertion:')
  endif

  let fname = vitex#lib#FindInRtp(filename, 'macros', ':p')

  let markerString = '<---- Latex Suite End Macro ---->'
  let _a = @a
  silent! call append(line('.'), markerString)
  silent! exec "read ".fname
  silent! exec "normal! V/^".markerString."$/-1\<CR>\"ax"
  " This is kind of tricky: At this stage, we are one line after the one we
  " started from with the marker text on it. We need to
  " 1. remove the marker and the line.
  " 2. get focus to the previous line.
  " 3. not remove anything from the previous line.
  silent! exec "normal! $v0k$\"_x"

  call vitex#viewer#CleanSearchHistory()

  let @a = substitute(@a, '['."\n\r\t ".']*$', '', '')
  let textWithMovement = IMAP_PutTextWithMovement(@a)
  call setreg("a", _a, "c")

  return textWithMovement

endfunc

" }}}
" commands for macros {{{
" This macros had to have 2 versions:
if v:version >= 602 
  " CompleteMacroNm: for completing names in TMacro...  commands {{{
  "	Description: get list of macro names with vitex#lib#FindInRtp(), remove full 
  "	path and return list of names separated with newlines.
  func! vitex#custmacros#CompleteMacroNm(A,P,L)
    " Get name of macros from all runtimepath directories
    let macronames = vitex#lib#FindInRtp('', 'macros')
    " Separate names with \n not ,
    let macronames = substitute(macronames,',','\n','g')
    return macronames
  endfunc
  " }}}
endif
" }}}

" vim:fdm=marker:ff=unix:noet
