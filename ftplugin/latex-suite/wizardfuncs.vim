"        File: wizardfuncs.vim
"      Author: Mikolaj Machowski <mikmach@wp.pl>
" Description: 
" 
" Installation:
"      History: pluginized by Srinath Avadhanula
"===========================================================================

if exists('s:doneOnce')
  finish
endif
let s:doneOnce = 1

let s:mapleader = exists('mapleader') ? mapleader : "\\"
" ==========================================================================
" Specialized functions for handling sections from command line
" ==========================================================================

com! -nargs=? TSection call Tex_section(<f-args>)
com! -nargs=? TSectionAdvanced call Tex_section_adv(<f-args>)

" Tex_VisSecAdv: handles visual selection for sections {{{
func! Tex_VisSecAdv(section)
  let shorttitle =  input("Short title? ")
  let toc = input("Include in table of contents [y]/n ? ")
  let sstructure = "\\".a:section
  if ( toc == "" || toc == "y" )
	let toc = ""
  else
	let toc = "*"
  endif
  if shorttitle != ""
	let shorttitle = '['.shorttitle.']'
  endif
  exe "normal! `>a}\<cr>\<esc>`<i".sstructure.toc.shorttitle."{"
endfunc 

" }}}
" Tex_InsSecAdv: section wizard in insert mode {{{
func! Tex_InsSecAdv(structure)
  let ttitle = input("Title? ")
  let shorttitle =  input("Short title? ")
  let toc = input("Include in table of contents [y]/n ? ")
  "Structure
  let sstructure = "\\".a:structure
  "TOC
  if ( toc == "" || toc == "y" )
	let toc = ""
  else
	let toc = "*"
  endif
  "Shorttitle
  if shorttitle != ""
	let shorttitle = '['.shorttitle.']'
  endif
  "Title
  let ttitle = '{'.ttitle.'}'
  "Happy end?
  return sstructure.toc.shorttitle.ttitle 
endfunc 

" }}}
func! Tex_section(...) "{{{
  silent let pos = Tex_GetPos()
  silent let last_section_value = s:tex_section_detection()
  if a:0 == 0
	silent let last_section_name = s:tex_section_name(last_section_value)
	silent call s:tex_section_call(last_section_name)
  elseif a:1 =~ "[+=\-]"
	silent let sec_arg = a:1
	silent let curr_section_value = s:tex_section_curr_rel_value(sec_arg, last_section_value)
	silent let curr_section_name = s:tex_section_name(curr_section_value)
	silent call s:tex_section_call(curr_section_name)
  elseif a:1 == "?"
	echo s:last_section_line
  else
	silent let curr_section_value = s:tex_section_curr_value(a:1)
	silent let curr_section_name = s:tex_section_name(curr_section_value)
	silent call s:tex_section_call(curr_section_name)
  endif
  silent call Tex_SetPos(pos)
endfunc
" }}}
func! Tex_section_adv(...) "{{{
  let pos = Tex_GetPos()
  silent let last_section_value = s:tex_section_detection()
  if a:0 == 0
	silent let last_section_name = s:tex_section_name(last_section_value)
	let section = Tex_InsSecAdv(last_section_name)
  elseif a:1 =~ "[+=\-]"
	silent let sec_arg = a:1
	silent let curr_section_value = s:tex_section_curr_rel_value(sec_arg, last_section_value)
	silent let curr_section_name = s:tex_section_name(curr_section_value)
	let section = Tex_InsSecAdv(curr_section_name)
  else
	silent let curr_section_value = s:tex_section_curr_value(a:1)
	silent let curr_section_name = s:tex_section_name(curr_section_value)
	silent call s:tex_section_call(curr_section_name)
	let section = Tex_InsSecAdv(curr_section_name)
  endif
  exe "normal! i".section
  call Tex_SetPos(pos)
