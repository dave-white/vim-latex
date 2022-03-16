"===========================================================================
"        File: compiler.vim
"      Author: Srinath Avadhanula
"     Created: Tue Apr 23 05:00 PM 2002 PST
"
"  Description: functions for compiling/viewing/searching latex documents
"===========================================================================

" line continuation used here.
let s:save_cpo = &cpo
set cpo&vim

func! Tex_GetJobName(...) " {{{
  if a:0 > 0
    let isForMain = a:1
  else
    let isForMain = 0
  endif

  if !empty(b:tex_jobNm)
    return b:tex_jobNm
  elseif isForMain
    return fnamemodify(Tex_GetMainFileName(), ':r')
  else
    return expand('%:r')
  endif
endfunc
" }}}
func! Tex_GetOutpDir(...) " {{{
  if a:0 < 1
    let fpathHead = expand('%:p:h')
    let mod = ':p'
  elseif a:0 < 2
    let fpathHead = fnamemodify(a:1, ':p:h')
    let mod = ':p'
  else
    let fpathHead = fnamemodify(a:1, ':p:h')
    let mod = a:2
  endif

  if !empty(b:tex_outpDir)
    let out_dir = fnameescape(fpathHead.'/'.b:tex_outpDir)
    return fnamemodify(out_dir, mod)
  else
    return fnamemodify(fpathHead, mod)
  endif
endfunc
" }}}
" Tex_BldCmd: {{{
func! Tex_BldCmd(cmd, optDict)
  let rslt = a:cmd
  for [opt, val] in items(a:optDict)
    let rslt .= ' '.opt
    if strlen(val) > 0
      let rslt .= '="'.val.'"'
    endif
  endfor
  return rslt
endfunc
" }}}
func! Tex_CompileRun(file, cmd, ...)
  if a:0 > 0
    let ignLvl = a:1
    if a:0 > 1
      let ignWarnPats = a:2
    else
      let ignWarnPats = ""
    endif
  else
    let ignLvl = -1
    let ignWarnPats = ""
  endif

  let origLvl = g:tex_ignLvl
  let origPats = g:tex_ignWarnPats

  if !empty(ignWarnPats)
    let g:tex_ignWarnPats .= g:tex_ignWarnPats.ignWarnPats
  endif
  if ignLvl >= 0
    exe "TCLevel ".ignLvl
  endif

  exec "silent! !".a:cmd." ".a:file

  let errLst = Tex_GetErrorList()
  call Tex_Debug("Tex_CompileRun: errLst = [".errLst."]", "comp")
  " If there are any errors, then break from the rest of the steps
  if errLst =~  '\v(error|warning)'
    return 1
  endif

  let g:tex_ignLvl = origLvl
  let g:tex_ignWarnPats = origPats

  return 0
