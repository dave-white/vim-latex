" vim:ft=vim:fdm=marker

nmap <silent> <script> <plug> i
imap <silent> <script> <C-o><plug> <Nop>

let s:path = expand('<sfile>:p:h')

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

if b:tex_useRunningImap
exe 'source '.s:path.'/imaps.vim'
endif

" Set the mapping leader character symbol.
let s:ml = '<Leader>'

if b:tex_useIMAP " {{{
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
    if !b:tex_smartKeyDot
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
	      \ && !((b:tex_smartKeyDot && l:char == '.')
	      \		|| (b:tex_smartKeyQuote && l:char == '"'))
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
if b:tex_smartKeyQuote

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
  let s:smartBS_pat = Tex_GetVarValue('tex_smartBSPattern')

  func! s:SmartBS_pat()
    return s:smartBS_pat
  endfunc

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
if b:tex_smartKeyDot

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
if b:tex_smartKeyQuote
  inoremap <buffer> <silent> " "<Left><C-R>=<SID>TexQuotes()<CR>
endif
if b:tex_smartKeyBS
  inoremap <buffer> <silent> <BS>
	\ <C-R>=<SID>SmartBS(<SID>SmartBS_pat())<CR>
endif
if b:tex_smartKeyDot
  inoremap <buffer> <silent> . <C-R>=<SID>SmartDots()<CR>
endif

" Mappings defined in package files will overwrite all other
exe 'source '.fnameescape(s:path.'/packages.vim')