endfunc
" }}}
func! s:tex_section_detection() "{{{
  let pos = Tex_GetPos()
  let last_section = search("\\\\part\\|\\\\chapter\\|\\\\section\\|\\\\subsection\\|\\\\subsubsection\\|\\\\paragraph\\|\\\\subparagraph", "bW")
  if last_section != 0
	exe last_section
	if getline(".") =~ "\\\\part"
	  let last_section_value = 0
	elseif getline(".") =~ "\\\\chapter"
	  let last_section_value = 1
	elseif getline(".") =~ "\\\\section"
	  let last_section_value = 2
	elseif getline(".") =~ "\\\\subsection"
	  let last_section_value = 3
	elseif getline(".") =~ "\\\\subsubsection"
	  let last_section_value = 4
	elseif getline(".") =~ "\\\\paragraph"
	  let last_section_value = 5
	elseif getline(".") =~ "\\\\subparagraph"
	  let last_section_value = 6
	endif
	let s:last_section_line = getline(".")
  else
	let last_section_value = 0
  endif
  call Tex_SetPos(pos)
  return last_section_value
endfunc
" }}}
func! s:tex_section_curr_value(sec_arg) "{{{
  if a:sec_arg == "pa" || a:sec_arg == "0" || a:sec_arg == "part"
	let curr_section_value = 0
  elseif a:sec_arg == "ch" || a:sec_arg == "1" || a:sec_arg == "chapter"
	let curr_section_value = 1
  elseif a:sec_arg == "se" || a:sec_arg == "2" || a:sec_arg == "section"
	let curr_section_value = 2
  elseif a:sec_arg == "ss" || a:sec_arg == "3" || a:sec_arg == "subsection"
	let curr_section_value = 3
  elseif a:sec_arg == "s2" || a:sec_arg == "4" || a:sec_arg == "subsubsection"
	let curr_section_value = 4
  elseif a:sec_arg == "pr" || a:sec_arg == "5" || a:sec_arg == "paragraph"
	let curr_section_value = 5
  elseif a:sec_arg == "sp" || a:sec_arg == "6" || a:sec_arg == "subparagraph"
	let curr_section_value = 6
  endif
  return curr_section_value
endfunc
" }}}
func! s:tex_section_curr_rel_value(sec_arg, last_section_value) "{{{
  let last_section_value = a:last_section_value
  if a:sec_arg == "+" || a:sec_arg == "+1"
	let curr_section_value = last_section_value + 1
  elseif a:sec_arg == "++" || a:sec_arg == "+2"
	let curr_section_value = last_section_value + 2
  elseif a:sec_arg == "-" || a:sec_arg == "-1"
	let curr_section_value = last_section_value - 1
  elseif a:sec_arg == "--" || a:sec_arg == "-2"
	let curr_section_value = last_section_value - 2
  elseif a:sec_arg == "="
	let curr_section_value = last_section_value
  else
	exe "let curr_section_value = last_section_value".a:sec_arg
  endif
  if curr_section_value < 0
	let curr_section_value = 0
  elseif curr_section_value > 6
	let curr_section_value = 6
  endif
  return curr_section_value
endfunc
" }}}
func! s:tex_section_name(section_value) "{{{
  if a:section_value == 0
	let section_name = "part"
  elseif a:section_value == 1
	let section_name = "chapter"
  elseif a:section_value == 2
	let section_name = "section"
  elseif a:section_value == 3
	let section_name = "subsection"
  elseif a:section_value == 4
	let section_name = "subsubsection"
  elseif a:section_value == 5
	let section_name = "paragraph"
  elseif a:section_value == 6
	let section_name = "subparagraph"
  endif
  return section_name
endfunc
" }}}
func! s:tex_section_call(section_name) "{{{
  exe "normal! i\\".a:section_name."{<++>}<++>\<Esc>0\<C-j>"
  "	let ret_section = "\\".a:section_name."{<++>}<++>"
  "	exe "normal! i\<C-r>=IMAP_PutTextWithMovement(ret_section)\<CR>"
  "	normal! f}i
endfunc
" }}}

" ==========================================================================
" Tables of shortcuts
" ==========================================================================

command! -nargs=? Tshortcuts call Tex_shortcuts(<f-args>)

