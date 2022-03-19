"===========================================================================
" 	     File: folding.vim
"      Author: Srinath Avadhanula
"      		   modifications/additions by Zhang Linbo, Gerd Wachsmuth
"     Created: Tue Apr 23 05:00 PM 2002 PST
" 
"  Description: functions to interact with Syntaxfolds.vim
"===========================================================================

" == External functions ===================================================
" SetupFolding: sets maps for every buffer {{{
" Description: 
func! tex#folding#SetupFolding()
  setlocal foldtext=SetFoldTxt()

  if b:tex_folding
    call tex#folding#MakeFolds(0, 0)
  endif


  " Setup a local autocommand, if FileChangedShellPost is available
  if exists('##FileChangedShellPost')
    augroup LatexSuite
      autocmd FileChangedShellPost <buffer> call tex#folding#MakeFolds(1, 0)
    augroup END
  endif

endfunc
" }}}
" MakeFolds: function to create fold items for latex. {{{
"
" used in conjunction with MakeSyntaxFolds().
" see ../plugin/syntaxFolds.vim for documentation
func! tex#folding#MakeFolds(force, manual)
  " Setup folded items lists b:tex_foldedxxxx
  " 	1. Use default value if b:tex_foldedxxxxxx is not defined
  " 	2. prepend default value to b:tex_foldedxxxxxx if it starts with ','
  " 	3. append default value to b:tex_foldedxxxxxx if it ends with ','

  " Folding items which are not caught in any of the standard commands,
  " environments or sections.
  let s = 'item,slide,preamble,<<<'
  if !exists('b:tex_foldedMisc')
    let b:tex_foldedMisc = s
  elseif b:tex_foldedMisc[0] == ','
    let b:tex_foldedMisc = s . b:tex_foldedMisc
  elseif b:tex_foldedMisc =~ ',$'
    let b:tex_foldedMisc = b:tex_foldedMisc . s
  endif

  " By default do not fold any commands. It looks like trying to fold
  " commands is a difficult problem since commands can be arbitrarily nested
  " and the end patterns are not unique unlike the case of environments.
  " For this to work well, we need a regexp which will match a line only if
  " a command begins on that line but does not end on that line. This
  " requires a regexp which will match unbalanced curly braces and that is
  " apparently not doable with regexps.
  let s = ''
  if !exists('b:tex_foldedCmds')
    let b:tex_foldedCmds = s
  elseif b:tex_foldedCmds[0] == ','
    let b:tex_foldedCmds = s . b:tex_foldedCmds
  elseif b:tex_foldedCmds =~ ',$'
    let b:tex_foldedCmds = b:tex_foldedCmds . s
  endif

  let s = 'verbatim,comment,eq,gather,align,figure,table,thebibliography,'
	\. 'keywords,abstract,titlepage'
  if !exists('b:tex_foldedEnvs')
    let b:tex_foldedEnvs = s
  elseif b:tex_foldedEnvs[0] == ','
    let b:tex_foldedEnvs = s . b:tex_foldedEnvs
  elseif b:tex_foldedEnvs =~ ',$'
    let b:tex_foldedEnvs = b:tex_foldedEnvs . s
  endif

  if !exists('b:tex_foldedSecs')
    let b:tex_foldedSecs = 'part,chapter,section,'
	  \. 'subsection,subsubsection,paragraph'
  endif

  " the order in which these calls are made decides the nestedness. in
  " latex, a table environment will always be embedded in either an item or
  " a section etc. not the other way around. so we first fold up all the
  " tables. and then proceed with the other regions.

  let b:numFoldItems = 0

  " ========================================================================
  " How to add new folding items {{{
  " ========================================================================
  "
  " Each of the following function calls defines a syntax fold region. Each
  " definition consists of a call to the AddSyntaxFoldItem() function.
  " 
  " The order in which the folds are defined is important. Juggling the
  " order of the function calls will create havoc with folding. The
  " "deepest" folding item needs to be called first. For example, if
  " the \begin{table} environment is a subset (or lies within) the \section
  " environment, then add the definition for the \table first.
  "
  " The AddSyntaxFoldItem() function takes either 4 or 6 arguments. When it
  " is called with 4 arguments, it is equivalent to calling it with 6
  " arguments with the last two left blank (i.e as empty strings)
  "
  " The explanation for each argument is as follows:
  "    startpat: a line matching this pattern defines the beginning of a fold.
  "    endpat  : a line matching this pattern defines the end of a fold.
  "    startoff: this is the offset from the starting line at which folding will
  "              actually start
  "    endoff  : like startoff, but gives the offset of the actual fold end from
  "              the line satisfying endpat.
  "              startoff and endoff are necessary when the folding region does
  "              not have a specific end pattern corresponding to a start
  "              pattern. for example in latex,
  "              \begin{section}
  "              defines the beginning of a section, but its not necessary to
  "              have a corresponding
  "              \end{section}
  "              the section is assumed to end 1 line _before_ another section
  "              starts.
  "    startskip: a pattern which defines the beginning of a "skipped" region.
  "
  "               For example, suppose we define a \itemize fold as follows:
  "               startpat =  '^\s*\\item',
  "               endpat = '^\s*\\item\|^\s*\\end{\(enumerate\|itemize\|description\)}',
  "               startoff = 0,
  "               endoff = -1
  "
  "               This defines a fold which starts with a line beginning with an
  "               \item and ending one line before a line beginning with an
  "               \item or \end{enumerate} etc.
  "
  "               Then, as long as \item's are not nested things are fine.
  "               However, once items begin to nest, the fold started by one
  "               \item can end because of an \item in an \itemize
  "               environment within this \item. i.e, the following can happen:
  "
  "               \begin{itemize}
  "               \item Some text <------- fold will start here
  "                     This item will contain a nested item
  "                     \begin{itemize} <----- fold will end here because next line contains \item...
  "                     \item Hello
  "                     \end{itemize} <----- ... instead of here.
  "               \item Next item of the parent itemize
  "               \end{itemize}
  "
  "               Therefore, in order to completely define a folding item which
  "               allows nesting, we need to also define a "skip" pattern.
  "               startskip and end skip do that.
  "               Leave '' when there is no nesting.
  "    endskip: the pattern which defines the end of the "skip" pattern for
  "             nested folds.
  "
  "    Example: 
  "    1. A syntax fold region for a latex section is
  "           startpat = "\\section{"
  "           endpat   = "\\section{"
  "           startoff = 0
  "           endoff   = -1
  "           startskip = ''
  "           endskip = ''
  "    Note that the start and end patterns are thus the same and endoff has a
  "    negative value to capture the effect of a section ending one line before
  "    the next starts.
  "    2. A syntax fold region for the \itemize environment is:
  "           startpat = '^\s*\\item',
  "           endpat = '^\s*\\item\|^\s*\\end{\(enumerate\|itemize\|description\)}',
  "           startoff = 0,
  "           endoff = -1,
  "           startskip = '^\s*\\begin{\(enumerate\|itemize\|description\)}',
  "           endskip = '^\s*\\end{\(enumerate\|itemize\|description\)}'
  "     Note the use of startskip and endskip to allow nesting.
  "
  "
  " }}}
  " ========================================================================

  " {{{ comment lines
  if b:tex_foldedMisc =~ '\<comments\>'
    call AddSyntaxFoldItem (
	  \ '^%\([^%]\|[^f]\|[^a]\|[^k]\|[^e]\)',
	  \ '^[^%]',
	  \ 0,
	  \ -1 
	  \ )
  endif
  " }}}

  " {{{ items
  if b:tex_foldedMisc =~ '\<item\>'
    call AddSyntaxFoldItem (
	  \ '^\s*\\item',
	  \ '^\s*\\item\|^\s*\\end{\(enumerate\|itemize\|description\)}',
	  \ 0,
	  \ -1,
	  \ '^\s*\\begin{\(enumerate\|itemize\|description\)}',
	  \ '^\s*\\end{\(enumerate\|itemize\|description\)}'
	  \ )
  endif
  " }}}

  " {{{ title
  if b:tex_foldedMisc =~ '\<title\>'
    call AddSyntaxFoldItem (
	  \ '^\s*\\title\W',
	  \ '^\s*\\maketitle',
	  \ 0,
	  \ 0
	  \ )
  endif
  " }}}

  " Commands and Environments {{{
  " Fold the commands and environments in 2 passes.
  let pass = 0
  while pass < 2
    if pass == 0
      let lst = b:tex_foldedCmds
    else
      let lst = b:tex_foldedEnvs
    endif
    while lst != ''
      let i = match(lst, ',')
      if i > 0
	let s = strpart(lst, 0, i)
	let lst = strpart(lst, i+1)
      else
	let s = lst
	let lst = ''
      endif
      if s != ''
	if pass == 0
	  " NOTE: This pattern ensures that a command which is
	  " terminated on the same line will not start a fold.
	  " However, it will also refuse to fold certain commands
	  " which have not terminated. eg:
	  " 	\commandname{something \textbf{text} and
	  " will _not_ start a fold.
	  " In other words, the pattern is safe, but not exact.
	  call AddSyntaxFoldItem('^\s*\\'.s.'{[^{}]*$','^[^}]*}',0,0)
	else
	  if s =~ 'itemize\|enumerate\|description'
	    " These environments can nest.
	    call AddSyntaxFoldItem('^\s*\\begin{'.s,'\(^\|\s\)\s*\\end{'
		  \.s,0,0,'^\s*\\begin{'.s,'\(^\|\s\)\s*\\end{'.s)
	  else
	    call AddSyntaxFoldItem('^\s*\\begin{'.s,'\(^\|\s\)\s*\\end{'
		  \.s,0,0,'','')
	  endif
	endif
      endif
    endwhile
    let pass = pass + 1
  endwhile
  " }}}

  " Sections {{{
  if b:tex_foldedSecs != '' 
    call FoldSecs(b:tex_foldedSecs,
	  \ '^\s*\\\%(frontmatter\|mainmatter\|backmatter\)\|'
	  \. '^\s*\\begin{thebibliography\|^\s*\\endinput\|'
	  \. '^\s*\\begin{slide\|^\s*\\\%(begin\|end\){document\|'
	  \. '^\s*\\\%(\%(begin\|end\){appendix}\|appendix\)')
  endif
  " }}} 

  " {{{ slide
  if b:tex_foldedMisc =~ '\<slide\>'
    call AddSyntaxFoldItem (
	  \ '^\s*\\begin{slide',
	  \ '^\s*\\appendix\W\|^\s*\\chapter\W\|^\s*\\end{slide\|^\s*\\end{document',
	  \ 0,
	  \ 0
	  \ )
  endif
  " }}}

  " {{{ preamble
  if b:tex_foldedMisc =~ '\<preamble\>'
    call AddSyntaxFoldItem (
	  \ '^\s*\\document\(class\|style\)\>',
	  \ '^\s*\\begin{document}',
	  \ 0,
	  \ -1 
	  \ )
  endif
  " }}}

  " Manually folded regions {{{
  if b:tex_foldedMisc =~ '\(^\|,\)<<<\(,\|$\)'
    call AddSyntaxFoldItem (
	  \ '<<<',
	  \ '>>>',
	  \ 0,
	  \ 0
	  \ )
  endif
  " }}}

  call MakeSyntaxFolds(a:force)

  " Open all folds if this function was triggered automatically
  " and b:tex_autoFolding is disabled
  if !a:manual && !b:tex_autoFolding
    normal! zR
  endif
endfunc

" }}}
" == Internal helper functions ============================================
" SetFoldTxt: create fold text for folds {{{
function! SetFoldTxt()
  " The dashes indicating the foldlevel together with
  " the number of lines are aligned to width '7'.
  let lines = v:foldend - v:foldstart + 1
  let myfoldtext = repeat('-', v:foldlevel-1) . '+'
	\. repeat(' ', 7-(v:foldlevel-1)-len(lines))
	\. lines . ' lines: '

  " Add some indent per foldlevel
  let myfoldtext .= repeat('> ', v:foldlevel-1)

  if getline(v:foldstart) =~ '^\s*\\begin{'
    let header = matchstr(getline(v:foldstart),
	  \ '^\s*\\begin{\zs\([:alpha:]*\)[^}]*\ze}')
    let title = ''
    let caption = ''
    let label = ''
    let i = v:foldstart
    while i <= v:foldend
      if getline(i) =~ '\\caption'
	" distinguish between
	" \caption{fulldesc} - fulldesc will be displayed
	" \caption[shortdesc]{fulldesc} - shortdesc will be displayed
	if getline(i) =~ '\\caption\['
	  let caption = matchstr(getline(i), '\\caption\[\zs[^\]]*')
	  let caption = substitute(caption, '\zs\]{.*}[^}]*$', '', '')
	else
	  let caption = matchstr(getline(i), '\\caption{\zs.*')
	  let caption = substitute(caption, '\zs}[^}]*$', '', '')
	endif
      elseif getline(i) =~ '\\label'
	let label = matchstr(getline(i), '\\label{\zs.*')
	" :FIXME: this does not work when \label contains a
	" newline or a }-character
	let label = substitute(label, '\([^}]*\)}.*$', '\1', '')
      elseif header =~ 'frame'
	    \ && getline(i) =~ '\\begin{frame}.*{[^{}]*}\|\\frametitle\|%'
	if getline(i) =~ '\\begin{frame}'
	  " The first argument inside {} is the frame title (the
	  " second one is a subtitle)
	  let title = matchstr(getline(i),
		\ '\\begin{frame}.\{-}{\zs[^{}]*\ze}')
	elseif getline(i) =~ '\\frametitle'
	  let title = matchstr(getline(i), '\\frametitle{\zs[^}]*\ze}')
	elseif getline(i) =~ '%' && title == ''
	  let title = substitute(getline(i), '^\(\s\|%\)*', '', '')
	endif
      endif

      let i = i + 1
    endwhile

    if header =~ 'frame'
      if title == ''
	let title = getline(v:foldstart + 1)
      endif
      " Count frames
      let frnum = 0
      for line in getline(1,v:foldstart)
	if line =~ '\\begin{frame}'
	  let frnum=frnum+1
	endif
      endfor
      " Pad with spaces to length 2
      let frnum = repeat(' ', 2-len(frnum)) . frnum
      return myfoldtext.': Frame '.frnum.': '. title
    endif

    " if no caption found, then use the second line.
    if caption == ''
      let caption = getline(v:foldstart + 1)
    endif

    return myfoldtext . header.  ' ('.label.'): '.caption

  elseif getline(v:foldstart) =~ '^\s*%\+[% =-]*$'
    " Useless comment. Use the next line.
    return myfoldtext . getline(v:foldstart+1)
  elseif getline(v:foldstart) =~ '^\s*%%fake'
    " Just strip one '%' from the fakesection.
    return myfoldtext . substitute(getline(v:foldstart),
	  \ '^\s*%%fake', '%', '')
  elseif getline(v:foldstart) =~ '^\s*%'
    " It's any other comment. Use it.
    return myfoldtext . getline(v:foldstart)
  elseif getline(v:foldstart)
	\ =~ '^\s*\\document\(class\|style\).*{'
    " This is the preamble.
    return myfoldtext . 'Preamble: ' . getline(v:foldstart)
  endif

  let section_pattern = substitute(b:tex_foldedSecs,
	\ ',\||', '\\|', 'g')
  let section_pattern = '\\\%('.section_pattern.'\)\>'

  if getline(v:foldstart) =~ '^\s*'.section_pattern
    " This is a section. Search for the content of the mandatory argument {...}
    let type = matchstr(getline(v:foldstart), '^\s*\zs' . section_pattern)
    return myfoldtext.type.s:ParseSecTitle(v:foldstart,
	  \ section_pattern)
  else
    " This is something.
    return myfoldtext . getline(v:foldstart)
  endif
endfunction
" }}}
" FoldSecs: creates section folds {{{
" Description:
" 	This function takes a comma seperated list of "sections" and creates fold
" 	definitions for them. The first item is supposed to be the "shallowest" field
" 	and the last is the "deepest". See b:tex_foldedSecs for the default
" 	definition of the lst input argument.
"
" 	**works recursively**
function! FoldSecs(lst, endpat)
  let i = match(a:lst, ',')
  if i > 0
    let s = strpart(a:lst, 0, i)
  else
    let s = a:lst
  endif
  if s =~ '%%fakesection'
    let s = '^\s*' . s
  else
    let pattern = ''
    let prefix = ''
    for label in split( s, "|" )
      let pattern .= prefix.'\\'.label.'\|'.'%%fake'.label
      let prefix = '\|'
    endfor
    " The line before the pattern could contain a mixture of "% =_" (within 
    " a comment).  The pattern itself is ended by a non-word character "\W" 
    " or a newline.
    let s = '^\%(%[% =-]*\n\)\?\s*'.'\%('.pattern.'\)'.'\%(\W\|\n\)'
  endif
  let endpat = s.'\|'.a:endpat
  if i > 0
    call FoldSecs(strpart(a:lst,i+1), endpat)
  endif
  call AddSyntaxFoldItem(s, endpat, 0, -1)
endfunction
" }}}
" s:ParseSecTitle: create fold text for sections {{{
" Search for the mandatory argument of the \section command and ignore the
" optional argument.
function! s:ParseSecTitle(foldstart, section_pattern)
  let currlinenr = a:foldstart
  let currline = s:StripLn(getline(currlinenr))
  let currlinelen = strlen(currline)

  " Look for the section title after the section macro
  let index = match(currline,
	\ '^\s*'.a:section_pattern.'\zs')

  let maxlines = 10

  " Current depth of nested [] and {}:
  let currdepth = 0
  " Do we have found the mandatory argument?
  " (We are looking for '{' at depth 0)
  let found_mandatory = 0

  let string = ''

  while (currdepth > 0) || !found_mandatory
    if index >= currlinelen
      " Read a new line.
      let maxlines = maxlines - 1
      if maxlines < 0
	return string . ' Scanned too many lines'
      endif
      let currlinenr = currlinenr + 1
      let currline = s:StripLn(getline(currlinenr))
      let currlinelen = strlen(currline)

      let index = 0

      if found_mandatory
	let string .= ' '
      endif
      continue
    endif

    " Look for [] and {} at current position
    if currline[index] =~ '[[{]'
      if(currdepth == 0) && (currline[index] =~ '{')
	let found_mandatory = 1
      endif
      let currdepth += 1
    elseif currline[index] =~ '[]}]'
      let currdepth -= 1
    endif

    " Look for the next interesting character
    let next_index = match( currline, '[{}[\]]',
	  \ index + 1 )
    if next_index == -1
      let next_index = currlinelen + 1
    endif

    " Update the string
    if found_mandatory
      let string .= currline[index:next_index-1]
    endif
    let index = next_index
  endwhile

  return string
endfunction
" }}}
" s:StripLn: strips whitespace and comments {{{
function! s:StripLn( string )
  let string = matchstr( a:string, '^\s*\zs.*$')
  let comment = match( string, '\\\@<!\%(\\\\\)*\zs%')
  if comment > 0
    let string = string[0:comment-1]
  elseif comment == 0
    let string = ''
  endif
  return string
endfunction
" }}}

" vim:fdm=marker:ff=unix:noet
