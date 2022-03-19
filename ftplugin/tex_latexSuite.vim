" LaTeX filetype
"   Language: LaTeX (ft=tex)
" Maintainer: Srinath Avadhanula
"      Email: srinath@fastmail.fm

if exists("b:did_tex_plugin") && b:did_tex_plugin
  finish
endif
let b:did_tex_plugin = 1

let s:save_cpo = &cpo
set cpo&vim

" TEXRC: Load user's settings. {{{
" Global settings.
runtime ftplugin/latex-suite/texvimrc
runtime ftplugin/tex/texvimrc

" Settings local to project.
let fpath = fnameescape(expand('%:p'))
let proj_texrc = tex#lib#FindFileAbove('texvimrc', fpath)
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

exe 'so '.fnameescape(expand('<sfile>:p:h')).'/latex-suite/setup.vim'

let &cpo = s:save_cpo

if b:tex_use_make
  setlocal makeprg=make
elseif b:tex_targ == "pdf"
  compiler tex2pdf
else
  compiler tex
endif

" vim:ft=vim:fdm=marker