" Tex_shortcuts: Show shortcuts in terminal after : command {{{
func! Tex_shortcuts(...)
  if a:0 == 0
	let shorts = input(" Allowed arguments are:"
		  \."\n g     General"
		  \."\n e     Environments"
		  \."\n f     Fonts"
		  \."\n s     Sections"
		  \."\n m     Math"
		  \."\n a     All"
		  \."\n Enter your choice (<Enter> quits) : ")
	call Tex_shortcuts(shorts)
  elseif a:1 == 'g'
	echo g:generalshortcuts
  elseif a:1 == 'e'
	echo g:environmentshortcuts
  elseif a:1 == 'f'
	echo g:fontshortcuts
  elseif a:1 == 's'
	echo g:sectionshortcuts
  elseif a:1 == 'm'
	echo g:mathshortcuts
  elseif a:1 == 'a'
	echo g:generalshortcuts
	echo g:environmentshortcuts
	echo g:fontshortcuts
	echo g:sectionshortcuts
	echo g:mathshortcuts
  endif

endfunc
" }}}

" General shortcuts {{{
let g:generalshortcuts = ''
	  \."\n General shortcuts"
	  \."\n <mapleader> is a value of <Leader>"
	  \."\n ".s:mapleader.'ll	compile whole document'
	  \."\n ".s:mapleader.'lv	view compiled document'
	  \."\n ".s:mapleader.'ls	forward searching (if possible)'
	  \."\n ".s:mapleader.'rf	refresh folds'
" }}}
" Environment shortcuts {{{
let g:environmentshortcuts = ''
	  \."\n Environment shortcuts"
	  \."\n <mapleader> is a value of g:tex_leader2"
	  \."\n I     v&V                       I     v&V"
	  \."\n ELI   ".g:tex_leader2."li   list                EQN   ".g:tex_leader2."qn   quotation"
	  \."\n EDE   ".g:tex_leader2."de   description         ESP   ".g:tex_leader2."sb   sloppypar"
	  \."\n EEN   ".g:tex_leader2."en   enumerate           ETI   ".g:tex_leader2."ti   theindex"
	  \."\n EIT   ".g:tex_leader2."it   itemize             ETP   ".g:tex_leader2."tp   titlepage"
	  \."\n ETI   ".g:tex_leader2."ti   theindex            EVM   ".g:tex_leader2."vm   verbatim"
	  \."\n ETL   ".g:tex_leader2."tl   trivlist            EVE   ".g:tex_leader2."ve   verse"
	  \."\n ETE   ".g:tex_leader2."te   table               ETB   ".g:tex_leader2."tb   thebibliography"
	  \."\n ETG   ".g:tex_leader2."tg   tabbing             ENO   ".g:tex_leader2."no   note"
	  \."\n ETR   ".g:tex_leader2."tr   tabular             EOV   ".g:tex_leader2."ov   overlay"
	  \."\n EAR   ".g:tex_leader2."ar   array               ESL   ".g:tex_leader2."sl   slide"
	  \."\n EDM   ".g:tex_leader2."dm   displaymath         EAB   ".g:tex_leader2."ab   abstract"
	  \."\n EAL   ".g:tex_leader2."al   align               EAP   ".g:tex_leader2."ap   appendix"
	  \."\n EEQ   ".g:tex_leader2."eq   equation            ECE   ".g:tex_leader2."ce   center"
	  \."\n EDO   ".g:tex_leader2."do   document            EFI   ".g:tex_leader2."fi   figure"
	  \."\n EFC   ".g:tex_leader2."fc   filecontents        ELR   ".g:tex_leader2."lr   lrbox"
	  \."\n EFL   ".g:tex_leader2."fl   flushleft           EMP   ".g:tex_leader2."mp   minipage"
	  \."\n EFR   ".g:tex_leader2."fr   flushright          EPI   ".g:tex_leader2."pi   picture"
	  \."\n EMA   ".g:tex_leader2."ma   math                EQE   ".g:tex_leader2."qe   quote"
