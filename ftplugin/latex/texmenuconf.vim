"===========================================================================
"        File: texmenuconf.vim
"      Author: Srinath Avadhanula
"   Copyright: Vim charityware license. :help license
" Description: 
" 
"===========================================================================

" Paths, crucial for functions
let s:mainMenuNm = b:tex_menuPrefix.'S&uite.'
let s:mapleader = exists('mapleader') ? mapleader : "\\"

" This glboal variable is incremented each time a top-level latex-suite 
" menu is created. We should always use this variable for setting the 
" locations of newly created top-level menus.
let b:tex_nextMenuLoc = b:tex_mainMenuLoc

" The templates and macros menus are always nested within the main 
" latex-suit menu.
let b:tex_templateMenuLoc = b:tex_mainMenuLoc.'.20 '.s:mainMenuNm.'&Templates.'
let b:tex_macroMenuLoc = b:tex_mainMenuLoc.'.20 '.s:mainMenuNm.'&Macros.'

" The packages menu can either be a child of the main menu or be a top-level
" menu by itself.
if b:tex_nestPkgMenu
  let b:tex_pkgMenuLoc = b:tex_mainMenuLoc.'.10 '.s:mainMenuNm.'&Packages.'
else
  let b:tex_pkgMenuLoc = b:tex_nextMenuLoc.'.10 '.b:tex_menuPrefix.'Packages.'
  let b:tex_nextMenuLoc = b:tex_nextMenuLoc + 1
endif

" Environments are always a top-level menu.
let b:tex_envMenuLoc= b:tex_nextMenuLoc.'.20 '.b:tex_menuPrefix.'E&nvironments.'
let b:tex_nextMenuLoc = b:tex_nextMenuLoc + 1

" Elements are always a top-level menu.  If we choose to nest elements, 
" then the top-level &TeX-Elements menu contains <Fonts / Counters / 
" Dimensions> otherwise, the Fonts, Counters and Dimensions menus become 
" top-level menus.
if b:tex_nestEltMenus
  let b:tex_eltMenuLoc = b:tex_nextMenuLoc.'.20 '.b:tex_menuPrefix.'E&lements.'
else
  let b:tex_eltMenuLoc = b:tex_nextMenuLoc.'.20 '.b:tex_menuPrefix
endif
let b:tex_nextMenuLoc = b:tex_nextMenuLoc + 1

" configuration menu.
if b:tex_menus
  exe 'amenu '.b:tex_mainMenuLoc.'.900 '.s:mainMenuNm.'Configure\ Menu.Add\ Math\ Menu         :call tex#menu#ConfigMenu("math", 1)<cr>'
  exe 'amenu '.b:tex_mainMenuLoc.'.900 '.s:mainMenuNm.'Configure\ Menu.Remove\ Math\ Menu      :call tex#menu#ConfigMenu("math", 0)<cr>'
  exe 'amenu '.b:tex_mainMenuLoc.'.900 '.s:mainMenuNm.'Configure\ Menu.Expand\ Elements        :call tex#menu#ConfigMenu("elements", "expand")<cr>'
  exe 'amenu '.b:tex_mainMenuLoc.'.900 '.s:mainMenuNm.'Configure\ Menu.Compress\ Elements      :call tex#menu#ConfigMenu("elements", "nest")<cr>'
  exe 'amenu '.b:tex_mainMenuLoc.'.900 '.s:mainMenuNm.'Configure\ Menu.Load\ Packages\ Menu    :call tex#menu#ConfigMenu("packages", 1)<cr>'

  if has('gui_running')
    exe 'anoremenu '.b:tex_mainMenuLoc.'.25 '. s:mainMenuNm.'-sepsuite0-  :'

    " menus for compiling / viewing etc.
    exe 'anoremenu '.b:tex_mainMenuLoc.'.30 '.s:mainMenuNm.'&Compile<tab>'.s:mapleader.'ll'.
	  \'   :silent! call Tex_RunLaTeX()<CR>'
    exe 'anoremenu '.b:tex_mainMenuLoc.'.40 '.s:mainMenuNm.'&View<tab>'.s:mapleader.'lv'.
	  \'   :silent! call Tex_ViewLaTeX()<CR>'
    exe 'anoremenu '.b:tex_mainMenuLoc.'.50 '.s:mainMenuNm.'&Search<tab>'.s:mapleader.'ls'.
	  \'   :silent! call ForwardSearchLaTeX()<CR>'
    exe 'anoremenu '.b:tex_mainMenuLoc.'.60 '.s:mainMenuNm.'&Target\ Format<tab>:TTarget'.
	  \'   :call SetTeXTarget()<CR>'
    exe 'anoremenu '.b:tex_mainMenuLoc.'.70 '.s:mainMenuNm.'&Compiler\ Target<tab>:TCTarget'.
	  \'   :call Tex_SetTeXCompilerTarget("Compile", "")<CR>'
    exe 'anoremenu '.b:tex_mainMenuLoc.'.80 '.s:mainMenuNm.'&Viewer\ Target<tab>:TVTarget'.
	  \'   :call Tex_SetTeXCompilerTarget("View", "")<CR>'
    exe 'anoremenu '.b:tex_mainMenuLoc.'.90 '.s:mainMenuNm.'Set\ &Ignore\ Level<tab>:TCLevel'.
	  \'   :TCLevel<CR>'
    exe 'imenu '.b:tex_mainMenuLoc.'.100 '.s:mainMenuNm.'C&omplete\ Ref/Cite'.
	  \'   <Plug>Tex_Completion'
    exe 'anoremenu '.b:tex_mainMenuLoc.'.110 '.s:mainMenuNm.'-sepsuite1- :'
    " refreshing folds
    if b:tex_folding
      exe 'anoremenu '.b:tex_mainMenuLoc.'.120 '.s:mainMenuNm.'&Refresh\ Folds<tab>'.s:mapleader.'rf'.
	    \'   :call MakeTexFolds(1)<CR>'
      exe 'anoremenu '.b:tex_mainMenuLoc.'.130 '.s:mainMenuNm.'-sepsuite2- :'
    endif
  endif
endif

" vim:fdm=marker:ff=unix:noet
