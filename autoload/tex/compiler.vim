"===========================================================================
"	      File: compiler.vim
"  Original Author: Srinath Avadhanula
" Modifications By: David White
"	   Created: Tue Apr 23 05:00 PM 2002 PST
"
"      Description: functions for compiling/viewing/searching latex 
"      documents
"===========================================================================

" == Settings =============================================================
" Script variables {{{
" A list of formats for which need multiple compilations should be done as 
" needed.
let s:multcmplfmts = ["dvi", "pdf"]

let s:fmtdeps_ps = ['dvi']
let s:fmtdeps_pdf = []

let s:idxcmd = 'makeindex "$*.idx"'

let s:bibprg = 'biber'
let s:bibcmd = s:bibprg
if exists('b:tex_outpdir')
  let s:bibcmd .= ' --input-directory="'.b:tex_outpdir.'"'
	       \.' --output-directory="'.b:tex_outpdir.'"'
endif

if has('win32')
  let s:viewprg_ps = 'gsview32'
  let s:viewprg_pdf = 'AcroRd32'
  let s:viewprg_dvi = 'yap -1'
elseif has('osx') || has('macunix')
  " Let the system pick.  If you want, you can override the choice here.
  let s:viewprg_ps = v:null
  let s:viewprg_pdf = v:null
  " let s:viewprg_pdf = 'Acrobat\ Reader\ 5.1'
  let s:viewprg_dvi = v:null
  " Set this to 1 to disable opening a viewer with 'open -a'
  " Note: If you do this, you need to specify viewers above
  let s:macasnix = 0
else
  if executable('xdg-open')
    let s:viewprg_ps = 'xdg-open'
    let s:viewprg_pdf = 'xdg-open'
    let s:viewprg_dvi = 'xdg-open'
  else
    let s:viewprg_ps = 'gv'
    let s:viewprg_pdf = 'xpdf'
    let s:viewprg_dvi = 'xdvi'
  endif
  " the option below specifies an editor for the dvi viewer while starting
  " up the dvi viewer according to Dimitri Antoniou's tip on vim.sf.net 
  " (tip
  " #225)
endif
let s:dvi_viewer_set_editor = 0
" For unix systems or macunix systens with enabled Tex_TreatMacViewerAsUNIX:
" Set this to 1 if you do not want to execute the viewer in the background
let s:fground_viewer = 1

" s:viewrule_* takes precedence over view_prg_* and is executed as is (up 
" to file name substitution).
let s:viewrule_html = 'MozillaFirebird "$*/index.html" &'
let s:viewrule_dvi = v:null

let s:goto_err = 0

" If set to 1, then latex-suite shows the context of the error in a preview
" window beneath the window showing the actual errors.
let s:show_err_cntxt = 0

" Remove temp files created during part compilations when vim exits.
let s:rmv_tmp_files = 1
" }}}

" == External functions ===================================================
" Run: Sets off the compilation process. {{{
func! tex#compiler#Run(...)
  if &makeprg =~ "make"
    let cwd = getcwd()
    call chdir(fnameescape(fnamemodify(fpath, ":p:h")))
    exec 'make!'
    call chdir(cwd)
    redraw!
    return 0
  endif

  if a:0 < 1
    let mainfpath = fnameescape(expand("%:p"))
    let targ = b:tex_targ
  elseif a:0 < 2
    let mainfpath = a:1
    let targ = b:tex_targ
  else
    let mainfpath = a:1
    let targ = a:2
  endif

  if fnamemodify(mainfpath, ":e") != 'tex'
    echo "calling tex#compiler#Run from a non-tex file"
    return 1
  endif

  " let mainbufnr = bufnr(mainfpath)
  " let bufchanged = getbufinfo(mainbufnr)[0]["changed"]
  " if mainbufnr > -1 && bufchanged
  "   let currbufnr = bufnr()
  "   exe string(mainbufnr)."buffer"
  "   let fpath = mainfpath.".tmp"
  "   exe "write ".fpath
  "   let usetmp = 1
  "   exe string(currbufnr)."buffer"
  " else
  "   let usetmp = 0
  "   let fpath = mainfpath
  " endif

  let jobnm = tex#compiler#GetJobNm()
  let outpdir = tex#compiler#GetOutpDir(mainfpath)

  if getftime(mainfpath) <= getftime(outpdir.'/'.jobnm.'.aux')
    " || (!usetmp exists("b:last_cmpl_time") && b:last_cmpl_time)
    echomsg "Nothing to do."
    return 2
  endif

  " first get the dependency chain of this format.
  let depchain = [targ]
  if exists("s:fmtdeps_".targ) && !empty(s:fmtdeps_{targ})
	\ && (index(s:fmtdeps_{targ}, targ) != len(s:fmtdeps_{targ})-1)
    let depchain = extendnew(s:fmtdeps_{targ}, [targ])
  endif

  let cwd = getcwd()
  call chdir(fnameescape(fnamemodify(mainfpath, ":p:h")))

  let err = 0
  let depidx = 0
  while !err && (depidx < len(depchain))
    let depidx += 1
    " let err = s:Compile(fpath, outpdir, jobnm)
    let err = s:Compile(mainfpath, outpdir, jobnm)
  endwhile
  " let b:last_cmpl_time = localtime()
  " if usetmp
  "   call delete(fpath)
  " endif

  call chdir(cwd)
  redraw!
  call Tex_SetupErrorWindow()
  return err
