"===========================================================================
" 	     File: templates.vim
"      Author: Gergely Kontra
"              (minor modifications by Srinath Avadhanula)
"              (plus other modifications by Mikolaj Machowski) 
" 	  Version: 1.0 
"     Created: Tue Apr 23 05:00 PM 2002 PST
" 
"  Description: functions for handling templates in latex-suite/templates
"               directory.
"===========================================================================

" SetTemplateMenu: sets up the menu for templates {{{
func! tex#template#SetTemplateMenu()
  let flist = s:FindInTemplateDir('')
  let i = 1
  while 1
    let fname = tex#lib#Strntok(flist, ',', i)
    if fname == ''
      break
    endif
    exe "amenu ".b:tex_templateMenuLoc."&".i.":<Tab>".fname." ".
	  \":call s:ReadTemplate('".fname."')<CR>"
    let i = i + 1
  endwhile
endfunc 

" }}}
" ReadTemplate: reads in the template file from the template directory. {{{
func! s:ReadTemplate(...)
  if a:0 > 0
    let filename = a:1
  else
    let filelist = s:FindInTemplateDir('')
    let filename = 
	  \ tex#lib#ChooseFromPrompt("Choose a template file:\n" . 
	  \ tex#lib#Tex_CreatePrompt(filelist, 2, ',') . 
	  \ "\nEnter number or name of file :", 
	  \ filelist, ',')
  endif

  let fname = s:FindInTemplateDir(filename.'.tex', ':p')
  let fname = fnameescape(fname)
  call tex#lib#Debug("0read ".fname, 'templates')

  silent! exe "0read ".fname

  " The first line of the file contains the specifications of what the
  " placeholder characters and the other special characters are.
  let pattern = '\v(\S+)\t(\S+)\t(\S+)\t(\S+)'

  let s:phsTemp = substitute(getline(1), pattern, '\1', '')
  let s:pheTemp = substitute(getline(1), pattern, '\2', '')
  let s:exeTemp = substitute(getline(1), pattern, '\3', '')
  let s:comTemp = substitute(getline(1), pattern, '\4', '')

  0 d_

  call s:ProcessTemplate()
  if exists('*Tex_pack_updateall')
    call Tex_pack_updateall(1)
  endif

  " Do not handle the placeholders here. Let IMAP_PutTextWithMovement do it
  " because it handles UTF-8 character substitutions etc. Therefore delete
  " the text into @a and paste it using IMAP_PutTextWithMovement().
  let _a = @a
  normal! ggVG"ax

  let _formatoptions = &formatoptions
  " Since IMAP_PutTextWithMovement simulates the key-presses, leading
  " indentation can get duplicated in strange ways if ``formatoptions`` is non-empty.
  set formatoptions=

  call tex#lib#Debug("normal! i\<C-r>=IMAP_PutTextWithMovement(@a, '".s:phsTemp."', '".s:pheTemp."')\<CR>", 'templates')
  silent exec "normal! i\<C-r>=IMAP_PutTextWithMovement(@a, '".s:phsTemp."', '".s:pheTemp."')\<CR>"

  let &formatoptions = _formatoptions

  " Restore register a
  call setreg("a", _a, "c")

  call tex#lib#Debug('phs = '.s:phsTemp.', phe = '.s:pheTemp.', exe = '.s:exeTemp.', com = '.s:comTemp, 'templates')

endfunc

" }}}
" FindInTemplateDir: Searches for template files. {{{
" Description:	This function looks for template files either in a custom
" 				directory, or in the latex-suite default directory.
" 				Uses Tex_FindInDirectory().
func! s:FindInTemplateDir(filename, ...)
  " The pattern used... An empty filename should be regarded as '*.tex'
  let pattern = (a:filename != '' ? a:filename : '*.tex')

  if exists("b:tex_customTemplateDirectory") && b:tex_customTemplateDirectory != ''
    return call("tex#lib#FindInDirectory", [pattern, 0, b:tex_customTemplateDirectory] + a:000)
  else
    return call("tex#lib#FindInDirectory", [pattern, 1, 'templates'] + a:000 )
  endif
endfunc
" }}}
" ProcessTemplate: processes the special characters in template file. {{{
"                  This implementation follows from Gergely Kontra's
"                  mu-template.vim
"                  http://vim.sourceforge.net/scripts/script.php?script_id=222
func! s:ProcessTemplate()
  if exists('s:phsTemp') && s:phsTemp != ''

    exec 'silent! %s/^'.s:comTemp.'\(\_.\{-}\)'.s:comTemp.'$/\=s:Compute(submatch(1))/ge'
    exec 'silent! %s/'.s:exeTemp.'\(.\{-}\)'.s:exeTemp.'/\=s:Exec(submatch(1))/ge'
    exec 'silent! g/'.s:comTemp.s:comTemp.'/d'

    " A function only puts one item into the search history...
    call tex#viewer#CleanSearchHistory()
  endif
endfunc

func! s:Exec(what)
  exec 'return '.a:what
endfunc

" Back-Door to trojans !!!
func! s:Compute(what)
  exe a:what
  if exists('s:comTemp')
    return s:comTemp.s:comTemp
  else
    return ''
  endif
endfunc

" }}}
" Command definitions {{{
if v:version >= 602
  " Tex_CompleteTemplateName: for completing names in TTemplate command {{{
  "	Description: get list of template names with FindInTemplateDir(), remove full path
  "	and return list of names separated with newlines.
  "
  func! tex#template#CompleteTemplateName(A,P,L)
    " Get name of macros from all runtimepath directories
    let tmplnames = s:FindInTemplateDir('')
    " Separate names with \n not ,
    let tmplnames = substitute(tmplnames,',','\n','g')
    return tmplnames
  endfunc
  " }}}
endif

" }}}

" vim:fdm=marker:ff=unix:noet
