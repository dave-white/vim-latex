" HEADER ==================================================================
" vim:ft=vim:fdm=marker:commentstring=\"\ %s:ff=unix
" 	 File: imaps.vim
"      Author: David G. White
"     Created: Sat. 19 Feb. 2022, 14:30 UTC-5
"
" Description: 
"
"        NOTE: This file is best viewed with Vim-6.0+ with folding turned on.
"==========================================================================

let s:runningimap_ldrs = ['\'] ", ';']

" Imap Dictionaries: {{{
" Form: { [ key = macro name, value = expansion text ], ... }
" Description: {{{ Each dictionary has a name of the form 
" `s:imapDict_{nr1}_{nr2}`. Here {nr1} is the UTF-8 / ASCII code for the 
" leader character, and {nr2} that of the triggering keystroke character, 
" to which the pairs `[{macro name}, {macro expansion text}]` in the 
" dictionary are to be associated. (This allows similar / identical macro 
" name patterns to be used with different leader + trigger pairs so that 
" they do not clobber each other.) A particular dictionary is chosen for 
" the expansion text lookup in `func GetRunningImap()` below based on that 
" leader + trigger pair typed by the user. The token checked against the 
" dictionary keys is that text lying between the leader, on the left, and 
" one column left of the cursor position when the trigger was typed.
" }}}

" imap dictionary: \...<cr> {{{
" Leader 92 = '\'
" Trigger 13 = "\<cr>"
let s:imapDict_92_13 = {
    \ "document"     : "\\begin{document}\n<++>\n\\end{document}",
    \ "maketitle"     : "\\maketitle\n<++>",
    \ "title"     : "\\maketitle\n<++>",
    \ "tableofcontents"     : "\\tableofcontents\n<++>",
    \ "toc"     : "\\tableofcontents\n<++>",
    \ "center" : "\\begin{center}\n<++>\n\\end{center}\n<++>",
    \ "figure"
    \ : "\\begin{figure} \\label{fig:<++>}"
    \ . "\n<++>\n\\caption{<++>}\n\\end{figure}\n<++>",
    \ "tikzpicture" : "\\begin{tikzpicture}\n<++>\n\\end{tikzpicture}\n<++>",
    \ "tabular" : "\\begin{tabular}[<++>]{<++>}\n<++>\n\\end{tabular}\n<++>",
    \ "array" : "\\begin{array}{<++>}\n<++>\n\\end{array}\n<++>",
    \ "abstract"     : "\\begin{abstract}\n<++>\n\\end{abstract}\n<++>",
    \ "block"     : "\\block{<++>}{\n<++>\n}\n<++>",
    \ "onslide"     : "\\onslide<<++>-<++>>{<++>}\n<++>",
    \ "*onslide"     : "\\onslide*<<++>-<++>>{<++>}\n<++>",
    \ "displaymath" : "\\begin{displaymath}\n<++>\n\\end{displaymath}\n<++>",
    \ "math" : "\\begin{displaymath}\n<++>\n\\end{displaymath}\n<++>",
    \ "equation"
    \ : "\\begin{equation} \\label{eq:<++>}\n<++>\n\\end{equation}\n<++>",
    \ "*equation" : "\\begin{equation*}\n<++>\n\\end{equation*}\n<++>",
    \ "align"	     : "\\begin{align}\n<++>\n\\end{align}\n<++>",
    \ "*align"    : "\\begin{align*}\n<++>\n\\end{align*}\n<++>",
    \ "enumerate" : "\\begin{enumerate}\n\\item <++>\n\\end{enumerate}\n<++>",
    \ "itemize"	: "\\begin{itemize}\n\\item <++>\n\\end{itemize}\n<++>",
    \ "frame"	     : "\\begin{frame}\n<++>\n\\end{frame}\n<++>",
    \ "theorem"
    \ : "\\begin{theorem}[<++>] \\label{thm:<++>}\n<++>\n\\end{thm}\n<++>",
    \ "thm" : "\\begin{thm}[<++>] \\label{thm:<++>}\n<++>\n\\end{thm}\n<++>",
    \ "athm"
    \ : "\\begin{athm}[<++>] \\label{thm:\theathm}\n<++>\n\\end{thm}\n<++>",
    \ "proposition"
    \ : "\\begin{prop}[<++>] \\label{prop:<++>}\n<++>\n\\end{prop}\n<++>",
    \ "lemma"
    \ : "\\begin{lem}[<++>] \\label{lem:<++>}\n<++>\n\\end{lem}\n<++>",
    \ "corollary"
    \ : "\\begin{cor}[<++>] \\label{cor:<++>}\n<++>\n\\end{cor}\n<++>",
    \ "definition"
    \ : "\\begin{defn}[<++>] \\label{def:<++>}\n<++>\n\\end{defn}\n<++>",
    \ "example"
    \ : "\\begin{exm}[<++>] \\label{exm:<++>}\n<++>\n\\end{exm}\n<++>",
    \ "problem"
    \ : "\\begin{prob}[<++>] \\label{prob:<++>}\n<++>\n\\end{prob}\n<++>",
    \ "remark"
    \ : "\\begin{rem}[<++>] \\label{rem:<++>}\n<++>\n\\end{rem}\n<++>",
    \ "observation"
    \ : "\\begin{obs}[<++>] \\label{obs:<++>}\n<++>\n\\end{obs}\n<++>",
    \ "note"
    \ : "\\begin{note}[<++>] \\label{note:<++>}\n<++>\n\\end{note}\n<++>",
    \ "proof"    : "\\begin{proof}\n<++>\n\\end{proof}\n<++>",
    \ }
" }}}

" imap dictionary: \...<tab> {{{
" Leader 92 = '\'
" Trigger 9 = "\<tab>"
let s:imapDict_92_9 = {
      \ "tex"	      : "\\TeX{}",
      \ "latex"	      : "\\LaTeX{}",
      \ "input"	      : "\\input{<++>}",
      \ "usepackage"    : "\\usepackage[<++>]{<++>}",
      \ "newcommand"    : "\\newcommand{<++>}[<++>][<++>]{<++>}",
      \ "section"	: "\\section{<++>}\n<++>",
      \ "subsection"    : "\\subsection{<++>}\n<++>",
      \ "ssection"      : "\\subsection{<++>}\n<++>",
      \ "subsubsection" : "\\subsubsection{<++>}\n<++>",
      \ "sssection"     : "\\subsubsection{<++>}\n<++>",
      \ "paragraph"     : "\\paragraph{<++>} <++>",
      \ "frametitle"    : "\\frametitle{<++>}\n<++>",
      \ "boldsymbol"    : "\\boldsymbol{<++>}<++>",
      \ "text"	      : "\\text{<++>}<++>",
      \ "tx"	      : "\\text{<++>}<++>",
      \ "mathbf"	      : "\\mathbf{<++>}<++>",
      \ "mbf"	      : "\\mathbf{<++>}<++>",
      \ "mathbb"	      : "\\mathbb{<++>}<++>",
      \ "bb"	      : "\\mathbb{<++>}<++>",
      \ "mathrm"	      : "\\mathrm{<++>}<++>",
      \ "rm"	      : "\\mathrm{<++>}<++>",
      \ "mathcal"	      : "\\mathcal{<++>}<++>",
      \ "cal"	      : "\\mathcal{<++>}<++>",
      \ "mathscr"	      : "\\mathscr{<++>}<++>",
      \ "scr"	      : "\\mathscr{<++>}<++>",
      \ "textbf"	      : "\\textbf{<++>}<++>",
      \ "bf"	      : "\\textbf{<++>}<++>",
      \ "textit"	      : "\\textit{<++>}<++>",
      \ "it"	      : "\\textit{<++>}<++>",
      \ "textsc"	      : "\\textsc{<++>}<++>",
      \ "sc"	      : "\\textsc{<++>}<++>",
      \ "texttt"	      : "\\texttt{<++>}<++>",
      \ "tt"	      : "\\texttt{<++>}<++>",
      \ "emph"	      : "\\emph{<++>}<++>",
      \ "cite"	      : "\\cite[<++>]{<++>}<++>",
      \ "ref"	      : "\\ref{<++>}<++>",
      \ "eqref"	      : "\\eqref{eq:<++>}<++>",
      \ "hyperref"      : "\\hyperref[<++>]{<++>}<++>",
      \ "label"	      : "\\label{<++>}<++>",
      \ 'a' : '\alpha',
      \ 'b' : '\beta',
      \ 'c' : '\varsigma',
      \ 'd' : '\delta',
      \ 'e' : '\epsilon',
      \ 'f' : '\phi',
      \ 'g' : '\gamma',
      \ 'h' : '\eta',
      \ 'i' : '\iota',
      \ 'j' : '\varepsilon',
      \ 'k' : '\kappa',
      \ 'l' : '\lambda',
      \ 'm' : '\mu',
      \ 'n' : '\nu',
      \ 'o' : '\omicron',
      \ 'p' : '\pi',
      \ 'q' : '\theta',
      \ 'r' : '\rho',
      \ 's' : '\sigma',
      \ 't' : '\tau',
      \ 'u' : '\upsilon',
      \ 'v' : '\varphi',
      \ 'w' : '\omega',
      \ 'x' : '\chi',
      \ 'y' : '\psi',
      \ 'z' : '\zeta',
      \ 'D' : '\Delta',
      \ 'F' : '\Phi',
      \ 'G' : '\Gamma',
      \ 'L' : '\Lambda',
      \ 'P' : '\Pi',
      \ 'Q' : '\Theta',
      \ 'S' : '\Sigma',
      \ 'U' : '\Upsilon',
      \ 'W' : '\Omega',
      \ 'Y' : '\Psi',
      \ '^' : '\hat{<++>}<++>',
      \ '_' : '\bar{<++>}<++>',
      \ '6' : '\partial',
      \ 'partial' : '\partial',
      \ '8' : '\infty',
      \ 'infty' : '\infty',
      \ '-' : '\setminus',
      \ 'setminus' : '\setminus',
      \ '/' : '\frac{<++>}{<++>}<++>',
      \ 'frac' : '\frac{<++>}{<++>}<++>',
      \ '@' : '\circ',
      \ '0' : '^\circ',
      \ '=' : '\equiv',
      \ '.' : '\cdot',
      \ '*' : '\times',
      \ '2' : '\sqrt[<++>]{<++>}<++>',
      \ 'nonumber' : '\nonumber',
      \ "square" : '\square',
      \ "tilde" : '\tilde{<++>}<++>',
      \ "hat" : '\hat{<++>}<++>',
      \ "bar" : '\bar{<++>}<++>',
      \ "widetilde" : '\widetilde{<++>}<++>',
      \ "wtilde" : '\widetilde{<++>}<++>',
      \ "widehat" : '\widehat{<++>}<++>',
      \ "what" : '\widehat{<++>}<++>',
      \ "widebar" : '\widebar{<++>}<++>',
      \ "wbar" : '\widebar{<++>}<++>',
      \ "wedge" : '\wedge',
      \ 'int' : "\\int_{<++>}^{<++>}<++>",
      \ 'dot' : '\dot{<++>}<++>',
      \ 'sum' : '\sum_{<++>}^{<++>}<++>',
      \ }
" }}}

" imap dictionary: \...<space> {{{
" Leader 92 = '\'
" Trigger 32 = "\<space>"
let s:imapDict_92_32 = {
      \ "tex"	      : "\\TeX{} <++>",
      \ "latex"	      : "\\LaTeX{} <++>",
      \ "item"	      : "\\item ",
      \ "boldsymbol"  : "\\boldsymbol ",
      \ "mathbf"      : "\\mathbf ",
      \ "mbf"	      : "\\mathbf ",
      \ "mathbb"      : "\\mathbb ",
      \ "bb"	      : "\\mathbb ",
      \ "mathrm"      : "\\mathrm ",
      \ "rm"	      : "\\mathrm ",
      \ "mathcal"     : "\\mathcal ",
      \ "cal"	      : "\\mathcal ",
      \ "mathscr"     : "\\mathscr ",
      \ "scr"	      : "\\mathscr ",
      \ "a" : '\alpha ',
      \ 'b' : '\beta ',
      \ 'c' : '\varsigma ',
      \ 'd' : '\delta ',
      \ 'e' : '\epsilon ',
      \ 'f' : '\phi ',
      \ 'g' : '\gamma ',
      \ 'h' : '\eta ',
      \ 'i' : '\iota ',
      \ 'j' : '\varepsilon ',
      \ 'k' : '\kappa ',
      \ 'l' : '\lambda ',
      \ 'm' : '\mu ',
      \ 'n' : '\nu ',
      \ 'o' : '\omicron ',
      \ 'p' : '\pi ',
      \ 'q' : '\theta ',
      \ 'r' : '\rho ',
      \ 's' : '\sigma ',
      \ 't' : '\tau ',
      \ 'u' : '\upsilon ',
      \ 'v' : '\varphi ',
      \ 'w' : '\omega ',
      \ 'x' : '\chi ',
      \ 'y' : '\psi ',
      \ 'z' : '\zeta ',
      \ 'D' : '\Delta ',
      \ 'F' : '\Phi ',
      \ 'G' : '\Gamma ',
      \ 'L' : '\Lambda ',
      \ 'P' : '\Pi ',
      \ 'Q' : '\Theta ',
      \ 'S' : '\Sigma ',
      \ 'U' : '\Upsilon ',
      \ 'W' : '\Omega ',
      \ 'Y' : '\Psi ',
      \ '^' : '\hat ',
      \ '_' : '\bar ',
      \ '6' : '\partial ',
      \ 'partial' : '\partial ',
      \ '8' : '\infty ',
      \ 'infty' : '\infty ',
      \ '-' : '\setminus ',
      \ 'setminus' : '\setminus ',
      \ '/' : '\frac ',
      \ 'frac' : '\frac ',
      \ '@' : '\circ ',
      \ '0' : '^\circ ',
      \ '=' : '\equiv ',
      \ '.' : '\cdot ',
      \ '*' : '\times ',
      \ '2' : '\sqrt ',
      \ '~' : '\tilde ',
      \ 'nonumber' : '\nonumber',
      \ "square" : '\square',
      \ "tilde" : '\tilde ',
      \ "hat" : '\hat ',
      \ "bar" : '\bar ',
      \ "widetilde" : '\widetilde ',
      \ "wtilde" : '\widetilde ',
      \ "widehat" : '\widehat ',
      \ "what" : '\widehat ',
      \ "widebar" : '\widebar ',
      \ "wbar" : '\widebar ',
      \ "wedge" : '\wedge ',
      \ 'dot' : '\dot ',
      \ }
" }}}

" imap dictionary: ;...<tab> {{{
" Leader 59 = ";"
" Trigger 9 = "\<tab>"
" let s:imapDict_59_9 = {
" 	    \ 'a' : '\alpha',
" 	    \ 'b' : '\beta',
" 	    \ 'c' : '\varsigma',
" 	    \ 'd' : '\delta',
" 	    \ 'e' : '\epsilon',
" 	    \ 'f' : '\phi',
" 	    \ 'g' : '\gamma',
" 	    \ 'h' : '\eta',
" 	    \ 'i' : '\iota',
" 	    \ 'j' : '\varepsilon',
" 	    \ 'k' : '\kappa',
" 	    \ 'l' : '\lambda',
" 	    \ 'm' : '\mu',
" 	    \ 'n' : '\nu',
" 	    \ 'o' : '\omicron',
" 	    \ 'p' : '\pi',
" 	    \ 'q' : '\theta',
" 	    \ 'r' : '\rho',
" 	    \ 's' : '\sigma',
" 	    \ 't' : '\tau',
" 	    \ 'u' : '\upsilon',
" 	    \ 'v' : '\varphi',
" 	    \ 'w' : '\omega',
" 	    \ 'x' : '\chi',
" 	    \ 'y' : '\psi',
" 	    \ 'z' : '\zeta',
" 	    \ 'D' : '\Delta',
" 	    \ 'F' : '\Phi',
" 	    \ 'G' : '\Gamma',
" 	    \ 'L' : '\Lambda',
" 	    \ 'P' : '\Pi',
" 	    \ 'Q' : '\Theta',
" 	    \ 'S' : '\Sigma',
" 	    \ 'U' : '\Upsilon',
" 	    \ 'W' : '\Omega',
" 	    \ 'Y' : '\Psi',
" 	    \ '^' : '\hat{<++>}<++>',
" 	    \ '_' : '\bar{<++>}<++>',
" 	    \ '6' : '\partial',
" 	    \ '8' : '\infty',
" 	    \ '/' : '\setminus',
" 	    \ '%' : '\frac{<++>}{<++>}<++>',
" 	    \ '@' : '\circ',
" 	    \ '0' : '^\circ',
" 	    \ '=' : '\equiv',
" 	    \ '.' : '\cdot',
" 	    \ '*' : '\times',
" 	    \ '&' : '\cap',
" 	    \ '+' : '\cup',
" 	    \ '(' : '\subset',
" 	    \ ')' : '\supset',
" 	    \ '$' : "\\int_{<++>}^{<++>}<++>",
" 	    \ '2' : '\sqrt{<++>}<++>',
" 	    \ ':' : '\dot{<++>}<++>',
" 	    \ '~' : '\tilde{<++>}<++>',
" 	    \ 'M' : '\sum_{<++>}^{<++>}<++>',
" 	    \ 'V' : '\wedge',
" 	    \ '<' : '\le',
" 	    \ '>' : '\ge',
" 	    \ ',' : '\nonumber',
" 	    \ }
" }}}

" imap dictionary: ;...<space> {{{
" Leader 59 = ";"
" Trigger 32 = "\<space>"
" let s:imapDict_59_32 = {
" 	    \ 'a' : '\alpha ',
" 	    \ 'b' : '\beta ',
" 	    \ 'c' : '\varsigma ',
" 	    \ 'd' : '\delta ',
" 	    \ 'e' : '\epsilon ',
" 	    \ 'f' : '\phi ',
" 	    \ 'g' : '\gamma ',
" 	    \ 'h' : '\eta ',
" 	    \ 'i' : '\iota ',
" 	    \ 'j' : '\varepsilon ',
" 	    \ 'k' : '\kappa ',
" 	    \ 'l' : '\lambda ',
" 	    \ 'm' : '\mu ',
" 	    \ 'n' : '\nu ',
" 	    \ 'o' : '\omicron ',
" 	    \ 'p' : '\pi ',
" 	    \ 'q' : '\theta ',
" 	    \ 'r' : '\rho ',
" 	    \ 's' : '\sigma ',
" 	    \ 't' : '\tau ',
" 	    \ 'u' : '\upsilon ',
" 	    \ 'v' : '\varphi ',
" 	    \ 'w' : '\omega ',
" 	    \ 'x' : '\chi ',
" 	    \ 'y' : '\psi ',
" 	    \ 'z' : '\zeta ',
" 	    \ 'D' : '\Delta ',
" 	    \ 'F' : '\Phi ',
" 	    \ 'G' : '\Gamma ',
" 	    \ 'L' : '\Lambda ',
" 	    \ 'P' : '\Pi ',
" 	    \ 'Q' : '\Theta ',
" 	    \ 'S' : '\Sigma ',
" 	    \ 'U' : '\Upsilon ',
" 	    \ 'W' : '\Omega ',
" 	    \ 'Y' : '\Psi ',
" 	    \ '^' : '\hat ',
" 	    \ '_' : '\bar ',
" 	    \ '6' : '\partial ',
" 	    \ '8' : '\infty ',
" 	    \ '/' : '\setminus ',
" 	    \ '%' : '\frac ',
" 	    \ '@' : '\circ ',
" 	    \ '0' : '^\circ ',
" 	    \ '=' : '\equiv ',
" 	    \ '.' : '\cdot ',
" 	    \ '*' : '\times ',
" 	    \ '&' : '\cap ',
" 	    \ '+' : '\cup ',
" 	    \ '(' : '\subset ',
" 	    \ ')' : '\supset ',
" 	    \ '$' : "\\int ",
" 	    \ '2' : '\sqrt ',
" 	    \ ':' : '\dot ',
" 	    \ '~' : '\tilde ',
" 	    \ 'M' : '\sum ',
" 	    \ 'V' : '\wedge ',
" 	    \ '<' : '\le ',
" 	    \ '>' : '\ge ',
" 	    \  ',' : '\nonumber ',
" 	    \ }
" }}}

" }}}
" s:ExpansionLookup: {{{
" Description: {{{ Look up expansion text corresponding to the user-typed 
" token, or to a macro name matching it, in selected dictionary above.
" }}}
func s:ExpansionLookup(trigger, leader, token)
  let l:expansion = ''
  " Choose dictionary based on leader and trigger
  let l:dict = s:imapDict_{char2nr(a:leader)}_{a:trigger}

  " User-typed token matches a macro name (dict key) exactly, so return 
  " corresponding expansion text immediately.
  if has_key(l:dict, a:token)
    let l:expansion = l:dict[a:token]
    return l:expansion
  endif

  " User-typed token does not match a macro name exactly, so build a list 
  " of those it pattern-matches.
  let l:macroMatchList = []
  for l:macro in keys(l:dict)
    if l:macro =~ '\C^'.a:token.'\w*$'
      let l:macroMatchList = add(l:macroMatchList, l:macro)
    endif
  endfor

  " Found no macro name matching user-typed token, so return blank string.
  if empty(l:macroMatchList)
    if a:trigger == 13 " <cr>
      return "\\begin{".a:token."}\n<++>\n\\end{".a:token."}"
    elseif a:trigger == 9 " <tab>
      return "\\".a:token."{<++>}<++>"
    " elseif a:trigger == 32 " <space>
    "   return "\\begin{".a:token."}\n<++>\n\\end{".a:token."}"
    else
      return l:expansion
    endif
  endif

  if len(l:macroMatchList) == 1
    " Unique macro key matching token, so just grab that one's 
    " corresponding expansion text.
    let l:expansion = l:dict[l:macroMatchList[0]]
  else " Ask user which macro they want.
    call sort(l:macroMatchList)
    let l:selMacroList = ['Select macro:']
    for l:selection in l:macroMatchList
      call add(l:selMacroList,
	    \ index(l:macroMatchList, l:selection) + 1
	    \ . '. ' . l:selection)
    endfor
    let l:selMacro = l:macroMatchList[
	  \ inputlist(l:selMacroList) - 1 ]
    let l:expansion = l:dict[l:selMacro]
  endif

  return l:expansion
endfunc
" }}}
" s:AddMovement: {{{
" Description: Move to and delete first placeholder.
func s:AddMovement(text, startLn)
  let l:firstPhIdx = stridx(a:text, "<++>")
  if l:firstPhIdx >= 0
    return  a:text . "\<c-o>:call cursor(".a:startLn.", 1) | "
	  \ . "call search(\"<++>\")\<cr>"
	  \ . repeat("\<Del>", 4)
  else
    return a:text
  endif
endfunc
" }}}
" GetRunningImap: {{{
" Description: to be written {{{
" args:
" 	trigger = char code of the keystroke imapped to trigger this lookup 
" 	below.
" }}}
func tex#imap#GetRunningImap(trigger)
  " Set current pos, parameters.
  let l:line = getline(".")
  let l:ln = line(".")
  let l:col = col(".")
  let l:leaderIdx = l:col - 2
  let l:maxMacroNameLen = 14 " currently comes from "subsubsection"

  " Search backward for a leader character.
  let l:stop = l:col - 2 - l:maxMacroNameLen
  while l:leaderIdx >= l:stop
      \ && index(s:runningimap_ldrs, l:line[l:leaderIdx]) < 0
      if l:line[l:leaderIdx] =~ '\s'
	" No whitespace characters allowed in macro names/tokens, so return 
	" immediately if we encounter one.
	return nr2char(a:trigger)
      endif
    let l:leaderIdx -= 1
  endwhile
  " No leader char found.
  if l:leaderIdx < l:stop
    return nr2char(a:trigger)
  endif

  " Get user-typed token: text between last leader char and pos of cursor 
  " at which trigger was inserted.
  let l:leader = l:line[l:leaderIdx]
  let l:token = slice(l:line, l:leaderIdx + 1, l:col - 1)
  " Abort if token is empty.
  if empty(l:token)
    return nr2char(a:trigger)
  endif

  " Look up expansion text corresponding to the user-typed token, or to a 
  " macro name matching it, in selected dictionary above.
  let l:expansion = s:ExpansionLookup(a:trigger, l:leader, l:token)

  " Don't paste in a blank; just return the trigger.
  if empty(l:expansion)
    return nr2char(a:trigger)
  endif

  " Add enough backspaces to overwrite the token and then an undo mark.
  let l:printText = repeat("\<bs>", strcharlen(l:token) + 1)
	\ . "\<c-g>u"
	\ . "\<c-v>"
	\ . l:expansion

  return s:AddMovement(l:printText, l:ln)
endfunc
" }}}
