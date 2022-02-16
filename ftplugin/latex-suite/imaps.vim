" inoremap __ <c-r>='_{<++>}<++>'<cr>
" inoremap () <c-r>='(<++>)<++>'<cr>
" inoremap [] <c-r>='[<++>]<++>'<cr>
" inoremap {} <c-r>='{<++>}<++>'<cr>
" inoremap ^^ <c-r>='^{<++>}<++>'<cr>
" inoremap $$ <c-r>='$<++>$<++>'<cr>
" inoremap (( <c-r>='\left( <++> \right)<++>'<cr>
" inoremap [[ <c-r>='\left[ <++> \right]<++>'<cr>
" inoremap {{ <c-r>='\left\{ <++> \right\}<++>'<cr>
inoremap == <c-r>='&= '<cr>
inoremap ~~ <c-r>='&\approx '<cr>
inoremap =~ <c-r>='\approx'<cr>
inoremap :: <c-r>='\dots'<cr>
inoremap .. <c-r>='\dotsc'<cr>
inoremap ** <c-r>='\dotsb'<cr>

let s:imapDictSC = {
	    \ 'a': '\alpha',
	    \ 'b': '\beta',
	    \ 'c': '\varsigma',
	    \ 'd': '\delta',
	    \ 'e': '\epsilon',
	    \ 'f': '\phi',
	    \ 'g': '\gamma',
	    \ 'h': '\eta',
	    \ 'i': '\iota',
	    \ 'j': '\varepsilon',
	    \ 'k': '\kappa',
	    \ 'l': '\lambda',
	    \ 'm': '\mu',
	    \ 'n': '\nu',
	    \ 'o': '\omicron',
	    \ 'p': '\pi',
	    \ 'q': '\theta',
	    \ 'r': '\rho',
	    \ 's': '\sigma',
	    \ 't': '\tau',
	    \ 'u': '\upsilon',
	    \ 'v': '\varphi',
	    \ 'w': '\omega',
	    \ 'x': '\chi',
	    \ 'y': '\psi',
	    \ 'z': '\zeta',
	    \ 'D': '\Delta',
	    \ 'F': '\Phi',
	    \ 'G': '\Gamma',
	    \ 'L': '\Lambda',
	    \ 'P': '\Pi',
	    \ 'Q': '\Theta',
	    \ 'S': '\Sigma',
	    \ 'U': '\Upsilon',
	    \ 'W': '\Omega',
	    \ 'Y': '\Psi',
	    \ '^': '\hat{<++>}<++>',
	    \ '_': '\bar{<++>}<++>',
	    \ '6': '\partial',
	    \ '8': '\infty',
	    \ '/': '\setminus',
	    \ '%': '\frac{<++>}{<++>}<++>',
	    \ '@': '\circ',
	    \ '0': '^\circ',
	    \ '=': '\equiv',
	    \ '\.': '\cdot',
	    \ '\*': '\times',
	    \ '&': '\cap',
	    \ '+': '\cup',
	    \ '(': '\subset',
	    \ ')': '\supset',
	    \ '$': "\\int_{<++>}^{<++>}<++>",
	    \ '2': '\sqrt{<++>}<++>',
	    \ ':': '\dot{<++>}<++>',
	    \ '~': '\tilde{<++>}<++>',
	    \ 'M': '\sum_{<++>}^{<++>}<++>',
	    \ 'V': '\wedge',
	    \ '<': '\le',
	    \ '>': '\ge',
	    \ ',': '\nonumber',
	    \ }
" call IMAP (g:Tex_Leader.'-', '\bigcap', "tex")
" call IMAP (g:Tex_Leader.'+', '\bigcup', "tex")
" call IMAP (g:Tex_Leader.':', '\ddot{<++>}<++>', "tex")
" call IMAP (g:Tex_Leader.'|', '\Big|', "tex")

