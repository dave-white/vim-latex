"            File: tex.vim
"            Type: compiler plugin for LaTeX
" Original Author: Artem Chuprina <ran@ran.pp.ru>
"   Customization: Srinath Avadhanula <srinath@fastmail.fm>
" Description:  {{{
"   This file sets the 'makeprg' and 'errorformat' options for the LaTeX
"   compiler. It is customizable to optionally ignore certain warnings and
"   provides the ability to set a dynamic 'ignore-warning' level.
"
"   By default it is set up in a 'non-verbose', 'ignore-common-warnings' mode,
"   which means that irrelevant lines from the compilers output will be
"   ignored and also some very common warnings are ignored.
"   
"   Depending on the 'ignore-level', the following kinds of messages are
"   ignored. An ignore level of 3 for instance means that messages 1-3 will be
"   ignored. By default, the ignore level is set to 4. 
"
"   1. LaTeX Warning: Specifier 'h' changed to 't'. 
"      This errors occurs when TeX is not able to correctly place a floating
"      object at a specified location, because of which it defaulted to the
"      top of the page.
"   2. LaTeX Warning: Underfull box ...
"   3. LaTeX Warning: Overfull box ...
"      both these warnings (very common) are due to \hbox settings not being
"      satisfied nicely.
"   4. LaTeX Warning: You have requested ..., 
"      This warning occurs in slitex when using the xypic package.
"   5. Missing number error:
"      Usually, when the name of an included eps file is spelled incorrectly,
"      then the \bb-error message is accompanied by a bunch of "missing
"      number, treated as zero" error messages. This level ignores these
"      warnings.
"      NOTE: number 5 is actually a latex error, not a warning!
"
"   Use 
"       TCLevel <level>
"   where level is a number to set the ignore level dynamically.
"
"   When TCLevel is called with the unquoted string strict
"      TClevel strict
"    then the 'efm' switches to a 'verbose', 'no-lines-ignored' mode which is
"    useful when you want to make final checks of your document and want to be
"    careful not to let things slip by.
" 
" TIP: MikTeX has a bug where it sometimes erroneously splits a line number
"      into multiple lines. i.e, if the warning is on line 1234. the compiler
"      output is:
"      LaTeX Warning: ... on input line 123
"      4.
"      In this case, vim will wrongly interpret the line-number as 123 instead
"      of 1234. If you have cygwin, a simple remedy around this is to first
"      copy the file vimlatex (provided) into your $PATH, make sure its
"      executable and then set the variable g:tex_flavor to vimlatex in your
"      ~/.vimrc (i.e putting let "g:tex_flavor = 'vimlatex'" in your .vimrc).
"      This problem occurs rarely enough that its not a botheration for most
"      people.
"
" TODO:
"   1. menu items for dynamically selecting a ignore warning level.
" }}}

if exists('b:suppress_latex_suite') && b:suppress_latex_suite == 1
  finish
endif

" avoid reinclusion for the same buffer. keep it buffer local so it can be
" externally reset in case of emergency re-sourcing.
if exists('b:doneTexCompiler') && !exists('b:forceRedoTexCompiler')
  finish
endif
let b:doneTexCompiler = 1

" ==========================================================================
" Customization of 'efm':  {{{
" This section contains the customization variables which the user can set.
" g:tex_ignWarnPats: This variable contains a ¡ seperated list of
" patterns which will be ignored in the TeX compiler's output. Use this
" carefully, otherwise you might end up losing valuable information.
if !exists('g:tex_ignWarnPats')
  let g:tex_ignWarnPats = [
	\ 'Underfull',
	\ 'Overfull',
	\ 'specifier changed to',
	\ 'You have requested',
	\ 'Missing number, treated as zero.',
	\ 'There were undefined references',
	\ 'Citation %.%# undefined'
	\ ]
endif
" This is the number of warnings in the g:tex_ignWarnPats string which
" will be ignored.
if !exists('g:tex_ignLvl')
  let g:tex_ignLvl = 7
endif
" There will be lots of stuff in a typical compiler output which will
" completely fall through the 'efm' parsing. This options sets whether or 
" not you will be shown those lines.
if !exists('g:tex_ignUnmatched')
  let g:tex_ignUnmatched = 1
endif
" With all this customization, there is a slight risk that you might be 
" ignoring valid warnings or errors. Therefore before getting the final 
" copy of your work, you might want to reset the 'efm' with this variable 
" set to 1.  With that value, all the lines from the compiler are shown 
" irrespective of whether they match the error or warning patterns.
" NOTE: An easier way of resetting the 'efm' to show everything is to do
"       TCLevel strict
if !exists('g:tex_showAllLns')
  let g:tex_showAllLns = 0
endif

" }}}
" ==========================================================================
" Customization of 'makeprg': {{{