" }}}
" Font shortcuts {{{
let g:fontshortcuts = ''
	  \."\n Font shortcuts"
	  \."\n <mapleader> is a value of g:tex_leader"
	  \."\n Shortcuts         Effects"
	  \."\n I        v&V      I&v               V"
	  \."\n FBF      ".g:tex_leader."bf      \\textbf{}         {\\bfseries }"
	  \."\n FMD      ".g:tex_leader."md      \\textmd{}         {\\mdseries }"
	  \."\n"
	  \."\n FTT      ".g:tex_leader."tt      \\texttt{}         {\\ttfamily }"
	  \."\n FSF      ".g:tex_leader."sf      \\textsf{}         {\\sffamily }"
	  \."\n FRM      ".g:tex_leader."rm      \\textrm{}         {\\rmfamily }"
	  \."\n"
	  \."\n FUP      ".g:tex_leader."up      \\textup{}         {\\upshape }"
	  \."\n FSL      ".g:tex_leader."sl      \\textsl{}         {\\slshape }"
	  \."\n FSC      ".g:tex_leader."sc      \\textsc{}         {\\scshape }"
	  \."\n FIT      ".g:tex_leader."it      \\textit{}         {\\itshape }"
" }}}
" Section shortcuts {{{
let g:sectionshortcuts = ''
	  \."\n Section shortcuts"
	  \."\n <mapleader> is a value of g:tex_leader2"
	  \."\n I     v&V"
	  \."\n SPA   ".g:tex_leader2."pa   part"
	  \."\n SCH   ".g:tex_leader2."ch   chapter"
	  \."\n SSE   ".g:tex_leader2."se   section"
	  \."\n SSS   ".g:tex_leader2."ss   subsection"
	  \."\n SS2   ".g:tex_leader2."s2   subsubsection"
	  \."\n SPG   ".g:tex_leader2."pg   paragraph"
	  \."\n SSP   ".g:tex_leader2."sp   subparagraph"
" }}}
" Math shortcuts {{{
let g:mathshortcuts = ''
	  \."\n Math shortcuts - Insert mode"
	  \."\n `a     \\alpha            `b     \\beta"
	  \."\n `g     \\gamma            `d     \\delta"
	  \."\n `e     \\varepsilon       `z     \\zeta"
	  \."\n `h     \\eta              `q     \\theta"
	  \."\n `i     \\iota             `k     \\kappa"
	  \."\n `l     \\lambda           `m     \\mu"
	  \."\n `n     \\nu               `x     \\xi"
	  \."\n `p     \\pi               `r     \\rho"
	  \."\n `s     \\sigma            `v     \\varsigma"
	  \."\n `t     \\tau              `u     \\upsilon"
	  \."\n `f     \\varphi           `c     \\chi"
	  \."\n `y     \\psi              `w     \\omega"
	  \."\n `A     \\Alpha            `B     \\Beta"
	  \."\n `G     \\Gamma            `D     \\Delta"
	  \."\n `E     \\Epsilon          `Z     \\mathrm{Z}"
	  \."\n `H     \\Eta              `K     \\Kappa"
	  \."\n `L     \\Lambda           `M     \\Mu"
	  \."\n `N     \\Nu               `X     \\Xi"
	  \."\n `P     \\Pi               `R     \\Rho"
	  \."\n `S     \\Sigma            `T     \\Tau"
	  \."\n `U     \\Upsilon          `C     \\Chi"
	  \."\n `Y     \\Psi              `W     \\Omega"
	  \."\n `(     \\subset           `)     \\Subset"
	  \."\n `=     \\equiv            =~     \\approx"
	  \."\n `-     \\bigcap           `+     \\bigcup"
	  \."\n `.     \\cdot             `*     \\times"
	  \."\n `\\     \\setminus         `@     \\circ"
	  \."\n `&     \\wedge            `,     \\nonumber"
	  \."\n `8     \\infty            `_     \\bar{}"
	  \."\n `:     \\ddot{}           `;     \\dot{}"
	  \."\n `^     \\hat{}            `~     \\tilde{}"
	  \."\n `6     \\partial"
" }}}

" vim:fdm=marker:ff=unix:noet
