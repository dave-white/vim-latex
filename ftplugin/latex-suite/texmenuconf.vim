"===========================================================================
"        File: texmenuconf.vim
"      Author: Srinath Avadhanula
"   Copyright: Vim charityware license. :help license
" Description: 
" 
"===========================================================================

" Paths, crucial for functions
let s:path = fnameescape(expand("<sfile>:p:h"))
let s:up_path = fnameescape(expand("<sfile>:p:h:h"))
let s:mainMenuNm = g:tex_menuPrefix.'S&uite.'
let s:mapleader = exists('mapleader') ? mapleader : "\\"

" This glboal variable is incremented each time a top-level latex-suite menu
" is created. We should always use this variable for setting the locations of
" newly created top-level menus.
let g:tex_nextMenuLoc = g:tex_mainMenuLoc

" The templates and macros menus are always nested within the main latex-suit
" menu.
let g:tex_templateMenuLoc = g:tex_mainMenuLoc.'.20 '.s:mainMenuNm.'&Templates.'
let g:tex_macroMenuLoc = g:tex_mainMenuLoc.'.20 '.s:mainMenuNm.'&Macros.'

" The packages menu can either be a child of the main menu or be a top-level
" menu by itself.
if g:tex_nestPkgMenu
  let g:tex_pkgMenuLoc = (g:tex_mainMenuLoc).'.10 '.s:mainMenuNm.'&Packages.'
else
  let g:tex_pkgMenuLoc = (g:tex_nextMenuLoc).'.10 '.g:tex_menuPrefix.'Packages.'
  let g:tex_nextMenuLoc = g:tex_nextMenuLoc + 1
endif

" Environments are always a top-level menu.
let g:tex_envMenuLoc= (g:tex_nextMenuLoc).'.20 '.g:tex_menuPrefix.'E&nvironments.'
let g:tex_nextMenuLoc = g:tex_nextMenuLoc + 1

" Elements are always a top-level menu. 
" If we choose to nest elements, then the top-level &TeX-Elements menu
" contains <Fonts / Counters / Dimensions>
" otherwise, the Fonts, Counters and Dimensions menus become top-level menus.
if g:tex_nestEltMenus
  let g:tex_eltMenuLoc = (g:tex_nextMenuLoc).'.20 '.g:tex_menuPrefix.'E&lements.'
else
  let g:tex_eltMenuLoc = (g:tex_nextMenuLoc).'.20 '.g:tex_menuPrefix
endif
let g:tex_nextMenuLoc = g:tex_nextMenuLoc + 1


" Set up the compiler/viewer menus. {{{
"
if has('gui_running') && g:tex_menus
  exec 'anoremenu '.g:tex_mainMenuLoc.'.25 '. s:mainMenuNm.'-sepsuite0-  :'

  " menus for compiling / viewing etc.
  exec 'anoremenu '.g:tex_mainMenuLoc.'.30 '.s:mainMenuNm.'&Compile<tab>'.s:mapleader.'ll'.
		\'   :silent! call Tex_RunLaTeX()<CR>'
  exec 'anoremenu '.g:tex_mainMenuLoc.'.40 '.s:mainMenuNm.'&View<tab>'.s:mapleader.'lv'.
		\'   :silent! call Tex_ViewLaTeX()<CR>'
  exec 'anoremenu '.g:tex_mainMenuLoc.'.50 '.s:mainMenuNm.'&Search<tab>'.s:mapleader.'ls'.
		\'   :silent! call ForwardSearchLaTeX()<CR>'
  exec 'anoremenu '.g:tex_mainMenuLoc.'.60 '.s:mainMenuNm.'&Target\ Format<tab>:TTarget'.
		\'   :call SetTeXTarget()<CR>'
  exec 'anoremenu '.g:tex_mainMenuLoc.'.70 '.s:mainMenuNm.'&Compiler\ Target<tab>:TCTarget'.
		\'   :call Tex_SetTeXCompilerTarget("Compile", "")<CR>'
  exec 'anoremenu '.g:tex_mainMenuLoc.'.80 '.s:mainMenuNm.'&Viewer\ Target<tab>:TVTarget'.
		\'   :call Tex_SetTeXCompilerTarget("View", "")<CR>'
  exec 'anoremenu '.g:tex_mainMenuLoc.'.90 '.s:mainMenuNm.'Set\ &Ignore\ Level<tab>:TCLevel'.
		\'   :TCLevel<CR>'
  exec 'imenu '.g:tex_mainMenuLoc.'.100 '.s:mainMenuNm.'C&omplete\ Ref/Cite'.
		\'   <Plug>Tex_Completion'
  exec 'anoremenu '.g:tex_mainMenuLoc.'.110 '.s:mainMenuNm.'-sepsuite1- :'
  " refreshing folds
  if g:tex_folding
	exec 'anoremenu '.g:tex_mainMenuLoc.'.120 '.s:mainMenuNm.'&Refresh\ Folds<tab>'.s:mapleader.'rf'.
		  \'   :call MakeTexFolds(1)<CR>'
	exec 'anoremenu '.g:tex_mainMenuLoc.'.130 '.s:mainMenuNm.'-sepsuite2- :'
  endif