endfunc
" Tex_Compile: compilation function this function runs the latex {{{ 
" command on the currently open file. often times the file being currently 
" edited is only a fragment being \input'ed into some master tex file. in 
" this case, make a file called mainfile.latexmain in the directory 
" containig the file. in other words, if the current file is 
" ~/thesis/chapter.tex so that doing "latex chapter.tex" doesnt make sense, 
" then make a file called main.tex.latexmain in the ~/thesis directory.  
" this will then run "latex main.tex" when Tex_Compile() is called.
func! Tex_Compile(...)
  if a:0 < 1
    let fpath = expand('%:p')
    let mainTarg = b:tex_dfltTarg
  elseif a:0 < 2
    let fpath = a:1
    let mainTarg = b:tex_dfltTarg
  else
    let fpath = a:1
    let mainTarg = a:2
  endif

  if b:tex_useMake
    let cwd = getcwd()
    call chdir(fnameescape(fnamemodify(fpath, ":p:h")))
    exec 'make!'
    call chdir(cwd)
    redraw!
    return 0
  endif

  if fnamemodify(fpath, ":e") != 'tex'
    echo "calling Tex_Compile from a non-tex file"
    return
  endif

  call Tex_Debug("Tex_Run: "
	\."compiling to target [".mainTarg."]", "comp")

  " first get the dependency chain of this format.
  let depChain = [mainTarg]
  if g:tex_fmtDeps_{mainTarg}
    let depChain = extendnew(g:tex_fmtDeps_{mainTarg}, [mainTarg])
  endif

  call Tex_Debug('Tex_Run: '
	\.'getting dependency chain = ['.string(depChain).']', 'comp')

  let cwd = getcwd()
  call chdir(fnameescape(fnamemodify(fpath, ":p:h")))
  let fname = fnamemodify(fpath, ":t")

  if exists('b:tex_outpDir') && strlen(b:tex_outpDir) > 0
    call mkdir(b:tex_outpDir, "p")
  endif

  let jobNm = Tex_GetJobName()
  let outpDir = Tex_GetOutpDir(fpath)
  let auxFile = outpDir.'/'.jobNm.'.aux'
  let bblFile = outpDir.'/'.jobNm.'.bbl'
  let idxFile = outpDir.'/'.jobNm.'.idx'

  if has('win32')
    let md5cmd = "Get-FileHash -Algorithm MD5"
  elseif has('osx')
    let md5cmd = "md5 -q"
  else
    let md5cmd = "md5sum"
  endif

  " now compile to the final target format via each dependency.
  for targ in depChain
    call Tex_Debug('Tex_Run: setting target to '.mainTarg, 'comp')
    " close any preview windows left open.
    pclose!
    " Record the 'state' of auxilliary files before compilation.
    let auxPreHash = system(md5cmd." ".auxFile)
    let idxPreHash = system(md5cmd." ".idxFile)

    " Compose the compiler program with its command line options.
    let compileCmd = Tex_BldCmd(b:tex_compilePrg_{targ},
	  \ b:tex_compilePrgOptDict_{targ})

    " Run the composed compiler command
    " exec "silent! !".compileCmd." ".fname
    let err = Tex_CompileRun(fname, compileCmd, 1000,
	  \ 'Reference %.%# undefined'."\n"
	  \.'Rerun to get cross-references right')

    let rerun = 0
    let runCnt = 1

    " Run biblatex if called for.
    if Tex_IsPresentInFile('\\bibdata|\\abx', auxFile)
      let bblPreHash = system(md5cmd." ".bblFile)
      let bibCmd = Tex_BldCmd(b:tex_bibPrg, b:tex_bibPrgOptDict)
      exec 'silent! !'.bibCmd.' "'.jobNm.'"'
      if system(md5cmd." ".bblFile) != bblPreHash
	let rerun = 1
      endif
    endif

    if b:tex_doMultCompile && (index(g:tex_multCompileFmts, targ) >= 0)
      call confirm(string(rerun), "cont.")
      " Recompile up to four times as necessary.
      while rerun && (runCnt < 5)
	let rerun = 0
	let runCnt += 1
	" exec "silent! !".compileCmd." ".fname
	let err = Tex_CompileRun(fname, compileCmd)
	let auxPostHash = system(md5cmd." ".auxFile)
	if auxPostHash != auxPreHash
	  let rerun = 1
	  let auxPreHash = auxPostHash
	endif
      endwhile
    endif
    call chdir(cwd)
    redraw!

    let timeWrd = "time"
    if runCnt != 1
      let timeWrd .= "s"
    endif
    echomsg "Ran ".b:tex_compilePrg_{targ}." ".runCnt." ".timeWrd
	  \."."

    let errlist = Tex_GetErrorList()
    call Tex_Debug("Tex_Run: errlist = [".errlist."]", "comp")

    " If there are any errors, then break from the rest of the steps
    if errlist =~  '\v(error|warning)'
      call Tex_Debug('Tex_Run: '
	    \.'There were errors in compiling, breaking chain...', 'comp')
      break
    endif
  endfor

  let s:origwinnum = winnr()
  call Tex_SetupErrorWindow()

  call Tex_Debug("-Tex_Run", "comp")
endfunc

