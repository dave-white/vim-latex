"===========================================================================
" 	     File: texproject.vim
"      Author: Mikolaj Machowski
" 	  Version: 1.0 
"     Created: Wen Apr 16 05:00 PM 2003
" 
"  Description: Handling tex projects.
"===========================================================================

" EditProj: Edit project file " {{{
" Description: If project file exists (*.latexmain) open it in window 
" created with ':split', if no create ':new' window and read there project 
" template
func tex#project#EditProj()
  let file = expand("%:p")
  let mainfname = tex#lib#GetMainFileName()
  if glob(mainfname.'.latexmain') != ''
    exec 'split '.fnameescape(mainfname.'.latexmain')
  else
    echohl WarningMsg
    echomsg "Master file not found."
    echomsg "    :help latex-master-file"
    echomsg "for more information"
    echohl None
  endif
endfunc
" }}}
" SourceProj: loads the .latexmain file {{{
" Description: If a *.latexmain file exists, then sources it
func tex#project#SourceProj()
  let l:origdir = fnameescape(getcwd())
  exe 'cd '.fnameescape(expand('%:p:h'))

  if glob(tex#lib#GetMainFileName(':p').'.latexmain') != ''
    if b:tex_debuglvl >= 1
      call tex#lib#debug("tex#project#SourceProj: sourcing ["
	    \.Tex_GetMainFileName().".latexmain]", "proj")
    endif
    exe 'source '.fnameescape(tex#lib#GetMainFileName().'.latexmain')
  endif

  exe 'cd '.l:origdir
endfunc
" }}}

" vim:fdm=marker:ff=unix:noet