endfunc
" }}}
" View: opens viewer {{{
" Description: opens the DVI viewer for the file being currently edited.
" Again, if the current file is a \input in a master file, see text above
" tex#compiler#Run() to see how to set this information.
func! tex#compiler#View(...)
  if a:0 < 1
    let targ = b:tex_targ
    let viewer = s:viewprg_{targ}
  elseif a:0 < 2
    let targ = a:1
    let viewer = s:viewprg_{targ}
  else
    let targ = a:1
    let viewer = a:2
  endif

  if exists("s:viewrule_".targ) && !empty(s:viewrule_{targ})
    let cmd = substitute(s:viewrule_{targ}, '{v:servername}', v:servername,
	  \ 'g')
  elseif has('win32')
    " unfortunately, yap does not allow the specification of an external
    " editor from the command line. that would have really helped ensure
    " that this particular vim and yap are connected.
    let cmd = 'start '.viewer.' "$*.'.targ.'"'
  elseif (has('osx') || has('macunix')) && !s:macasnix
    let cmd = 'open'
    if !empty(viewer)
      let cmd .= ' -a '.viewer
    endif
    let cmd .= ' $*.'.targ
  else
    " taken from Dimitri Antoniou's tip on vim.sf.net (tip #225).
    " slight change to actually use the current servername instead of
    " hardcoding it as xdvi.
    " Using an option for specifying the editor in the command line
    " because that seems to not work on older bash'es.
    let cmd = viewer
    if targ == 'dvi' && s:dvi_viewer_set_editor
      if !empty(v:servername) && viewer =~ '^ *xdvik\?\( \|$\)'
	let cmd .= ' -editor "gvim --servername '.v:servername
	      \.' --remote-silent +\%l \%f"'
      elseif viewer =~ '^ *kdvi\( \|$\)'
	let cmd .= ' --unique'
      endif
    endif
    let cmd .= ' $*.'.targ
  endif


  let fpath = tex#compiler#GetOutpDir(expand('%:p'))
  if exists("b:tex_jobnm")
    let fpath .= b:tex_jobnm
  else
    let fpath .= expand('%:r')
  endif

  let cmd = substitute(cmd, '\V$*', fpath, 'g')
  if b:tex_debug
    call Tex_Debug("View: cmd = ".cmd, "comp")
  endif

  exec 'silent! !'.cmd

  if !has('gui_running')
    redraw!
  endif
endfunc