" }}}
" Tex_ViewOutp: opens viewer {{{
" Description: opens the DVI viewer for the file being currently edited.
" Again, if the current file is a \input in a master file, see text above
" Tex_Compile() to see how to set this information.
func! Tex_ViewOutp(...)
  if a:0 < 1
    let targ = b:tex_dfltTarg
    let viewer = g:tex_viewPrg_{targ}
  elseif a:0 < 2
    let targ = a:1
    let viewer = g:tex_viewPrg_{targ}
  else
    let targ = a:1
    let viewer = a:2
  endif

  if exists("g:tex_viewPrgComplete_".targ)
   \ && !empty(g:tex_viewPrgComplete_{targ})
    let cmd = substitute(g:tex_viewPrgComplete_{targ},
	  \ '{v:servername}', v:servername, 'g')
  elseif has('win32')
    " unfortunately, yap does not allow the specification of an external
    " editor from the command line. that would have really helped ensure
    " that this particular vim and yap are connected.
    let cmd = 'start '.viewer.' "$*.'.targ.'"'
  elseif (has('osx') || has('macunix')) && !g:tex_treatMacViewerAsUNIX
    if strlen(viewer) > 0
      let appOpt = '-a ' . viewer
    else
      let appOpt = ''
    endif
    let cmd = 'open '.appOpt.' $*.'.targ
  else
    " taken from Dimitri Antoniou's tip on vim.sf.net (tip #225).
    " slight change to actually use the current servername instead of
    " hardcoding it as xdvi.
    " Using an option for specifying the editor in the command line
    " because that seems to not work on older bash'es.
    if targ == 'dvi'
      if g:tex_useEditorSettingInDVIViewer
	if v:servername != '' && viewer =~ '^ *xdvik\?\( \|$\)'
	  let cmd = viewer.' -editor "gvim --servername '.v:servername
		\.' --remote-silent +\%l \%f" $*.dvi'
	elseif \ viewer =~ '^ *kdvi\( \|$\)'
	  let cmd = viewer.' --unique $*.dvi'
	else
	  let cmd = viewer.' $*.dvi'
	endif
      else
	let cmd = viewer.' $*.dvi'
      endif
    else
      let cmd = viewer.' $*.'.targ
    endif
  endif


  let fpath = Tex_GetOutpDir(expand('%:p')).'/'
  if !empty(b:tex_jobNm)
    let fpath .= b:tex_jobNm
  else
    let fpath .= expand('%:r')
  endif

  let cmd = substitute(cmd, '\V$*', fpath, 'g')
  call Tex_Debug("Tex_ViewOutp: cmd = ".cmd, "comp")

  exec 'silent! !'.cmd

  if !has('gui_running')
    redraw!
  endif
endfunc

