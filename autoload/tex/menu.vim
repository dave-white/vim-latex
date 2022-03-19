"===========================================================================
"        File: texmenuconf.vim
"      Author: Srinath Avadhanula
"   Copyright: Vim charityware license. :help license
" Description: 
" 
"===========================================================================

" Paths, crucial for functions
let s:path = fnameescape(expand("<sfile>:p:h"))
let s:mainMenuNm = b:tex_menuPrefix.'S&uite.'

" ==========================================================================
" MenuConf: configure the menus as compact/extended, with/without math
" ==========================================================================
func! tex#menu#ConfigMenu(type, action) " {{{
  let menuloc = s:mainMenuNm.'Configure\ Menu.'
  if a:type == 'math'
    if a:action == 1
      let b:tex_mathMenus = 1
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
      let b:tex_eltMenuLoc = '80.20 '.b:tex_menuPrefix
      exe 'amenu disable '.menuloc.'Expand\ Elements'
      exe 'amenu enable '.menuloc.'Compress\ Elements'
    elseif a:action == 'nest'
      let b:tex_eltMenuLoc = '80.20 '.b:tex_menuPrefix.'Elements.'
      exe 'amenu enable '.menuloc.'Expand\ Elements'
      exe 'amenu disable '.menuloc.'Compress\ Elements'
    endif
    exe 'source '.fnameescape(s:path.'/elementmacros.vim')
  elseif a:type == 'packages'
    if a:action == 1
      let b:tex_packagesMenu = 1
      exe 'source '.s:path.'/packages.vim'
      exe 'amenu disable '.menuloc.'Load\ Packages\ Menu'
    endif
  endif
endfunc
" }}}

" vim:fdm=marker:ff=unix:noet
