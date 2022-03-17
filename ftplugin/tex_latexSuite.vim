" LaTeX filetype
"   Language: LaTeX (ft=tex)
" Maintainer: Srinath Avadhanula
"      Email: srinath@fastmail.fm

if exists("b:did_tex_plugin") && b:did_tex_plugin == 1
  finish
endif
let b:did_tex_plugin = 1

let s:save_cpo = &cpo
set cpo&vim

" Tex_FindFileAbove: {{{
" Search up the path from current file's directory for file matching expr.
" Return str = absolute path to file matching expr
func Tex_FindFileAbove(xpr, ...)
  if a:0 < 1
    let curr_dir = fnameescape(expand('%:p:h'))
  else
    let curr_dir = fnameescape(fnamemodify(a:1, ':p:h'))
  endif

  let max_depth = 31
  let last_dir = ""
  let cnt = 0
  while (cnt < max_depth) && (curr_dir != last_dir)
    let cnt += 1
    let fpath = glob(curr_dir.'/'.a:xpr)
    if !empty(fpath)
      return fpath
    else
      let last_dir = curr_dir
      let curr_dir = fnameescape(fnamemodify(curr_dir, ':h'))
    endif
  endwhile
  return ""
endfunc
" }}}

let s:path = fnameescape(expand('<sfile>:p:h'))

" TEXRC: Set default global settings. {{{
exe "so ".s:path.'/latex-suite/texrc'
runtime ftplugin/tex/texrc
let s:loc_texrc = Tex_FindFileAbove('texrc', fnameescape(expand('%:p')))
if filereadable(s:loc_texrc)
  exe 'so '.s:loc_texrc
endif
" }}}

if !exists("g:did_tex_plugin") || g:did_tex_plugin != 1
  let g:did_tex_plugin = 1
  exe 'so '.fnameescape(expand('<sfile>:p:h').'/latex-suite/setup-glob.vim')
endif
exe 'so '.fnameescape(expand('<sfile>:p:h').'/latex-suite/setup-loc.vim')
let &cpo = s:save_cpo

silent compiler tex

" vim:ft=vim:fdm=marker