" }}}
" Tex_ForwardSearchLaTeX: searches for current location in dvi file. {{{
" Description: if the DVI viewer is compatible, then take the viewer to that
"              position in the dvi file. see docs for Tex_Compile() to set a
"              master file if this is an \input'ed file.
" Tip: With YAP on Windows, it is possible to do forward and inverse searches
"      on DVI files. to do forward search, you'll have to compile the file
"      with the --src-specials option. then set the following as the command
"      line in the 'view/options/inverse search' dialog box:
"           gvim --servername LATEX --remote-silent +%l "%f"
"      For inverse search, if you are reading this, then just pressing \ls
"      will work.
func! Tex_ForwardSearchLaTeX(...)
  if &ft != 'tex'
    echo "calling Tex_ForwardSeachLaTeX from a non-tex file"
    return
  endif

  if a:0 > 0
    let targ = a:1
  else
    let targ = b:tex_dfltTarg
  endif

  if empty(g:tex_viewPrg_{targ})
    return
  endif
  let viewer = g:tex_viewPrg_{targ}

  let origdir = fnameescape(getcwd())

  let mainfnameRoot = shellescape(fnamemodify(Tex_GetMainFileName(), ':t:r'), 1)
  let mainfnameFull = Tex_GetMainFileName(':p:r')
  let target_file = shellescape(mainfnameFull . "." . targ, 1)
  let sourcefile = shellescape(expand('%'), 1)
  let sourcefileFull = shellescape(expand('%:p'), 1)
  let linenr = line('.')
  " cd to the location of the file to avoid problems with directory name
  " containing spaces.
  call Tex_CD(Tex_GetMainFileName(':p:h'))

  " inverse search tips taken from Dimitri Antoniou's tip and Benji Fisher's
  " tips on vim.sf.net (vim.sf.net tip #225)
  let execString = 'silent! !'
  if (has('win32'))
    if (viewer =~? '^ *yap\( \|$\)')
      let execString .= 'start '.viewer.' -s '.linenr.sourcefile.' '
	    \.mainfnameRoot

      " SumatraPDF forward search support added by Dieter Castel:
    elseif (viewer =~? "^sumatrapdf")
      " Forward search in sumatra has these arguments (-reuse-instance is optional):
      " SumatraPDF -reuse-instance "pdfPath" -forward-search "texPath" lineNumber
      let execString .= 'start '.viewer.' '.target_file.' -forward-search '
	    \.sourcefileFull.' '.linenr
    endif	

  elseif ((has('osx') || has('macunix'))
	\ && (viewer =~ '\(Skim\|PDFView\|TeXniscope\)'))
    " We're on a Mac using a traditional Mac viewer

    if viewer =~ 'Skim'

      if executable('displayline')
	let execString .= 'displayline '
      else
	let execString .= '/Applications/Skim.app/Contents/SharedSupport/displayline '
      endif
      let execString .= join([linenr, target_file, sourcefileFull])

    elseif viewer =~ 'PDFView'

      let execString .= '/Applications/PDFView.app/Contents/MacOS/gotoline.sh '
      let execString .= join([linenr, target_file, sourcefileFull])

    elseif viewer =~ 'TeXniscope'

      let execString .= '/Applications/TeXniscope.app/Contents/Resources/forward-search.sh '
      let execString .= join([linenr, sourcefileFull, target_file])

    endif

  else
    " We're either UNIX or Mac and using a UNIX-type viewer

    " Check for the special DVI viewers first
    if viewer =~ '^ *\(xdvi\|xdvik\|kdvi\|okular\|zathura\)\( \|$\)'
      let execString .= viewer." "

      if g:tex_UseEditorSettingInDVIViewer &&
	    \ exists('v:servername') &&
	    \ viewer =~ '^ *xdvik\?\( \|$\)'

	let execString .= '-name xdvi -sourceposition "'.linenr.' '
	      \.expand('%').'" -editor "gvim --servername .'
	      \.v:servername.' --remote-silent +\%l \%f" '.target_file

      elseif viewer =~ '^ *kdvi'

	let execString .= '--unique file:'.target_file.'\#src:.'linenr
	      \.sourcefile

      elseif viewer =~ '^ *xdvik\?\( \|$\)'

	let execString .= '-name xdvi -sourceposition "'.linenr.' '
	      \.expand('%').'" '.target_file

      elseif viewer =~ '^ *okular'

	let execString .= '--unique '.target_file.'\#src:'.linenr
	      \.sourcefileFull

      elseif viewer =~ '^ *zathura'

	let execString .= '--synctex-forward '.linenr.':1:.'sourcefileFull
	      \.' '.target_file

      endif

    elseif (viewer == "synctex_wrapper" )
      " Unix + synctex_wrapper
      " You can add a custom script named 'synctex_wrapper' in your $PATH
      " syntax is: synctex_wrapper TARGET_FILE LINE_NUMBER COLUMN_NUMBER SOURCE_FILE
      let execString .= 'synctex_wrapper '.target_file.' '.linenr.' '
	    \.col('.').' '.sourcefile
    else
      " We must be using a generic UNIX viewer
      " syntax is: viewer TARGET_FILE LINE_NUMBER SOURCE_FILE

      let execString .= join([viewer, target_file, linenr, sourcefile])

    endif

    " See if we should add &. On Mac (at least in MacVim), it seems
    " like this should NOT be added...
    if g:tex_execNixViewerInForeground
      let execString = execString.' &'
    endif

  endif

  call Tex_Debug("Tex_ForwardSearchLaTeX: execString = ".execString, "comp")
  execute execString
  if !has('gui_running')
    redraw!
  endif

  exe 'cd '.origdir
endfunc

" }}}

