call IMAP("\\doc\<cr>", "\\begin{document}\n<++>\n\\end{document}", "tex")
call IMAP('\sec ', "\\section{<++>}\n<++>", "tex")
call IMAP('\ssec ', "\\subsection{<++>}\n<++>", "tex")
call IMAP('\sssec ', "\\subsubsection{<++>}\n<++>", "tex")
call IMAP('\para ',
      \ '\paragraph{<++>} <++>', "tex")

call IMAP("\\math\<cr>",
      \ "\\begin{displaymath}\n<++>\n\\end{displaymath}", "tex")
call IMAP("\\eqn\<cr>", "\\begin{equation}\n<++>\n\\end{equation}", "tex")
call IMAP("\\align\<cr>", "\\begin{align}\n<++>\n\\end{align}", "tex")
call IMAP("\\eqns\<cr>",
      \ "\\begin{equation*}\n<++>\n\\end{equation*}", "tex")
call IMAP("\\aligns\<cr>", "\\begin{align*}\n<++>\n\\end{align*}", "tex")

call IMAP("\\enum\<cr>", "\\begin{enumerate}\n\\item <++>\n\\end{enumerate}", "tex")
call IMAP("\\item\<cr>",
      \ "\\begin{itemize}\n\\item <++>\n\\end{itemize}", "tex")

call IMAP('\i ', '\item <++>', "tex")

call IMAP('\b ', '\boldsymbol ', "tex")
call IMAP('\mb ', '\mathbf{<++>}<++>', "tex")
call IMAP('\mr ', '\mathrm{<++>}<++>', "tex")
call IMAP('\ms ', '\mathscr{<++>}<++>', "tex")
call IMAP('\tb ', '\textbf{<++>}<++>', "tex")
call IMAP('\ti ', '\textit{<++>}<++>', "tex")
call IMAP('\em ', '\emph{<++>}<++>', "tex")
call IMAP('\t ', '\text{<++>}<++>', "tex")

call IMAP('\cite ', '\cite{<++>}<++>', "tex")
call IMAP('\ref ', '\ref{<++>}<++>', "tex")
call IMAP('\href ', '\hyperref{<++>}<++>', "tex")