" There are several alternate ways in which 'makeprg' is set up. 
"
" Case 1
" ------
" The first is when this file is a part of latex-suite. In this case, a
" variable called g:tex_defaultTargetFormat exists, which gives the default
" format .tex files should be compiled into. In this case, we use the TTarget
" command provided by latex-suite.
"
" Case 2
" ------
" The user is using this file without latex-suite AND he wants to directly
" specify the complete 'makeprg'. Then he should set the g:tex_compileRule_dvi
" variable. This is a string which should be directly be able to be cast into
" &makeprg. An example of one such string is:
"
" 	g:tex_compileRule_dvi = 'pdflatex \\nonstopmode \\input\{$*\}'
"
" NOTE: You will need to escape back-slashes, {'s etc yourself if you are
"       using this file independently of latex-suite.
" TODO: Should we also have a check for backslash escaping here based on
"       platform?
"
" Case 3
" ------
" The use is using this file without latex-suite and he doesnt want any
" customization. In this case, this file makes some intelligent guesses based
" on the platform. If he doesn't want to specify the complete 'makeprg' but
" only the name of the compiler program (for example 'pdflatex' or 'latex'),
" then he sets b:tex_flavor or g:tex_flavor. 

if exists('g:tex_defaultTargetFormat')
  exec 'TTarget '.g:tex_defaultTargetFormat
elseif exists('g:tex_compileRule_dvi')
  let &l:makeprg = g:tex_compileRule_dvi
else
  " If buffer-local variable 'tex_flavor' exists, it defines TeX flavor, 
  " otherwize the same for global variable with same name, else it will be 
  " LaTeX
  if exists("b:tex_flavor")
    let current_compiler = b:tex_flavor
  elseif exists("g:tex_flavor")
    let current_compiler = g:tex_flavor
  else
    let current_compiler = "latex"
  endif
  if has('win32')
    let escChars = ''
  else
    let escChars = '{}\'
  endif
  " Furthermore, if 'win32' is detected, then we want to set the arguments 
  " up so that miktex can handle it.
  if has('win32')
    let options = '--src-specials'
  else
    let options = ''
  endif
  let &l:makeprg = current_compiler . ' ' . options .
	\ escape(' \nonstopmode \input{$*}', escChars)
endif

" }}}
" ==========================================================================
" Functions for setting up a customized 'efm' {{{

" IgnoreWarnings: parses g:tex_ignWarnPats for message customization {{{
" Description: 
func! <SID>IgnoreWarnings()
  let s:Ignored_Overfull = 0

  let i = 0
  while (i < len(g:tex_ignWarnPats)) && (i < g:tex_ignLvl)
    let warningPat = g:tex_ignWarnPats[i]
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
" SetLatexEfm: sets the 'efm' for the latex compiler {{{
" Description: 
func! <SID>SetLatexEfm()

  let pm = ( g:tex_showAllLns == 1 ? '+' : '-' )

  " Add a dummy entry to overwrite the global setting.
  setlocal efm=dummy_value

  if !g:tex_showAllLns
    call s:IgnoreWarnings()
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

  if g:tex_ignUnmatched && !g:tex_showAllLns
    " Ignore all lines which are unmatched so far.
    setlocal efm+=%-G%.%#
    " Sometimes, there is some garbage after a ')'
    setlocal efm+=%-O%.%#
  endif

  " Finally, remove the dummy entry.
  setlocal efm-=dummy_value

endfunc 

" }}}
" Strntok: extract the n^th token from a list {{{
" example: Strntok('1,23,3', ',', 2) = 23
fun! <SID>Strntok(s, tok, n)
  return matchstr( a:s.a:tok[0], '\v(\zs([^'.a:tok.']*)\ze['.a:tok.']){'.a:n.'}')
endfun

" }}}
" SetTexCompilerLevel: sets the "level" for the latex compiler {{{
func! <SID>SetTexCompilerLevel(...)
  if a:0 > 0
    let level = a:1
  else
    call Tex_ResetIncrementNumber(0)
    echo substitute(g:tex_ignWarnPats, 
	  \ '^\|\n\zs\S', '\=Tex_IncrementNumber(1)." ".submatch(0)', 'g')
    let level = input("\nChoose an ignore level: ")
    if level == ''
      return
    endif
  endif
  if level == 'strict'
    let g:tex_showAllLns = 1
  elseif level =~ '^\d\+$'
    let g:tex_showAllLns = 0
    let g:tex_ignLvl = level
  else
    echoerr "SetTexCompilerLevel: Unkwown option [".level."]"
  endif
  call s:SetLatexEfm()
endfunc 

com! -nargs=? TCLevel :call <SID>SetTexCompilerLevel(<f-args>)
" }}}

" }}}
" ==========================================================================

call s:SetLatexEfm()

" Set the errorfile if not already set by somebody else
if &errorfile ==# ''  ||  &errorfile ==# 'errors.err'
  try
    execute 'set errorfile=' . fnameescape(Tex_GetMainFileName(':p:r') . '.log')
  catch
  endtry
endif


if !exists('*Tex_Debug')
  func! Tex_Debug(...)
  endfunc
endif

call Tex_Debug("compiler/tex.vim: sourcing this file", "comp")

" vim:fdm=marker:ff=unix:noet
