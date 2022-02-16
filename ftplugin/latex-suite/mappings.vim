let s:imapDictSp = {
      \ "s": "\\section{<++>}\n<++>",
      \ "ss": "\\subsection{<++>}\n<++>",
      \ "sss": "\\subsubsection{<++>}\n<++>",
      \ "para": "\\paragraph{<++>} <++>",
      \ "i": "\\item <++>",
      \ "fr": "\\frametitle{<++>}\n<++>",
      \ "b": "\\boldsymbol <++>",
      \ "t": "\\text{<++>}<++>",
      \ "mb": "\\mathbf{<++>}<++>", 
      \ "mr": "\\mathrm{<++>}<++>", 
      \ "ms": "\\mathscr{<++>}<++>", 
      \ "tb": "\\textbf{<++>}<++>", 
      \ "ti": "\\textit{<++>}<++>", 
      \ "em": "\\emph{<++>}<++>", 
      \ "ci": "\\cite{<++>}<++>", 
      \ "re": "\\ref{<++>}<++>", 
      \ "hyperre": "\\hyperref{<++>}<++>", 
      \ }

let s:imapDictCR = {
      \ "d": "\\begin{document}\n<++>\n\\end{document}",
      \ "m": "\\begin{displaymath}\n<++>\n\\end{displaymath}",
      \ "eq": "\\begin{equation}\n<++>\n\\end{equation}",
      \ "eqs": "\\begin{equation*}\n<++>\n\\end{equation*}",
      \ "a": "\\begin{align}\n<++>\n\\end{align}",
      \ "as": "\\begin{align*}\n<++>\n\\end{align*}",
      \ "en": "\\begin{enumerate}\n\\item <++>\n\\end{enumerate}",
      \ "i": "\\begin{itemize}\n\\item <++>\n\\end{itemize}",
      \ "f": "\\begin{frame}\n<++>\n\\end{frame}\n<++>",
      \ }

function! GetMapping(trigger)
  let l:leader = "\\"
  let l:line = getline(".")
  let l:lastLeaderIdx = strridx(l:line, l:leader)

  if l:lastLeaderIdx < 0
    return a:trigger
  endif
  let l:token = slice(l:line, l:lastLeaderIdx + 1, col("."))
  if l:token =~ "\\W" || strlen(l:token) <= 0
    return a:trigger
  endif

  let l:imapDict = s:imapDictSp
  if a:trigger == "\<cr>"
    let l:imapDict = s:imapDictCR
  endif

  for [l:pat, l:res] in items(l:imapDict)
    if l:token =~ "^".l:pat."\\w*"
      let l:backspaces = ""
      let l:idx = 0
      while l:idx <= strlen(l:token)
	let l:idx += 1
	let l:backspaces .= "\<bs>"
      endwhile
      return l:backspaces."\<c-g>u" . IMAP_PutTextWithMovement(l:res, "<+", "+>")
    endif
  endfor
  return a:trigger
endfunction

inoremap <space> <c-r>=GetMapping("<c-v><space>")<cr>
inoremap <cr> <c-r>=GetMapping("<c-v><cr>")<cr>
