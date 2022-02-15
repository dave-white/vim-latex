function! TurnOnMacro()
  let g:macro_on = 1
endfunction

call IUNMAP("@", "tex")
inoremap @ :call TurnOnMacro()<CR>

function s:var_len_imap(macro_name, min_len, trigger, result)
  let l:idx = a:min_len
  while l:idx <= strcharlen(a:macro_name)
    let s:short_macro_name = slice(a:macro_name, 0, l:idx)
    let l:idx += 1
    call IMAP("\\".s:short_macro_name.a:trigger, a:result, "tex")
  endwhile
endfunction

call s:var_len_imap("document", 3, "\<cr>",
      \ "\\begin{document}\n<++>\n\\end{document}")
call s:var_len_imap("section", 3, " ", "\\section{<++>}\n<++>")
call IMAP('\ssec ', "\\subsection{<++>}\n<++>", "tex")
call IMAP('\sssec ', "\\subsubsection{<++>}\n<++>", "tex")
call s:var_len_imap("paragraph", 4, " ", "\\paragraph{<++>} <++>")

call IMAP("\\math\<cr>",
      \ "\\begin{displaymath}\n<++>\n\\end{displaymath}", "tex")
call IMAP("\\eqn\<cr>", "\\begin{equation}\n<++>\n\\end{equation}", "tex")
call IMAP("\\align\<cr>", "\\begin{align}\n<++>\n\\end{align}", "tex")
call IMAP("\\eqns\<cr>",
      \ "\\begin{equation*}\n<++>\n\\end{equation*}", "tex")
call IMAP("\\aligns\<cr>", "\\begin{align*}\n<++>\n\\end{align*}", "tex")

call s:var_len_imap("enumerate", 4, "\<cr>",
      \ "\\begin{enumerate}\n\\item <++>\n\\end{enumerate}")
call IMAP("\\itemize\<cr>",
      \ "\\begin{itemize}\n\\item <++>\n\\end{itemize}", "tex")

call s:var_len_imap("item", 1, " ", "\\item <++>")

call s:var_len_imap("boldsymbol", 1, " ", "\\boldsymbol <++>")
call IMAP('\mb ', '\mathbf{<++>}<++>', "tex")
call IMAP('\mr ', '\mathrm{<++>}<++>', "tex")
call IMAP('\ms ', '\mathscr{<++>}<++>', "tex")
call IMAP('\tb ', '\textbf{<++>}<++>', "tex")
call IMAP('\ti ', '\textit{<++>}<++>', "tex")
call s:var_len_imap("emph", 2, " ", "\\emph{<++>}<++>")
call s:var_len_imap("text", 1, " ", "\\text{<++>}<++>")

call s:var_len_imap("cite", 1, " ", "\\cite{<++>}<++>")
call IMAP('\ref ', '\ref{<++>}<++>', "tex")
call IMAP('\href ', '\hyperref{<++>}<++>', "tex")