" }}}
" SeekFoward: searches for current location in dvi file. {{{
" Description: if the DVI viewer is compatible, then take the viewer to that
"              position in the dvi file. see docs for tex#compiler#Run() to set a
"              master file if this is an \input'ed file.
" Tip: With YAP on Windows, it is possible to do forward and inverse searches
"      on DVI files. to do forward search, you'll have to compile the file
"      with the --src-specials option. then set the following as the command
"      line in the 'view/options/inverse search' dialog box:
"           gvim --servername LATEX --remote-silent +%l "%f"
"      For inverse search, if you are reading this, then just pressing \ls
"      will work.
func tex#compiler#SeekFoward(...)
  if a:0 > 0
    let targ = a:1
  else
    let targ = b:tex_targ
  endif

  if !exists("s:viewprg_".targ) || empty(s:viewprg_{targ})
    echoerr "No viewer set for output file type."
    return
  else
    let viewer = s:viewprg_{targ}
  endif

  let origdir = fnameescape(getcwd())

  let mainfnameRoot = shellescape(fnamemodify(tex#lib#GetMainFileName(), ':t:r'), 1)
  let mainfnameFull = tex#lib#GetMainFileName(':p:r')
  let target_file = shellescape(mainfnameFull . "." . targ, 1)
  let sourcefile = shellescape(expand('%'), 1)
  let sourcefileFull = shellescape(expand('%:p'), 1)
  let linenr = line('.')
  " cd to the location of the file to avoid problems with directory name
  " containing spaces.
  call chdir(fnameescape(tex#lib#GetMainFileName(':p:h')))

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

      if b:tex_UseEditorSettingInDVIViewer &&
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
    if s:fground_viewer
      let execString = execString.' &'
    endif

  endif

  if b:tex_debug
    call Tex_Debug("tex#compiler#SeekFoward: execString = ".execString, "comp")
  endif
  execute execString
  if !has('gui_running')
    redraw!
  endif

  exe 'cd '.origdir
endfunc
" }}}
" PartCompile: compiles selected fragment {{{
" Description: creates a temporary file from the selected fragment of text
"       prepending the preamble and \end{document} and then asks tex#compiler#Run() to
"       compile it.
func! tex#compiler#PartCompile()
  if b:tex_debug
    call Tex_Debug('+PartCompile', 'comp')
  endif

  " Get a temporary file in the same directory as the file from which
  " fragment is being extracted. This is to enable the use of relative path
  " names in the fragment.
  let tmpfile = tex#lib#GetTempName(expand('%:p:h'))

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
  if b:tex_removeTempFiles
    augroup RemoveTmpFiles
      au!
      au VimLeave * :call RmvTmpFiles()
    augroup END
  endif

  " If mainfile exists open it in tiny window and extract preamble there,
  " otherwise do it from current file
  let mainfile = tex#lib#GetMainFileName(":p")
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

  silent! call tex#compiler#Run()
endfunc " }}}

" == External helper functions ============================================
" GetJobNm: Return the pdftex -jobname option value if it is set. {{{
func tex#compiler#GetJobNm()
  if exists('b:tex_jobnm')
    return b:tex_jobnm
  elseif exists('b:tex_main_fxpr')
    return glob(b:tex_main_fxpr)
  else
    return expand('%:r')
  endif
endfunc
" }}}
" GetOutpDir: Return the current output directory for tex file being {{{ 
" built.
func tex#compiler#GetOutpDir(...)
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

  if !empty(b:tex_outpdir)
    let out_dir = fnameescape(fpathHead.'/'.b:tex_outpdir)
    return fnamemodify(out_dir, mod)
  else
    return fnamemodify(fpathHead, mod)
  endif
endfunc
" }}}
" == Internal helper functions ============================================
" ExeCompiler: {{{
func s:ExeCompiler(file, ...)
  if a:0 > 0
    let ignwarnpats = a:1
    if a:0 > 1
      let ignLvl = a:2
    else
      let ignLvl = -1
    endif
  else
    let ignLvl = -1
    let ignwarnpats = []
  endif

  let orig_ignlvl = b:tex_ignlvl
  let orig_ignpats = b:tex_ignwarnpats

  let b:tex_ignwarnpats = extendnew(ignwarnpats, b:tex_ignwarnpats)
  let newIgnLvl = orig_ignlvl
  if ignLvl >= 0
    let newIgnLvl = ignLvl
  else
    let newIgnLvl = len(ignwarnpats)+orig_ignlvl
  endif
  exe "TCLevel ".string(newIgnLvl)

  silent! exe "make! ".a:file

  let b:tex_ignLvl = orig_ignlvl
  let b:tex_ignwarnpats = orig_ignpats

  " If there are any errors, then break from the rest of the steps
  let errLst = tex#lib#GetErrorList()
  if b:tex_debug
    call Tex_Debug("ExeCompiler: errLst = [".errLst."]", "comp")
  endif
  if errLst =~  'error'
    redraw!
    return 1
  endif

  return 0
endfunc
" }}}
" Compile: {{{
func s:Compile(fpath, outpdir, jobnm)
  let auxfile = a:outpdir.'/'.a:jobnm.'.aux'
  let bcffile = a:outpdir.'/'.a:jobnm.'.bcf'
  let bblfile = a:outpdir.'/'.a:jobnm.'.bbl'
  let idxFile = a:outpdir.'/'.a:jobnm.'.idx'

  if !empty(a:outpdir)
    call mkdir(a:outpdir, "p")
  endif

  if has('win32')
    let md5cmd = "Get-FileHash -Algorithm MD5"
  elseif has('osx')
    let md5cmd = "md5 -q"
  else
    let md5cmd = "md5sum"
  endif

  let fname = fnamemodify(a:fpath, ":t")
  " close any preview windows left open.
  pclose!
  " Record the 'state' of auxilliary files before compilation.
  let auxPreHash = system(md5cmd." ".auxfile)
  let idxPreHash = system(md5cmd." ".idxFile)
  let bcfPreHash = system(md5cmd." ".bcffile)

  " Run the composed compiler command
  let err = s:ExeCompiler(fname, [
	\ 'Reference %.%# undefined',
	\ 'Rerun to get cross-references right'
	\ ])
  if err
    return 1
  endif

  let rerun = 0
  let runCnt = 1

  " Run BibLatex 'backend' if *.bcf (BibLatex control file) has changed.
  if bcfPreHash != system(md5cmd." ".bcffile)
    let bblPreHash = system(md5cmd." ".bblfile)

    silent! exec '!'.s:bibcmd.' "'.a:jobnm.'"'
    echomsg "Ran ".s:bibprg

    if system(md5cmd." ".bblfile) != bblPreHash
      let rerun = 1
    endif
  endif

  " Recompile up to four times as necessary.
  while rerun && (runCnt < 5)
    let rerun = 0
    let runCnt += 1

    let err = s:ExeCompiler(fname)
    if err
      let timeWrd = "time"
      if runCnt != 1
	let timeWrd .= "s"
      endif
      echomsg "Ran ".b:tex_cmplprg." ".runCnt." ".timeWrd."."
      return 1
    endif

    let auxPostHash = system(md5cmd." ".auxfile)
    if auxPostHash != auxPreHash
      let rerun = 1
      let auxPreHash = auxPostHash
    endif
  endwhile

  let timeWrd = "time"
  if runCnt != 1
    let timeWrd .= "s"
  endif
  echomsg "Ran ".b:tex_cmplprg." ".runCnt." ".timeWrd."."
endfunc
" }}}

" == Functions for compiling parts of a file.  ============================
" RmvTmpFiles: cleans up temporary files created during part {{{ 
" compilation
" Description: During part compilation, temporary files containing the
"              visually selected text are created. These files need to be
"              removed when Vim exits to avoid "file leakage".
func! RmvTmpFiles()
  if s:rmv_tmp_files && exists('s:tmp_file_cnt')
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
  endif
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
  " Must capture buffer vars before opening the error win (new buf).
  let debug = b:tex_debug

  let mainfname = tex#lib#GetMainFileName()

  let main_winnr = winnr()

  " close the quickfix window before trying to open it again, otherwise
  " whether or not we end up in the quickfix window after the :cwindow
  " command is not fixed.
  cclose
  cwindow
  " create log file name from mainfname
  let mfnlog = fnamemodify(mainfname, ":t:r").'.log'
  if debug
    call Tex_Debug('Tex_SetupErrorWindow: mfnlog = '.mfnlog, 'comp')
  endif
  " if we moved to a different window, then it means we had some errors.
  if main_winnr != winnr()
    if s:show_err_cntxt
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
    if s:goto_err
      call Tex_GotoErrorLocation(mfnlog)
    else
      exec main_winnr.' wincmd w'
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
      if b:tex_debug
	call Tex_Debug("not finding error pattern anywhere in quickfix window :".bufname(bufnr('%'))
      endif,
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

  if !s:show_err_cntxt
    pclose!
  endif
endfunc " }}}

" vim:fdm=marker:ff=unix:noet