let s:imapDictSp = {
	    \ "section": "\\section{<++>}\n<++>",
	    \ "ssection": "\\subsection{<++>}\n<++>",
	    \ "sssection": "\\subsubsection{<++>}\n<++>",
	    \ "paragraph": "\\paragraph{<++>} <++>",
	    \ "item": "\\item <++>",
	    \ "frametitle": "\\frametitle{<++>}\n<++>",
	    \ "boldsymbol": "\\boldsymbol <++>",
	    \ "text": "\\text{<++>}<++>",
	    \ "mb": "\\mathbf{<++>}<++>", 
	    \ "mr": "\\mathrm{<++>}<++>", 
	    \ "ms": "\\mathscr{<++>}<++>", 
	    \ "tb": "\\textbf{<++>}<++>", 
	    \ "ti": "\\textit{<++>}<++>", 
	    \ "emph": "\\emph{<++>}<++>", 
	    \ "cite": "\\cite{<++>}<++>", 
	    \ "ref": "\\ref{<++>}<++>", 
	    \ "hyperref": "\\hyperref{<++>}<++>", 
	    \ }

let s:imapDictCR = {
	    \ "document": "\\begin{document}\n<++>\n\\end{document}",
	    \ "math": "\\begin{displaymath}\n<++>\n\\end{displaymath}\n<++>",
	    \ "equation": "\\begin{equation}\n<++>\n\\end{equation}\n<++>",
	    \ "eqs": "\\begin{equation*}\n<++>\n\\end{equation*}\n<++>",
	    \ "align": "\\begin{align}\n<++>\n\\end{align}\n<++>",
	    \ "als": "\\begin{align*}\n<++>\n\\end{align*}\n<++>",
	    \ "enumerate": "\\begin{enumerate}\n\\item <++>\n\\end{enumerate}\n<++>",
	    \ "itemize": "\\begin{itemize}\n\\item <++>\n\\end{itemize}\n<++>",
	    \ "frame": "\\begin{frame}\n<++>\n\\end{frame}\n<++>",
	    \ }

" GetMapping: TODO
" args:
" 	trigger = imapped keystroke that fires the macro lookup
function! GetMapping(trigger)
    let l:line = getline(".")
    let l:col = col(".")
    let l:leaderIdx = l:col - 1

    " Search backward for the leader character, the text following which 
    " forms the token we try to match with a macro in one of the 
    " dictionaries above.
    while l:leaderIdx >= 0
	if l:line[l:leaderIdx] == '\' || l:line[l:leaderIdx] == ';'
	    let l:token = slice(l:line, l:leaderIdx + 1, l:col - 1)
		  " \ escape(slice(l:line, l:leaderIdx + 1, l:col - 1),
		  " \ '*^@:\$/?=+-()&.')
	    " Abort if token empty or whitespace.
	    if l:token =~ '\s' || strlen(l:token) == 0
		return a:trigger
	    endif

	    let l:leader = l:line[l:leaderIdx]

	    " Choose dictionary based on leader and trigger
	    if l:leader == ';'
		let l:imapDict = s:imapDictSC
	    else
		if a:trigger == "\<cr>"
		    let l:imapDict = s:imapDictCR
		else
		    let l:imapDict = s:imapDictSp
		endif
	    endif

	    for [l:macro, l:result] in items(l:imapDict)
		if l:macro =~ '\C^'.l:token.'\w*'
		    let l:backspaces = ""
		    let l:idx = 0
		    while l:idx <= strcharlen(l:token)
			let l:idx += 1
			let l:backspaces .= "\<bs>"
		    endwhile
		    return l:backspaces."\<c-g>u" . IMAP_PutTextWithMovement(l:result, "<+", "+>")
		endif
	    endfor
	endif

	let l:leaderIdx -= 1
    endwhile

    " Never found the a leader character.
    return a:trigger
endfunction

inoremap <space> <c-r>=GetMapping("<c-v><space>")<cr>
inoremap <cr> <c-r>=GetMapping("<c-v><cr>")<cr>
