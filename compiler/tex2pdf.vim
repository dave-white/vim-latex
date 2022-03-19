" == Compiler settings: tex -> pdf ========================================
" MAKEPRG: Set vim &makeprg option. {{{
let b:tex_targ = "pdf"
let b:tex_cmplprg = 'pdflatex'
let b:tex_flavor = 'latex'

let strMkPrg = b:tex_cmplprg
      \.' -file-line-error-style'
      \.' -interaction=nonstopmode'
if exists('b:tex_outpdir') && !empty(b:tex_outpdir)
  let strMkPrg .= ' -output-directory="'.b:tex_outpdir.'"'
endif
if exists('b:tex_jobnm') && !empty(b:tex_jobnm)
  let strMkPrg .= ' -jobname="'.b:tex_jobnm.'"'
endif

exe "CompilerSet makeprg=".escape(strMkPrg, " '\"\\")
" }}}
" ==========================================================================
" Salvage: Need new homes. {{{
let b:tex_compilePrg_dvi = 'latex -interaction=nonstopmode '
      \.'-file-line-error-style "$*"'

let b:tex_escChars = '{}\'

let b:tex_compilePrg_ps = 'dvips -Ppdf -o "$*.ps" "$*.dvi"'

" ways to generate pdf files. there are soo many...
" NOTE: pdflatex generates the same output as latex. therefore quickfix is
"       possible.
" Synctex is now supported by pdflatex.


" let b:tex_CompileRule_pdf = 'ps2pdf "$*.ps"'
" let b:tex_CompileRule_pdf = 'dvipdfm "$*.dvi"'
" let b:tex_CompileRule_pdf = 'dvipdf "$*.dvi"'
let b:tex_CompilePrg_html = 'latex2html "$*.tex"'
" }}}
" ==========================================================================
" Functions for setting up a customized 'efm' {{{
" IgnoreWarnings: parses b:tex_ignwarnpats for message customization {{{
" Description: 
func! <SID>IgnoreWarnings()
  let s:Ignored_Overfull = 0

  let i = 0
  while (i < len(b:tex_ignwarnpats)) && (i < b:tex_ignlvl)
    let warningPat = b:tex_ignwarnpats[i]
    let warningPat = escape(substitute(warningPat, '[\,]', '%\\\\&', 'g'), ' ')

    if warningPat =~? 'overfull'
      let s:Ignored_Overfull = 1
      if ( v:version > 800 || v:version == 800 && has("patch26") )
	" Overfull warnings are ignored as 'warnings'. Therefore, we can gobble
	" some of the following lines with %-C (see below)
	exe 'setlocal efm+=%-W%.%#'.warningPat.'%.%#'
      else
	exe 'setlocal efm+=%-G%.%#'.warningPat.'%.%#'
      endif
    else
      exe 'setlocal efm+=%-G%.%#'.warningPat.'%.%#'
    endif

    let i += 1
  endwhile
endfunc 