" ==========================================================================
" Functions for compiling parts of a file.
" ==========================================================================
" Tex_PartCompile: compiles selected fragment {{{
" Description: creates a temporary file from the selected fragment of text
"       prepending the preamble and \end{document} and then asks Tex_Compile() to
"       compile it.
func! Tex_PartCompile() range
  call Tex_Debug('+Tex_PartCompile', 'comp')

  " Get a temporary file in the same directory as the file from which
  " fragment is being extracted. This is to enable the use of relative path
  " names in the fragment.
  let tmpfile = Tex_GetTempName(expand('%:p:h'))

  " Remember all the temp files and for each temp file created, remember
  " where the temp file came from.
  let s:tmpFileCnt = (exists('s:tmpFileCnt') ? s:tmpFileCnt + 1 : 1)
  let s:tmpFiles = (exists('s:tmpFiles') ? s:tmpFiles : '')
	\ . tmpfile."\n"
  let s:tmpFile_{s:tmpFileCnt} = tmpfile
  " TODO: For a function Tex_RestoreFragment which restores a temp file to
  "       its original location.
  let s:tmpFileOrig_{s:tmpFileCnt} = expand('%:p')
  let s:tmpFileRange_{s:tmpFileCnt} = a:firstline.','.a:lastline

  " Set up an autocmd to clean up the temp files when Vim exits.
  if g:tex_removeTempFiles
    augroup RemoveTmpFiles
      au!
      au VimLeave * :call Tex_RemoveTempFiles()
    augroup END
  endif

  " If mainfile exists open it in tiny window and extract preamble there,
  " otherwise do it from current file
  let mainfile = Tex_GetMainFileName(":p")
  exe 'bot 1 split '.escape(mainfile, ' ')
  exe '1,/\s*\\begin{document}/w '.tmpfile
  wincmd q

  exe a:firstline.','.a:lastline."w! >> ".tmpfile

  " edit the temporary file
  if exists('drop')
    exec 'drop '.tmpfile
  else
    exec 'tabe '.tmpfile
  endif

  " append the \end{document} line.
  $ put ='\end{document}'
  w

  " set this as a fragment file.
  let b:fragmentFile = 1

  silent! call Tex_Compile()
endfunc " }}}
" Tex_RemoveTempFiles: cleans up temporary files created during part compilation {{{
" Description: During part compilation, temporary files containing the
"              visually selected text are created. These files need to be
"              removed when Vim exits to avoid "file leakage".
func! Tex_RemoveTempFiles()
  if !exists('s:tmpFileCnt') || !g:tex_rmvTmpFiles
    return
  endif
  let i = 1
  while i <= s:tmpFileCnt
    let tmpFile = s:tmpFile_{i}
    " Remove the tmp file and all other associated files such as the
    " .log files etc.
    let rmFileLst = glob(fnamemodify(tmpFile, ':p:r').'.*', 1, 1)
    for file in rmFileLst
      call delete(file)
    endfor
    let i += 1
  endwhile
endfunc " }}}

" ==========================================================================
" Helper functions for
" . viewing the log file in preview mode.
" . syncing the display between the quickfix window and preview window
" . going to the correct line _and column_ number from from the quick fix
"   window.
" ==========================================================================
" Tex_SetupErrorWindow: sets up the cwindow and preview of the .log file {{{
" Description:
func! Tex_SetupErrorWindow()
  let mainfname = Tex_GetMainFileName()

  let winnum = winnr()

  " close the quickfix window before trying to open it again, otherwise
  " whether or not we end up in the quickfix window after the :cwindow
  " command is not fixed.
  cclose
  cwindow
  " create log file name from mainfname
  let mfnlog = fnamemodify(mainfname, ":t:r").'.log'
  call Tex_Debug('Tex_SetupErrorWindow: mfnlog = '.mfnlog, 'comp')
  " if we moved to a different window, then it means we had some errors.
  if winnum != winnr()
    if g:tex_showErrCntxt
      call Tex_UpdatePreviewWindow(mfnlog)
      exe 'nnoremap <buffer> <silent> j j:call Tex_UpdatePreviewWindow("'.mfnlog.'")<CR>'
      exe 'nnoremap <buffer> <silent> k k:call Tex_UpdatePreviewWindow("'.mfnlog.'")<CR>'
      exe 'nnoremap <buffer> <silent> <up> <up>:call Tex_UpdatePreviewWindow("'.mfnlog.'")<CR>'
      exe 'nnoremap <buffer> <silent> <down> <down>:call Tex_UpdatePreviewWindow("'.mfnlog.'")<CR>'
    endif
    exe 'nnoremap <buffer> <silent> <enter> :call Tex_GotoErrorLocation("'.mfnlog.'")<CR>'

    setlocal nowrap

    " resize the window to just fit in with the number of lines.
    exec ( line('$') < 4 ? line('$') : 4 ).' wincmd _'
    if g:tex_gotoErr
      call Tex_GotoErrorLocation(mfnlog)
    else
      exec s:origwinnum.' wincmd w'
    endif
  endif

