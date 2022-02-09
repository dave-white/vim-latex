# dave-white/vim-latex

My personal version of the `vim-latex` plugin.

See the repo of the original 
[vim-latex](https://github.com/vim-latex/vim-latex) to know everything not 
covered here.

## Changes

- The following parameters have been added to `texrc`:
   -  `g:Tex_OutputDir` -- given to `pdflatex` parameter 
      `-output-directory`;
   -  `g:Tex_JobName` -- given to `pdflatex` parameter `-jobname`;
These are used in `compiler.vim to locate required output/auxiliary file 
(suchas when viewing the PDF or running `biber`).

-  I've added code to `main.vim` to locate whatever the user specifies in 
   `g:Tex_MainFileExpression` by climbing up the file path from whatever is 
   currently open.

-  I've added code to `main.vim` to `source` a "project-specific" `texrc` 
   instance. It searches for the latter successively in each directory above
   the current file along its (absolute) path; similarly to the last item.

