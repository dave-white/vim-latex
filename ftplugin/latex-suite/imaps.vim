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
	    \ "math": "\\begin{displaymath}\n<++>\n\\end{displaymath}",
	    \ "equation": "\\begin{equation}\n<++>\n\\end{equation}",
	    \ "eqs": "\\begin{equation*}\n<++>\n\\end{equation*}",
	    \ "align": "\\begin{align}\n<++>\n\\end{align}",
	    \ "als": "\\begin{align*}\n<++>\n\\end{align*}",
	    \ "enumerate": "\\begin{enumerate}\n\\item <++>\n\\end{enumerate}",
	    \ "itemize": "\\begin{itemize}\n\\item <++>\n\\end{itemize}",
	    \ "frame": "\\begin{frame}\n<++>\n\\end{frame}\n<++>",
	    \ }

function! GetMapping(trigger)
    let l:line = getline(".")
    let l:col = col(".")
    let l:leaderIdx = l:col - 1

    while l:leaderIdx >= 0
	if l:line[l:leaderIdx] == '\' || l:line[l:leaderIdx] == ';'
	    let l:token = slice(l:line, l:leaderIdx + 1, l:col - 1)
	    if l:token =~ '\W' || strlen(l:token) == 0
		return a:trigger
	    endif

	    let l:leader = l:line[l:leaderIdx]

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
		if l:macro =~ "^".l:token.'\w*'
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

    return a:trigger
endfunction

inoremap <space> <c-r>=GetMapping("<c-v><space>")<cr>
inoremap <cr> <c-r>=GetMapping("<c-v><cr>")<cr>