endif

" }}}

" ==========================================================================
" MenuConf: configure the menus as compact/extended, with/without math
" ==========================================================================
func! Tex_MenuConfigure(type, action) " {{{
  let menuloc = s:mainMenuNm.'Configure\ Menu.'
  if a:type == 'math'
	if a:action == 1
	  let g:tex_mathMenus = 1
	  exe 'source '.s:path.'/mathmacros.vim'
	  exe 'amenu disable '.menuloc.'Add\ Math\ Menu'
	  exe 'amenu enable '.menuloc.'Remove\ Math\ Menu'
	elseif a:action == 0
	  call Tex_MathMenuRemove()
	  exe 'amenu enable '.menuloc.'Add\ Math\ Menu'
	  exe 'amenu disable '.menuloc.'Remove\ Math\ Menu'
	endif
  elseif a:type == 'elements'
	if a:action == 'expand'
	  let g:tex_eltMenuLoc = '80.20 '.g:tex_menuPrefix
	  exe 'amenu disable '.menuloc.'Expand\ Elements'
	  exe 'amenu enable '.menuloc.'Compress\ Elements'
	elseif a:action == 'nest'
	  let g:tex_eltMenuLoc = '80.20 '.g:tex_menuPrefix.'Elements.'
	  exe 'amenu enable '.menuloc.'Expand\ Elements'
	  exe 'amenu disable '.menuloc.'Compress\ Elements'
	endif
	exe 'source '.fnameescape(s:path.'/elementmacros.vim')
  elseif a:type == 'packages'
	if a:action == 1
	  let g:tex_packagesMenu = 1
	  exe 'source '.s:path.'/packages.vim'
	  exe 'amenu disable '.menuloc.'Load\ Packages\ Menu'
	endif
  endif
endfunc

" }}}

" configuration menu.
if g:tex_menus
  exe 'amenu '.g:tex_mainMenuLoc.'.900 '.s:mainMenuNm.'Configure\ Menu.Add\ Math\ Menu         :call Tex_MenuConfigure("math", 1)<cr>'
  exe 'amenu '.g:tex_mainMenuLoc.'.900 '.s:mainMenuNm.'Configure\ Menu.Remove\ Math\ Menu      :call Tex_MenuConfigure("math", 0)<cr>'
  exe 'amenu '.g:tex_mainMenuLoc.'.900 '.s:mainMenuNm.'Configure\ Menu.Expand\ Elements        :call Tex_MenuConfigure("elements", "expand")<cr>'
  exe 'amenu '.g:tex_mainMenuLoc.'.900 '.s:mainMenuNm.'Configure\ Menu.Compress\ Elements      :call Tex_MenuConfigure("elements", "nest")<cr>'
  exe 'amenu '.g:tex_mainMenuLoc.'.900 '.s:mainMenuNm.'Configure\ Menu.Load\ Packages\ Menu    :call Tex_MenuConfigure("packages", 1)<cr>'
endif

" vim:fdm=marker:ff=unix:noet