" }}}
" SetEfm: sets the 'efm' for the latex compiler {{{
" Description: 
func! <SID>SetEfm()

  let pm = ( b:tex_showAllLns == 1 ? '+' : '-' )

  " Add a dummy entry to overwrite the global setting.
  setlocal efm=dummy_value

  if !b:tex_showAllLns
    call <SID>IgnoreWarnings()
  endif

  setlocal efm+=%E!\ LaTeX\ %trror:\ %m
  setlocal efm+=%E!\ %m
  setlocal efm+=%E%f:%l:\ %m

  " If we do not ignore 'overfull \hbox' messages, we care for them to get the
  " line number.
  if s:Ignored_Overfull == 0
    setlocal efm+=%+WOverfull\ %mat\ lines\ %l--%*\\d
    setlocal efm+=%+WOverfull\ %mat\ line\ %l
  endif

  " Add some generic warnings
  setlocal efm+=%+WLaTeX\ %.%#Warning:\ %.%#line\ %l%.%#
  setlocal efm+=%+W%.%#\ at\ lines\ %l--%*\\d
  setlocal efm+=%+WLaTeX\ %.%#Warning:\ %m
  setlocal efm+=%+WPackage\ %.%#Warning:\ %m

  " 'Overfull \hbox' messages are ended by:
  exec 'setlocal efm+=%'.pm.'Z\ []'

  " Empty line ends multi-line messages
  setlocal efm+=%-Z

  exec 'setlocal efm+=%'.pm.'C(%.%#)\ %#%m\ on\ input\ line\ %l.'
  exec 'setlocal efm+=%'.pm.'C(%.%#)\ %#%m'

  exec 'setlocal efm+=%'.pm.'Cl.%l\ %m'
  exec 'setlocal efm+=%'.pm.'Cl.%l\ '
  exec 'setlocal efm+=%'.pm.'C\ \ %m'
  exec 'setlocal efm+=%'.pm.'C%.%#-%.%#'
  exec 'setlocal efm+=%'.pm.'C%.%#[]%.%#'
  exec 'setlocal efm+=%'.pm.'C[]%.%#'
  exec 'setlocal efm+=%'.pm.'C%.%#%[{}\\]%.%#'
  exec 'setlocal efm+=%'.pm.'C<%.%#>%m'
  exec 'setlocal efm+=%'.pm.'C\ \ %m'
  exec 'setlocal efm+=%'.pm.'GSee\ the\ LaTeX%m'
  exec 'setlocal efm+=%'.pm.'GType\ \ H\ <return>%m'
  exec 'setlocal efm+=%'.pm.'G\ ...%.%#'
  exec 'setlocal efm+=%'.pm.'G%.%#\ (C)\ %.%#'
  exec 'setlocal efm+=%'.pm.'G(see\ the\ transcript%.%#)'
  exec 'setlocal efm+=%'.pm.'G\\s%#'

  " After a 'overfull \hbox' message, there is some garbage from the input.
  " We try to match it, such that parenthesis in this garbage does not
  " confuse the OPQ-patterns below.
  " Every line continues a multiline pattern (hopefully a 'overfull \hbox'
  " message).
  " Due to a bug in old versions of vim, this cannot be used if we ignore the
  " 'overfull \hbox' messages, see vim/vim#1126.
  if s:Ignored_Overfull == 0 || ( v:version > 800 || v:version == 800 && has("patch26") )
    exec 'setlocal efm+=%'.pm.'C%.%#'
  endif

  " Now, we try to trace the used files.
  "
  " In principle, the following combinations could arise in the LaTeX logs:
  "
  " )* \((%f)\)* (%f
  " [Close files, skip some files, open a file]
  "
  " (%f))*
  " [Skip some files, close some files]
  "
  " And you will find many more awkward combinations...
  "
  " Even something like this is possible:
  " [18] [19] [20] (./bla.bbl [21])
  "
  " After a %[OPQ] is matched, the %r part is passed to the same and
  " following patterns. Hence, we have to add many $[OPQ]-patterns.
  "
  " If you use vim to compile your documents, you might want to use
  "     :let $max_print_line=1024
  " such that latex will not wrap the filenames. Otherwise, you could use it
  " as an environment variable or simply use
  "     max_print_line=1024 pdflatex ...
  " in your terminal. If you are using latexmk, you should set
  "     $ENV{'max_print_line'} = '1024';
  "     $log_wrap = $ENV{'max_print_line'};
  " in your ~/.latexmkrc

  " The first pattern is needed to match lines like
  " '[10] [11] (some_file.txt)',
  " where the first number correspond to an output page in the document
  exec 'setlocal efm+=%'.pm.'O[%*\\d]%r'

  " Some close patters
  exec 'setlocal efm+=%'.pm.'Q\ %#)%r'
  exec 'setlocal efm+=%'.pm.'Q\ %#[%\\d%*[^()])%r'
  " The next pattern is needed to match lines like
  " '   ])',
  exec 'setlocal efm+=%'.pm.'Q\ %#])%r'

  " Skip pattern
  exec 'setlocal efm+=%'.pm.'O(%f)%r'

  " Some openings
  exec 'setlocal efm+=%'.pm.'P(%f%r'
  exec 'setlocal efm+=%'.pm.'P%*[^()](%f%r'
  exec 'setlocal efm+=%'.pm.'P(%f%*[^()]'
  exec 'setlocal efm+=%'.pm.'P[%\\d%[^()]%#(%f%r'


  " Now, the sledgehammer to cope with awkward endless combinations (did you
  " ever tried tikz/pgf?)
  " We have to build up the string first, otherwise we cannot append it with
  " '+='.
  let PQO = '%'.pm.'P(%f%r,%'.pm.'Q)%r,%'.pm.'O(%f)%r,%'.pm.'O[%*\\d]%r'
  let PQOs = PQO
  for xxx in range(3)
    let PQOs .= ',' . PQO
  endfor
  exec 'setlocal efm+=' . PQOs

  " Finally, there are some lonely page numbers after all the patterns.
  exec 'setlocal efm+=%'.pm.'O[%*\\d'

  " This gobbles some entries consisting only of whitespace, in fact, it
  " matches the empty line.
  " See https://github.com/vim/vim/issues/807
  exec 'setlocal efm+=%'.pm.'O'

  if b:tex_ignUnmatched && !b:tex_showAllLns
    " Ignore all lines which are unmatched so far.
    setlocal efm+=%-G%.%#
    " Sometimes, there is some garbage after a ')'
    setlocal efm+=%-O%.%#
  endif

  " Finally, remove the dummy entry.
  setlocal efm-=dummy_value

