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

let s:path = fnameescape(expand('<sfile>:p:h'))

" TEXRC: Load user's settings. {{{
" Global settings.
runtime ftplugin/tex/texrc

" Tex_FindFileAbove: {{{
" Search up the path from current file's directory for file matching expr.
" Return str = absolute path to file matching expr
if !exists("g:did_tex_plugin") || g:did_tex_plugin != 1

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

endif
" }}}

" Settings local to project.
let fpath = fnameescape(expand('%:p'))
let proj_texrc = Tex_FindFileAbove('texrc', fpath)
if filereadable(proj_texrc)
  exe 'so '.proj_texrc
endif
" Settings local to tex file.
let fpath_r = fnameescape(expand('%:p:r'))
let file_texrc = glob(fpath_r.".vim")
if filereadable(file_texrc)
  exe 'so '.file_texrc
endif
" }}}

if !exists("g:did_tex_plugin") || g:did_tex_plugin != 1
  exe 'so '.s:path.'/latex-suite/setup-glob.vim'
endif
let g:did_tex_plugin = 1

exe 'so '.s:path.'/latex-suite/setup-loc.vim'

let &cpo = s:save_cpo

if b:tex_targ == "pdf"
  compiler tex-pdf
else
  compiler tex
endif

" vim:ft=vim:fdm=marker