endfunc " }}}
" Tex_PositionPreviewWindow: positions the preview window correctly. {{{
" Description:
"   The purpose of this function is to count the number of times an error
"   occurs on the same line. or in other words, if the current line is
"   something like |10 error|, then we want to count the number of
"   lines in the quickfix window before this line which also contain lines
"   like |10 error|.
"
func! Tex_PositionPreviewWindow(filename)

  if getline('.') !~ '|\d\+ \(error\|warning\)|'
    if !search('|\d\+ \(error\|warning\)|')
      call Tex_Debug("not finding error pattern anywhere in quickfix window :".bufname(bufnr('%')),
	    \ 'comp')
      pclose!
      return
    endif
  endif

  " extract the error pattern (something like 'file.tex|10 error|') on the
  " current line.
  let errpat = matchstr(getline('.'), '^\f*|\d\+ \(error\|warning\)|\ze')
  let errfile = matchstr(getline('.'), '^\f*\ze|\d\+ \(error\|warning\)|')
  " extract the line number from the error pattern.
  let linenum = matchstr(getline('.'), '|\zs\d\+\ze \(error\|warning\)|')

  " if we are on an error, then count the number of lines before this in the
  " quickfix window with an error on the same line.
  if errpat =~ 'error|$'
    " our location in the quick fix window.
    let errline = line('.')

    " goto the beginning of the quickfix window and begin counting the lines
    " which show an error on the same line.
    0
    let numrep = 0
    while 1
      " if we are on the same kind of error line, then means we have another
      " line containing the same error pattern.
      if getline('.') =~ errpat
	let numrep = numrep + 1
	normal! 0
      endif
      " if we have reached the original location in the quick fix window,
      " then break.
      if line('.') == errline
	break
      else
	" otherwise, search for the next line which contains the same
	" error pattern again. goto the end of the current line so we
	" dont count this line again.
	normal! $
	call search(errpat, 'W')
      endif
    endwhile
  else
    let numrep = 1
  endif

  if getline('.') =~ '|\d\+ warning|'
    let searchpat = escape(matchstr(getline('.'), '|\d\+ warning|\s*\zs.*'), '\ ')
  else
    let searchpat = 'l\.'.linenum
  endif

  " We first need to be in the scope of the correct file in the .log file.
  " This is important for example, when a.tex and b.tex both have errors on
  " line 9 of the file and we want to go to the error of b.tex. Merely
  " searching forward from the beginning of the log file for l.9 will always
  " land us on the error in a.tex.
  if errfile != ''
    exec 'silent! bot pedit +/(\\(\\f\\|\\[\\|\]\\|\\s\\)*'.errfile.'/ '.a:filename
  else
    exec 'bot pedit +0 '.a:filename
  endif
  " Goto the preview window
  " TODO: This is not robust enough. Check that a wincmd j actually takes
  " us to the preview window.
  wincmd j
  " now search forward from this position in the preview window for the
  " numrep^th error of the current line in the quickfix window.
  while numrep > 0
    call search(searchpat, 'W')
    let numrep = numrep - 1
  endwhile
  normal! z.

endfunc " }}}
" Tex_UpdatePreviewWindow: updates the view of the log file {{{
" Description:
"       This function should be called when focus is in a quickfix window.
"       It opens the log file in a preview window and makes it display that
"       part of the log file which corresponds to the error which the user is
"       currently on in the quickfix window. Control returns to the quickfix
"       window when the function returns.
"
func! Tex_UpdatePreviewWindow(filename)
  call Tex_PositionPreviewWindow(a:filename)

  if &previewwindow
    6 wincmd _
    wincmd p
  endif