endfunc 
" }}}
" SetTexCompilerLevel: sets the "level" for the latex compiler {{{
func! <SID>SetTexCompilerLevel(...)
  if a:0 > 0
    let level = a:1
  else
    call tex#lib#ResetIncrementNumber(0)
    " echo substitute(b:tex_ignwarnpats, \ '^\|\n\zs\S', 
    " '\=Itex#lib#ncrementNumber(1)." ".submatch(0)', 'g')
    let level = input("\nChoose an ignore level: ")
    if level == ''
      return
    endif
  endif
  if level == 'strict'
    let b:tex_showAllLns = 1
  elseif level =~ '^\d\+$'
    let b:tex_showAllLns = 0
    let b:tex_ignlvl = level
  else
    echoerr "SetTexCompilerLevel: Unkwown option [".level."]"
  endif
  call <SID>SetEfm()
endfunc 

com! -nargs=? TCLevel :call <SID>SetTexCompilerLevel(<f-args>)
" }}}

" }}}
" ==========================================================================
" EFM: Customize efm. {{{
" This section contains the customization variables which the user can set.
" b:tex_ignwarnpats: This variable contains a ¡ seperated list of
" patterns which will be ignored in the TeX compiler's output. Use this
" carefully, otherwise you might end up losing valuable information.
"
" There will be lots of stuff in a typical compiler output which will
" completely fall through the 'efm' parsing. This options sets whether or 
" not you will be shown those lines.
if !exists('b:tex_ignUnmatched')
  let b:tex_ignUnmatched = 1
endif
" With all this customization, there is a slight risk that you might be 
" ignoring valid warnings or errors. Therefore before getting the final 
" copy of your work, you might want to reset the 'efm' with this variable 
" set to 1.  With that value, all the lines from the compiler are shown 
" irrespective of whether they match the error or warning patterns.
" NOTE: An easier way of resetting the 'efm' to show everything is to do
"       TCLevel strict
if !exists('b:tex_showAllLns')
  let b:tex_showAllLns = 0
endif

let b:tex_ignwarnpats = [
      \ 'Underfull',
      \ 'Overfull',
      \ 'specifier changed to',
      \ 'You have requested',
      \ 'Missing number, treated as zero.',
      \ 'There were undefined references',
      \ 'Citation %.%# undefined',
      \ ]

" the 'ignore level' of the 'efm'. A value of 4 says that the first 4 kinds 
" of warnings in the list above will be ignored. Use the command TCLevel to 
" set a level dynamically.
let b:tex_ignlvl = len(b:tex_ignwarnpats)

call <SID>SetEfm()
" }}}
" ==========================================================================
" ERRORFILE: Set the errorfile if not already set by somebody else. {{{
if &errorfile ==# ''  ||  &errorfile ==# 'errors.err'
  try
    execute 'set errorfile='.fnameescape(tex#compiler#GetOutpDir()
	  \.tex#compiler#GetJobName().'.log')
  catch
  endtry
endif
" }}}
" ==========================================================================

" Debugging {{{
if b:tex_debug
  call tex#lib#Debug("compiler/tex.vim: sourcing this file", "comp")
endif
" }}}

" vim:fdm=marker:ff=unix:noet
