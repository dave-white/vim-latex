" ==========================================================================
" Settings
" ==========================================================================
" Buffer and script variables. {{{
let useIMAP = 0
let useRunningImap = 1
let b:tex_envMaps = 1
let b:tex_envMenus = 1
let b:tex_envEndWithCR = 1
let b:tex_labelAfterContent = 0
let b:tex_itemsWithCR = 0
let b:tex_envLabelPrefix_tab = "tab:"
let b:tex_envLabelPrefix_fig = "fig:"
let b:tex_promptEnvs = [
      \ 'equation*',
      \ 'align*',
      \ 'equation',
      \ 'align',
      \ 'enumerate',
      \ 'itemize',
      \ 'displaymath',
      \ 'figure',
      \ 'table'
      \ ]
let b:tex_promptCmds = [
      \ 'footnote',
      \ 'cite',
      \ 'pageref',
      \ 'label'
      \ ]
let b:tex_smartKeyBS = 1
let smart_bs_pat =
      \ '\(' .
      \ "\\\\[\"^'=v]{\\S}"      . '\|' .
      \ "\\\\[\"^'=]\\S"         . '\|' .
      \ '\\v \S'                 . '\|' .
      \ "\\\\[\"^'=v]{\\\\[iI]}" . '\|' .
      \ '\\v \\[iI]'             . '\|' .
      \ '\\q \S'                 . '\|' .
      \ '\\-'                    .
      \ '\)' . "$"
let smart_quote = 1
let b:tex_smartQuoteOpen = "``"
let b:tex_smartQuoteClose = "''"
let smart_space = 0
let smart_dot = 1
let b:tex_advMath = 0
let b:tex_outlineWinHeight = 15
let b:tex_viewerCwinHeight = 5 
let b:tex_viewerPreviewHeight = 10 
let b:tex_ExplorerHeight = 10
let b:tex_useOutlineCompletion = 1
let b:tex_projSrcFiles = v:null
let b:tex_useSimpleLabelSearch = 0
let b:tex_useCiteCompletionVer2 = 1
let b:tex_bibFieldPrompt =
      \ "Field acronyms: (`:let b:tex_EchoBibFields= 0` to avoid ".
      \ "this message)\n" .
      \ " [t] title         [a] author        [b] booktitle     \n" .
      \ " [j] journal       [y] year          [p] bibtype       \n" .
      \ " (you can also enter the complete field name)    \n"
let b:tex_echoBibFields = 1
let b:tex_useJabref = 0
let b:tex_rememberCiteSearch = 0
let b:tex_BIBINPUTS = v:null
let b:tex_TEXINPUTS = v:null
let b:tex_menus = 0
let b:tex_mainMenuLoc = 80
let b:tex_mathMenus = 1 
let b:tex_nestEltMenus = 1
let b:tex_pkgMenu = 0
let b:tex_nestPkgMenu = 1
let b:tex_menuPrefix = 'TeX-'
let b:tex_useUtfMenus = 0
let b:tex_folding = 1
let b:tex_autoFolding = 1
let b:tex_tagListSupport = 1
let b:tex_internalTagDfns = 1

let b:tex_foldedMisc = 'item,slide,preamble,<<<'
let b:tex_foldedCmds = ''
let b:tex_foldedEnvs = 'verbatim,comment,eq,gather,align,figure,table,'
      \.'thebibliography,keywords,abstract,titlepage'
let b:tex_foldedSecs = 'part,chapter,section,subsection,subsubsection,'
      \.'paragraph'
" }}}

command! -nargs=0 -range=% TPartCompile
      \ :<line1>, <line2> silent! call tex#compiler#PartCompile()
" Setting b:fragmentFile = 1 makes RunLatex consider the present 
" file the _main_ file irrespective of the presence of a .latexmain file.
command! -nargs=0 TCompileThis let b:fragmentFile = 1
command! -nargs=0 TCompileMainFile let b:fragmentFile = 0

nnoremap <Plug>Tex_RefreshFolds :call tex#folding#MakeFolds(1, 1)<cr>
nnoremap <silent> <buffer> <Leader>rf :call tex#folding#MakeFolds(1, 1)<CR>

command! -nargs=0 TProjectEdit :call tex#project#EditProj()

com! -nargs=0 TVersion echo tex#version#GetVersion()

nmap <silent> <script> <plug> i
imap <silent> <script> <C-o><plug> <Nop>

let s:path = expand('<sfile>:p:h')