endfunc " }}}
" Tex_GotoErrorLocation: goes to the correct location of error in the tex file {{{
" Description:
"   This function should be called when focus is in a quickfix window. This
"   function will first open the preview window of the log file (if it is not
"   already open), position the display of the preview to coincide with the
"   current error under the cursor and then take the user to the file in
"   which this error has occured.
"
"   The position is both the correct line number and the column number.
func! Tex_GotoErrorLocation(filename)
  " first use vim's functionality to take us to the location of the error
  " accurate to the line (not column). This lets us go to the correct file
  " without applying any logic.
  exec "normal! \<enter>"
  " If the log file is not found, then going to the correct line number is
  " all we can do.
  if glob(a:filename) == ''
    return
  endif

  let winnum = winnr()
  " then come back to the quickfix window
  wincmd w

  " find out where in the file we had the error.
  let linenum = matchstr(getline('.'), '|\zs\d\+\ze \(warning\|error\)|')
  call Tex_PositionPreviewWindow(a:filename)

  if getline('.') =~ 'l.\d\+'

    let brokenline = matchstr(getline('.'), 'l.'.linenum.' \zs.*\ze')
    " If the line is of the form
    "   l.10 ...and then there was some error
    " it means (most probably) that only part of the erroneous line is
    " shown. In this case, finding the length of the broken line is not
    " correct.  Instead goto the beginning of the line and search forward
    " for the part which is displayed and then go to its end.
    if brokenline =~ '^\M...'
      let partline = matchstr(brokenline, '^\M...\m\zs.*')
      let normcmd = "0/\\V".escape(partline, "\\")."/e+1\<CR>"
    else
      let column = strlen(brokenline) + 1
      let normcmd = column.'|'
    endif

  elseif getline('.') =~ 'LaTeX Warning: \(Citation\|Reference\) `.*'

    let ref = matchstr(getline('.'), "LaTeX Warning: \\(Citation\\|Reference\\) `\\zs[^']\\+\\ze'")
    let normcmd = '0/'.ref."\<CR>"

  else

    let normcmd = '0'

  endif

  " go back to the window where we came from.
  exec winnum.' wincmd w'
  exec 'silent! '.linenum.' | normal! '.normcmd

  if !g:tex_showErrCntxt
    pclose!
  endif
endfunc " }}}
" Tex_SetCompilerMaps: sets maps for compiling/viewing/searching {{{
" Description:
func! <SID>Tex_SetCompilerMaps()
  if exists('b:Tex_doneCompilerMaps')
    return
  endif
  let s:ml = '<Leader>'

  nnoremap <buffer> <Plug>Tex_Compile :up \| call Tex_Compile()<cr>
  xnoremap <buffer> <Plug>Tex_Compile :call Tex_PartCompile()<cr>
  nnoremap <buffer> <Plug>Tex_View :call Tex_ViewOutp()<cr>
  nnoremap <buffer> <Plug>Tex_ForwardSearch :call Tex_ForwardSearchLaTeX()<cr>

  call Tex_MakeMap(s:ml."c", "<Plug>Tex_Compile", 'n', '<buffer>')
  call Tex_MakeMap(s:ml."c", "<Plug>Tex_Compile", 'v', '<buffer>')
  call Tex_MakeMap(s:ml."v", "<Plug>Tex_View", 'n', '<buffer>')
  call Tex_MakeMap(s:ml."a", '<Plug>Tex_Compile \| <Plug>Tex_View', 'n', '<buffer>')
  call Tex_MakeMap(s:ml."s", "<Plug>Tex_ForwardSearch", 'n', '<buffer>')
endfunc
" }}}

augroup LatexSuite
  au LatexSuite User LatexSuiteFileType
   \ call Tex_Debug('compiler.vim: '
		   \.'Catching LatexSuiteFileType event', 'comp')
   \ | call <SID>Tex_SetCompilerMaps()
augroup END

command! -nargs=0 -range=% TPartCompile
      \ :<line1>, <line2> silent! call Tex_PartCompile()
" Setting b:fragmentFile = 1 makes Tex_CompileLatex consider the present file
" the _main_ file irrespective of the presence of a .latexmain file.
command! -nargs=0 TCompileThis let b:fragmentFile = 1
command! -nargs=0 TCompileMainFile let b:fragmentFile = 0

let &cpo = s:save_cpo

" vim:fdm=marker:ff=unix:noet
