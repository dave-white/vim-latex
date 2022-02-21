" HEADER ==================================================================
" vim:ft=vim:sw=4:sts=4:foldmethod=manual:commentstring=\"\ %s:ff=unix
" 	 File: imaps.vim
"      Author: David G. White
"     Created: Sat. 19 Feb. 2022, 14:30 UTC-5
"
" Description: 
"
"    Requires: vim-latex/plugin/imaps.vim#IMAP_PutTextWithMovement()
" 
"        NOTE: This file is best viewed with Vim-6.0+ with folding turned 
"        on.
"==========================================================================

let g:runImapLeaderList = ['\', ';']

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

" imap dictionary: ;...<tab> {{{
" Leader 59 = ";"
" Trigger 9 = "\<tab>"
let s:imapDict_59_9 = {
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
	    \ '8' : '\infty',
	    \ '/' : '\setminus',
	    \ '%' : '\frac{<++>}{<++>}<++>',
	    \ '@' : '\circ',
	    \ '0' : '^\circ',
	    \ '=' : '\equiv',
	    \ '.' : '\cdot',
	    \ '*' : '\times',
	    \ '&' : '\cap',
	    \ '+' : '\cup',
	    \ '(' : '\subset',
	    \ ')' : '\supset',
	    \ '$' : "\\int_{<++>}^{<++>}<++>",
	    \ '2' : '\sqrt{<++>}<++>',
	    \ ':' : '\dot{<++>}<++>',
	    \ '~' : '\tilde{<++>}<++>',
	    \ 'M' : '\sum_{<++>}^{<++>}<++>',
	    \ 'V' : '\wedge',
	    \ '<' : '\le',
	    \ '>' : '\ge',
	    \ ',' : '\nonumber',
	    \ }
" }}}

" Unincorporated IMAPs {{{
" call IMAP (g:Tex_Leader.'-', '\bigcap', "tex")
" call IMAP (g:Tex_Leader.'+', '\bigcup', "tex")
" call IMAP (g:Tex_Leader.':', '\ddot{<++>}<++>', "tex")
" call IMAP (g:Tex_Leader.'|', '\Big|', "tex")
" }}}

" imap dictionary: ;...<tab> {{{
" Leader 59 = ";"
" Trigger 32 = "\<space>"
" let s:imapDict_59_32 = s:imapDict_59_9
" }}}

" imap dictionary: \...<tab> {{{
" Leader 92 = '\'
" Trigger 9 = "\<tab>"
let s:imapDict_92_9 = {
	    \ "section"	      : "\\section{<++>}\n<++>",
	    \ "subsection"    : "\\subsection{<++>}\n<++>",
	    \ "ssection"      : "\\subsection{<++>}\n<++>",
	    \ "subsubsection" : "\\subsubsection{<++>}\n<++>",
	    \ "sssection"     : "\\subsubsection{<++>}\n<++>",
	    \ "paragraph"     : "\\paragraph{<++>} <++>",
	    \ "item"	      : "\\item <++>",
	    \ "frametitle"    : "\\frametitle{<++>}\n<++>",
	    \ "boldsymbol"    : "\\boldsymbol <++>",
	    \ "text"	      : "\\text{<++>}<++>",
	    \ "mathbf"	      : "\\mathbf{<++>}<++>",
	    \ "mbf"	      : "\\mathbf{<++>}<++>",
	    \ "mathbb"	      : "\\mathbb{<++>}<++>",
	    \ "mbb"	      : "\\mathbb{<++>}<++>",
	    \ "mathrm"	      : "\\mathrm{<++>}<++>",
	    \ "mr"	      : "\\mathrm{<++>}<++>",
	    \ "mathcal"	      : "\\mathcal{<++>}<++>",
	    \ "mc"	      : "\\mathcal{<++>}<++>",
	    \ "mathscr"	      : "\\mathscr{<++>}<++>",
	    \ "ms"	      : "\\mathscr{<++>}<++>",
	    \ "textbf"	      : "\\textbf{<++>}<++>",
	    \ "tb"	      : "\\textbf{<++>}<++>",
	    \ "textit"	      : "\\textit{<++>}<++>",
	    \ "ti"	      : "\\textit{<++>}<++>",
	    \ "emph"	      : "\\emph{<++>}<++>",
	    \ "cite"	      : "\\cite{<++>}<++>",
	    \ "ref"	      : "\\ref{<++>}<++>",
	    \ "hyperref"      : "\\hyperref[<++>]{<++>}<++>",
	    \ }
" }}}

" imap dictionary: \...<space> {{{
" Leader 92 = '\'
" Trigger 32 = "\<space>"
" let s:imapDict_92_32 = s:imapDict_92_9
" }}}

" imap dictionary: \...<cr> {{{
" Leader 92 = '\'
" Trigger 13 = "\<cr>"
let s:imapDict_92_13 = {
	    \ "document"     : "\\begin{document}\n<++>\n\\end{document}",
	    \ "displaymath"  :
	    \ "\\begin{displaymath}\n<++>\n\\end{displaymath}\n<++>",
	    \ "math"	     :
	    \ "\\begin{displaymath}\n<++>\n\\end{displaymath}\n<++>",
	    \ "equation"     :
	    \ "\\begin{equation}"
	    \ . "\n\\label{eqn:<++>}\n<++>\n\\end{equation}\n<++>",
	    \ "eqn"     :
	    \ "\\begin{equation}"
	    \ . "\n\\label{eqn:<++>}\n<++>\n\\end{equation}\n<++>",
	    \ "equationstar" :
	    \ "\\begin{equation*}\n<++>\n\\end{equation*}\n<++>",
	    \ "eqs"	     :
	    \ "\\begin{equation*}\n<++>\n\\end{equation*}\n<++>",
	    \ "align"	     : "\\begin{align}\n<++>\n\\end{align}\n<++>",
	    \ "alignstar"    : "\\begin{align*}\n<++>\n\\end{align*}\n<++>",
	    \ "als"	     : "\\begin{align*}\n<++>\n\\end{align*}\n<++>",
	    \ "enumerate"    :
	    \ "\\begin{enumerate}\n\\item <++>\n\\end{enumerate}\n<++>",
	    \ "itemize"	     :
	    \ "\\begin{itemize}\n\\item <++>\n\\end{itemize}\n<++>",
	    \ "frame"	     : "\\begin{frame}\n<++>\n\\end{frame}\n<++>",
	    \ "definition"   :
	    \ "\\begin{definition}"
	    \ . "\n\\label{dfn:<++>}\n<++>\n\\end{definition}\n<++>",
	    \ "theorem"	     :
	    \ "\\begin{theorem}[<++>]"
	    \ . "\n\\label{thm:<++>}\n<++>\n\\end{theorem}\n<++>",
	    \ "thm"	     :
	    \ "\\begin{theorem}[<++>]"
	    \ . "\n\\label{thm:<++>}\n<++>\n\\end{theorem}\n<++>",
	    \ "nthm"	     :
	    \ "\\begin{nthm}[<++>]"
	    \ . "\n\\label{thm:<++>}\n<++>\n\\end{nthm}\n<++>",
	    \ "proposition"  :
	    \ "\\begin{proposition}"
	    \ . "\n\\label{prp:<++>}\n<++>\n\\end{proposition}\n<++>",
	    \ "lemma"	     :
	    \ "\\begin{lemma}\n\\label{lem:<++>}\n<++>\n\\end{lemma}\n<++>",
	    \ }
" }}}

" }}}

" s:ExpansionLookup: {{{
" Description: {{{ Look up expansion text corresponding to the user-typed 
" token, or to a macro name matching it, in selected dictionary above.
" }}}
func s:ExpansionLookup(dict, token)
    let l:expansion = ''

    " User-typed token matches a macro name (dict key) exactly, so return 
    " corresponding expansion text immediately.
    if has_key(a:dict, a:token)
	let l:expansion = a:dict[a:token]
	return l:expansion
    endif

    " User-typed token does not match a macro name exactly, so build a list 
    " of those it pattern-matches.
    let l:macroMatchList = []
    for l:macro in keys(a:dict)
	if l:macro =~ '\C^'.a:token
	    let l:macroMatchList = add(l:macroMatchList, l:macro)
	endif
    endfor

    " Found no macro name matching user-typed token, so return blank 
    " string.
    if empty(l:macroMatchList)
	return l:expansion
    endif

    if len(l:macroMatchList) == 1
	" Unique macro key matching token, so just grab that one's 
	" corresponding expansion text.
	let l:expansion = a:dict[l:macroMatchList[0]]
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
	let l:expansion = a:dict[l:selMacro]
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
func GetRunningImap(trigger)
    " Set current pos, parameters.
    let l:line = getline(".")
    let l:ln = line(".")
    let l:col = col(".")
    let l:leaderIdx = l:col - 2
    let l:maxMacroNameLen = 14 " currently comes from "subsubsection"

    " Search backward for a leader character.
    while l:leaderIdx >= l:col - 2 - l:maxMacroNameLen
	if index(g:runImapLeaderList, l:line[l:leaderIdx]) >= 0
	    break
	else
	    let l:leaderIdx -= 1
	endif
    endwhile

    " No leader char found.
    if l:leaderIdx < l:col - 2 - l:maxMacroNameLen
	return nr2char(a:trigger)
    endif

    " Get user-typed token: text between last leader char and pos of cursor 
    " at which trigger was inserted.
    let l:leader = l:line[l:leaderIdx]
    let l:token = slice(l:line, l:leaderIdx + 1, l:col - 1)
    " Abort if token is empty or just whitespace.
    if l:token =~ '\s' || empty(l:token)
	return nr2char(a:trigger)
    endif

    " Choose dictionary based on leader and trigger
    let l:imapDict = s:imapDict_{char2nr(l:leader)}_{a:trigger}

    " Look up expansion text corresponding to the user-typed token, or to a 
    " macro name matching it, in selected dictionary above.
    let l:expansion = s:ExpansionLookup(l:imapDict, l:token)

    " Don't paste in a blank; just return the trigger.
    if empty(l:expansion)
	return nr2char(a:trigger)
    endif

    " Add enough backspaces to overwrite the token and then an undo mark.
    let l:printText = repeat("\<bs>", strcharlen(l:token) + 1)
		    \ . "\<c-g>u"
		    \ . l:expansion

    return s:AddMovement(l:printText, l:ln)
endfunc
" }}}

" Raw imaps {{{
" let g:runImapTriggerList = ["\<tab>", "\<cr>"]
" let s:asciiCd = 1
" while s:asciiCd < 100
"     let s:trigger = nr2char(s:asciiCd)
"     if index(g:runImapTriggerList, s:trigger) >= 0
" 	exe 'inoremap ' . s:trigger . '<c-r>=GetRunningImap('
" 		    \ . s:asciiCd . ')<cr>'
"     endif
"     let s:asciiCd += 1
" endwhile

inoremap <buffer> <tab> <c-r>=GetRunningImap(9)<cr>
"inoremap <space> <c-r>=GetRunningImap(32)<cr>
inoremap <buffer> <cr> <c-r>=GetRunningImap(13)<cr>

inoremap == <c-r>='&= '<cr>
inoremap ~~ <c-r>='&\approx '<cr>
inoremap =~ <c-r>='\approx'<cr>
inoremap :: <c-r>='\dots'<cr>
inoremap .. <c-r>='\dotsc'<cr>
inoremap ** <c-r>='\dotsb'<cr>

inoremap <buffer> __ <c-r>=IMAP_PutTextWithMovement('_{<++>}<++>')<cr>
inoremap <buffer> ^^ <c-r>=IMAP_PutTextWithMovement('^{<++>}<++>')<cr>
inoremap <buffer> () <c-r>=IMAP_PutTextWithMovement('(<++>)<++>')<cr>
inoremap <buffer> [] <c-r>=IMAP_PutTextWithMovement('[<++>]<++>')<cr>
inoremap <buffer> {} <c-r>=IMAP_PutTextWithMovement('{<++>}<++>')<cr>
inoremap <buffer> $$ <c-r>=IMAP_PutTextWithMovement('$<++>$<++>')<cr>
inoremap <buffer> (( <c-r>=
	    \IMAP_PutTextWithMovement('\left( <++> \right)<++>')<cr>
inoremap <buffer> [[ <c-r>=
	    \IMAP_PutTextWithMovement('\left[ <++> \right]<++>')<cr>
inoremap <buffer> {{ <c-r>=
	    \IMAP_PutTextWithMovement('\left\{ <++> \right\}<++>')<cr>
" }}}