call tex#project#SourceProj()
exe 'source '.fnameescape(s:path.'/texmenuconf.vim')
if b:tex_envMaps || b:tex_envMenus
  exe 'source '.fnameescape(s:path.'/envmacros.vim')
endif
exe 'source '.fnameescape(s:path.'/elementmacros.vim')
if b:tex_folds
  call tex#folding#SetupFolding()
endif
exe 'source '.fnameescape(s:path.'/templates.vim')
" source advanced math functions
if b:tex_advMath
  exe 'source '.fnameescape(s:path.'/brackets.vim')
endif
if smart_space
  exe 'source '.fnameescape(s:path.'/smartspace.vim')
endif
if b:tex_diacritics
  exe 'source '.fnameescape(s:path.'/diacritics.vim')
endif
exe 'source '.fnameescape(s:path.'/texviewer.vim')
exe 'setlocal dict^='.fnameescape(s:path.'/dictionaries/dictionary')

" ========================================================================
" Mappings
" ========================================================================
" {{{
nnoremap <buffer> <Leader>c :up \| call Tex_Compile()<cr>
vnoremap <buffer> <Leader>c :up \| call Tex_PartCompile()<cr>
nnoremap <buffer> <Leader>v :call Tex_View()<cr>
nnoremap <buffer> <Leader>a :up \| call Tex_Compile()
      \ \| call Tex_View()<cr>
nnoremap <buffer> <Leader>s :call Tex_ForwardSearch()<cr>

if useRunningImap
exe 'source '.s:path.'/imaps.vim'
endif

" Set the mapping leader character symbol.
let s:ml = '<Leader>'

if useIMAP " {{{
  if !exists('s:doneMappings') || s:doneMappings != 1
    let s:doneMappings = 1
    " short forms for latex formatting and math elements. {{{
    " taken from auctex.vim or miktexmacros.vim
    call IMAP ('__', '_{<++>}<++>', "tex")
    call IMAP ('()', '(<++>)<++>', "tex")
    call IMAP ('[]', '[<++>]<++>', "tex")
    call IMAP ('{}', '{<++>}<++>', "tex")
    call IMAP ('^^', '^{<++>}<++>', "tex")
    call IMAP ('$$', '$<++>$<++>', "tex")
    call IMAP ('((', '\left( <++> \right)<++>', "tex")
    call IMAP ('[[', '\left[ <++> \right]<++>', "tex")
    call IMAP ('{{', '\left\{ <++> \right\}<++>', "tex")
    call IMAP ('==', '&= ', "tex")
    call IMAP ('~~', '&\approx ', "tex")
    call IMAP ('=~', '\approx', "tex")
    call IMAP ('::', '\dots', "tex")
    call IMAP ('..', '\dotsc', "tex")
    call IMAP ('**', '\dotsb', "tex")
    call IMAP (b:tex_leader.'^', '\hat{<++>}<++>', "tex")
    call IMAP (b:tex_leader.'_', '\bar{<++>}<++>', "tex")
    call IMAP (b:tex_leader.'6', '\partial', "tex")
    call IMAP (b:tex_leader.'8', '\infty', "tex")
    call IMAP (b:tex_leader.'/', '\frac{<++>}{<++>}<++>', "tex")
    call IMAP (b:tex_leader.'%', '\frac{<++>}{<++>}<++>', "tex")
    call IMAP (b:tex_leader.'@', '\circ', "tex")
    call IMAP (b:tex_leader.'0', '^\circ', "tex")
    call IMAP (b:tex_leader.'=', '\equiv', "tex")
    call IMAP (b:tex_leader."\\",'\setminus', "tex")
    if !smart_dot
      call IMAP (b:tex_leader.'.', '\cdot', "tex")
    endif
    call IMAP (b:tex_leader.'*', '\times', "tex")
    call IMAP (b:tex_leader.'&', '\wedge', "tex")
    call IMAP (b:tex_leader.'-', '\bigcap', "tex")
    call IMAP (b:tex_leader.'+', '\bigcup', "tex")
    call IMAP (b:tex_leader.'M', '\sum_{<++>}^{<++>}<++>', 'tex')
    call IMAP (b:tex_leader.'S', '\sum_{<++>}^{<++>}<++>', 'tex')
    call IMAP (b:tex_leader.'(', '\subset', "tex")
    call IMAP (b:tex_leader.')', '\supset', "tex")
    call IMAP (b:tex_leader.'<', '\le', "tex")
    call IMAP (b:tex_leader.'>', '\ge', "tex")
    call IMAP (b:tex_leader.',', '\nonumber', "tex")
    call IMAP (b:tex_leader.'~', '\tilde{<++>}<++>', "tex")
    call IMAP (b:tex_leader.';', '\dot{<++>}<++>', "tex")
    call IMAP (b:tex_leader.':', '\ddot{<++>}<++>', "tex")
    call IMAP (b:tex_leader.'2', '\sqrt{<++>}<++>', "tex")
    call IMAP (b:tex_leader.'|', '\Big|', "tex")
    call IMAP (b:tex_leader.'I', "\\int_{<++>}^{<++>}<++>", 'tex')
    " }}}
    " Greek Letters {{{
    call IMAP(b:tex_leader.'a', '\alpha', 'tex')
    call IMAP(b:tex_leader.'b', '\beta', 'tex')
    call IMAP(b:tex_leader.'c', '\chi', 'tex')
    call IMAP(b:tex_leader.'d', '\delta', 'tex')
    call IMAP(b:tex_leader.'e', '\varepsilon', 'tex')
    call IMAP(b:tex_leader.'f', '\varphi', 'tex')
    call IMAP(b:tex_leader.'g', '\gamma', 'tex')
    call IMAP(b:tex_leader.'h', '\eta', 'tex')
    call IMAP(b:tex_leader.'i', '\iota', 'tex')
    call IMAP(b:tex_leader.'k', '\kappa', 'tex')
    call IMAP(b:tex_leader.'l', '\lambda', 'tex')
    call IMAP(b:tex_leader.'m', '\mu', 'tex')
    call IMAP(b:tex_leader.'n', '\nu', 'tex')
    call IMAP(b:tex_leader.'o', '\omicron', 'tex')
    call IMAP(b:tex_leader.'p', '\pi', 'tex')
    call IMAP(b:tex_leader.'q', '\theta', 'tex')
    call IMAP(b:tex_leader.'r', '\rho', 'tex')
    call IMAP(b:tex_leader.'s', '\sigma', 'tex')
    call IMAP(b:tex_leader.'t', '\tau', 'tex')
    call IMAP(b:tex_leader.'u', '\upsilon', 'tex')
    call IMAP(b:tex_leader.'v', '\varsigma', 'tex')
    call IMAP(b:tex_leader.'w', '\omega', 'tex')
    call IMAP(b:tex_leader.'x', '\xi', 'tex')
    call IMAP(b:tex_leader.'y', '\psi', 'tex')
    call IMAP(b:tex_leader.'z', '\zeta', 'tex')
    " not all capital greek letters exist in LaTeX!
    " reference: http://www.giss.nasa.gov/latex/ltx-405.html
    " But we still expand all the letters and give choices to users
    call IMAP(b:tex_leader.'A', '\Alpha', 'tex')
    call IMAP(b:tex_leader.'B', '\Beta', 'tex')
    call IMAP(b:tex_leader.'C', '\Chi', 'tex')
    call IMAP(b:tex_leader.'D', '\Delta', 'tex')
    call IMAP(b:tex_leader.'E', '\Varepsilon', 'tex')
    call IMAP(b:tex_leader.'F', '\Varphi', 'tex')
    call IMAP(b:tex_leader.'G', '\Gamma', 'tex')
    call IMAP(b:tex_leader.'H', '\Eta', 'tex')
    call IMAP(b:tex_leader.'I', '\Iota', 'tex')
    call IMAP(b:tex_leader.'K', '\Kappa', 'tex')
    call IMAP(b:tex_leader.'L', '\Lambda', 'tex')
    call IMAP(b:tex_leader.'M', '\Mu', 'tex')
    call IMAP(b:tex_leader.'N', '\Nu', 'tex')
    call IMAP(b:tex_leader.'O', '\Omicron', 'tex')
    call IMAP(b:tex_leader.'P', '\Pi', 'tex')
    call IMAP(b:tex_leader.'Q', '\Theta', 'tex')
    call IMAP(b:tex_leader.'R', '\Rho', 'tex')
    call IMAP(b:tex_leader.'S', '\Sigma', 'tex')
    call IMAP(b:tex_leader.'T', '\Tau', 'tex')
    call IMAP(b:tex_leader.'U', '\Upsilon', 'tex')
    call IMAP(b:tex_leader.'V', '\Varsigma', 'tex')
    call IMAP(b:tex_leader.'W', '\Omega', 'tex')
    call IMAP(b:tex_leader.'X', '\Xi', 'tex')
    call IMAP(b:tex_leader.'Y', '\Psi', 'tex')
    call IMAP(b:tex_leader.'Z', '\Zeta', 'tex')
    " }}}
    " ProtectLetters: sets up identity maps for things like ``a {{{
    " " Description: If we simply do
    " 		call IMAP('`a', '\alpha', 'tex')
    " then we will never be able to type 'a' after a tex-quotation. 
    " Since IMAP() always uses the longest map ending in the letter, 
    " this problem can be avoided by creating a fake map for ``a -> 
    " ``a.  This function sets up fake maps of the following forms:
    " 	``[aA]  -> ``[aA]    (for writing in quotations)
    " 	\`[aA]  -> \`[aA]    (for writing diacritics)
    " 	"`[aA]  -> "`[aA]    (for writing german quotations)
    " It does this for all printable lower ascii characters just to 
    " make sure we dont let anything slip by.
    function! s:ProtectLetters(first, last)
      for i in range(a:first, a:last)
	let l:char = nr2char(i)
	if l:char =~ '[[:print:]]'
	      \ && !((smart_dot && l:char == '.')
	      \		|| (smart_quote && l:char == '"'))
	  call IMAP('``'.l:char, '``'.l:char, 'tex')
	  call IMAP('\`'.l:char, '\`'.l:char, 'tex')
	  call IMAP('"`'.l:char, '"`'.l:char, 'tex')
	endif
      endfor
    endfunction
    call s:ProtectLetters(32, 127)
  endif
  " }}}
  " vmaps: enclose selected region in brackets, environments. The {{{ 
  " action changes depending on whether the selection is character-wise 
  " or line wise. for example, selecting linewise and pressing \v will 
  " result in the region being enclosed in \begin{verbatim}, 
  " \end{verbatim}, whereas in characterise visual mode, the thingie is 
  " enclosed in \verb| and |.
  exec 'xnoremap <silent> '
	\ .b:tex_leader."( \<C-\\>\<C-N>:call "
	\ ."VEnclose('\\left( ', ' \\right)', "
	\ ."'\\left(', '\\right)')\<CR>"
  exec 'xnoremap <silent> '
	\ .b:tex_leader."[ \<C-\\>\<C-N>:call "
	\ ."VEnclose('\\left[ ', ' \\right]', "
	\ ."'\\left[', '\\right]')\<CR>"
  exec 'xnoremap <silent> '
	\ .b:tex_leader."{ \<C-\\>\<C-N>:call "
	\ ."VEnclose('\\left\\{ ', ' \\right\\}', "
	\ ."'\\left\\{', '\\right\\}')\<CR>"
  exec 'xnoremap <silent> '
	\ .b:tex_leader."$ \<C-\\>\<C-N>:call "
	\ ."VEnclose('$', '$', '\\[', '\\]')\<CR>"
  " }}}
  " Infect the current buffer with <buffer>-local imaps for the IMAPs
  call IMAP_infect()
endif
" }}}
" ========================================================================
" Smart key-mappings
" ======================================================================== 
" TexQuotes: inserts `` or '' instead of " {{{
if smart_quote

  " TexQuotes: inserts `` or '' instead of "
  " Taken from texmacro.vim by Benji Fisher <benji@e-math.AMS.org>
  " TODO:  Deal with nested quotes.
  " The :imap that calls this function should insert a ", move the cursor 
  " to the left of that character, then call this with <C-R>= .
  function! s:TexQuotes()
    let l = line(".")
    let c = col(".")
    let restore_cursor = l . "G" . virtcol(".") . "|"
    normal! H
    let restore_cursor = "normal!" . line(".") . "Gzt"
	  \ . restore_cursor
    execute restore_cursor
    " In math mode, or when preceded by a \, just move the cursor past 
    " the
    " already-inserted " character.
    if synIDattr(synID(l, c, 1), "name") =~ "^texMath"
	  \ || (c > 1 && getline(l)[c-2] == '\')
      return "\<Right>"
    endif
    " Find the appropriate open-quote and close-quote strings.
    if exists("b:tex_smartQuoteOpen")
      let open = b:tex_smartQuoteOpen
    elseif exists("b:tex_smartQuoteOpen")
      let open = b:tex_smartQuoteOpen
    else
      let open = "``"
    endif
    if exists("b:tex_smartQuoteClose")
      let close = b:tex_smartQuoteClose
    elseif exists("b:tex_smartQuoteClose")
      let close = b:tex_smartQuoteClose
    else
      let close = "''"
    endif
    let boundary = '\|'
    " This code seems to be obsolete, since this script variable is 
    " never set. The idea is that some languages use ",," as an open-
    " or close-quote string, and we want to avoid confusing ordinary
    " "," with a quote boundary.
    if exists("s:strictQuote")
      if (s:strictQuote == "open"
	    \ || s:strictQuote == "both")
	let boundary = '\<' . boundary
      endif
      if (s:strictQuote == "close"
	    \ || s:strictQuote == "both")
	let boundary = boundary . '\>'
      endif
    endif

    " Eventually return q; set it to the default value now.
    let q = open
    let pattern = escape(open, '\~') .
	  \ boundary .
	  \ escape(close, '\~') .
	  \ '\|^$\|"'

    while 1	" Look for preceding quote (open or close), ignoring
      " math mode and '\"' .
      call search(pattern, "bw")
      if synIDattr(synID(line("."), col("."), 1), "name")
	    \ !~ "^texMath"
	    \ && strpart(getline('.'), col('.')-2, 2) != '\"'
	break
      endif
    endwhile

    " Now, test whether we actually found a _preceding_ quote; if so, 
    " is it an open quote?
    if ( line(".") < l || line(".") == l && col(".") < c )
      if strpart(getline("."), col(".")-1)
	    \ =~ '\V\^' . escape(open, '\')
	if line(".") == l && col(".") + strlen(open) == c
	  " Insert "<++>''<++>" instead of just "''".
	  let q = IMAP_PutTextWithMovement("<++>".close."<++>")
	else
	  let q = close
	endif
      endif
    endif

    " Return to line l, column c:
    execute restore_cursor
    " Start with <Del> to remove the " put in by the :imap .
    return "\<Del>" . q

  endfunction

endif
" }}}
" SmartBS: smart backspacing {{{
if b:tex_smartKeyBS 

  " SmartBS: smart backspacing
  " SmartBS lets you treat diacritic characters (those \'{a} thingies) as 
  " a
  " single character. This is useful for example in the following 
  " situation:
  "
  " \v{s}\v{t}astn\'{y}    ('happy' in Slovak language :-) )
  " If you will delete this normally (without using smartBS() function), 
  " you
  " must press <BS> about 19x. With function smartBS() you must press 
  " <BS> only
  " 7x. Strings like "\v{s}", "\'{y}" are considered like one character 
  " and are
  " deleted with one <BS>.

  " This function comes from Benji Fisher <benji@e-math.AMS.org>
  " http://vim.sourceforge.net/scripts/download.php?src_id=409 
  " (modified/patched by Lubomir Host 'rajo' <host8 AT 
  " keplerDOTfmphDOTuniba.sk>)
  function! s:SmartBS(pat)
    let init = strpart(getline("."), 0, col(".")-1)
    let matchtxt = matchstr(init, a:pat)
    if matchtxt != ''
      let bstxt = substitute(matchtxt, '.', "\<bs>", 'g')
      return bstxt
    else
      return "\<bs>"
    endif
  endfun

endif
" }}}
" SmartDots: inserts \cdots instead of ... in math mode otherwise {{{ 
" \ldots if amsmath package is detected then just use \dots and let amsmath 
" take care of it.
if smart_dot

  func! <SID>SmartDots()
    if strpart(getline('.'), col('.')-3, 2) == '..'
	  \ && b:tex_pkgDetected =~ '\<amsmath\|ellipsis\>'
      return "\<bs>\<bs>\\dots"
    elseif synIDattr(synID(line('.'),col('.')-1,0),"name")
	  \ =~ '^texMath'
	  \ && strpart(getline('.'), col('.')-3, 2) == '..' 
      return "\<bs>\<bs>\\cdots"
    elseif strpart(getline('.'), col('.')-3, 2) == '..'
      return "\<bs>\<bs>\\ldots"
    else
      return '.'
    endif
  endfunc 

endif
" }}}
" smart functions
if smart_quote
  inoremap <buffer> <silent> " "<Left><C-R>=<SID>TexQuotes()<CR>
endif
if b:tex_smartKeyBS
  exe "inoremap <buffer> <silent> <BS>"
	\."<C-R>=<SID>SmartBS(".smart_bs_pat.")<CR>"
endif
if smart_dot
  inoremap <buffer> <silent> . <C-R>=<SID>SmartDots()<CR>
endif

" Mappings defined in package files will overwrite all other
exe 'source '.fnameescape(s:path.'/packages.vim')

" vim:ft=vim:fdm=marker
