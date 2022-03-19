# dave-white/vim-latex

My fork of the [`vim-latex` 
plugin](https://github.com/vim-latex/vim-latex).

## Changes from the original

### Architecture

1. The bulk of the functions are moved to scripts in `autoload/tex/`. For 
   the most part, `autoload` script files correspond to those under 
   `ftplugin/latex-suite/` in the original, but I've shortened names here 
   and there.

2. Global variables in the original become script variables in the 
   `autoload` scripts here, and the `ftplugin` now exclusively sets buffer 
   variables. Each `autoload` script is to open with a segment in which the 
   `ftplugin` buffer variable corresponding to each script variable is 
   checked; if it exists/is populated, then the script variable is given 
   the buffer value. This code looks as follows:

       if exists("b:tex_<param>")
	 let s:<param> = b:tex_<param>
       else
	 let s:<param> = <default_val>
       endif

   I haven't yet fulfilled this everywhere.

3. Rules for compiling to a particular target file type are to be located 
   in scripts with names like `tex2<targ>.vim` under `compiler/` as much as 
   practicable. Buffer variables may be used here for runtime 
   customization, and some may be set here. When the `ftplugin` is loaded, 
   these compiling rules can then be set via the `vim` command `:compiler`.
   
   I've only done this for the `pdf` target so far, and the script is a bit 
   messy.

4. The `IMAP` plugin is not specific to the `tex` file type, hence should 
   be, in my humble opinion, a standalone plugin. I've accordingly removed 
   it from my forked ftplugin.

### Functionality

1. Compiling/Viewing: I've rewritten what was mostly contained in 
   `Tex_RunLatex()`, `Tex_CompileLatex()` and `Tex_CompileMultipleTimes()`, 
   and made some changes to what was in `Tex_ViewLatex()`&mdash;partly to 
   speed things up (which I may or may not have achieved), partly to take 
   advantage of more of what `pdflatex` can do, and partly to avoid running 
   steps which are unnecessary in a particular instance.  In particular:

   -  The code is now aware of the use of the `-output-directory` and 
      `-jobname` options for `pdflatex` via the vim settings 
      `b:tex_outpdir` and `b:tex_jobnm`, resp.

   -  Nothing is done if the `tex` file (which is now written to right at 
      the start of the process) is older than its associated `aux` file.  
      The BibLaTeX "backend" (`biber` by default) is only run if the `bcf` 
      file is updated, and it gets its input/output from `pdflatex`'s 
      output directory if applicable.

   -  The `autoload` function `tex#compiler#View()` (replacing 
      `Tex_ViewLatex()`) opens the target file from `pdflatex`'s output 
      directory if applicable.

2. `imap`s: The `IMAP` plugin provided with the original ftplugin is great, 
   and I continue employing it for a number of things in this fork (with 
   the goal of eventually removing it entirely), but most `LaTeX` 
   constructs it just isn't exactly to my taste.  I've added my own 
   `autoload` code in `tex/imap.vim` to provide what I call "running 
   `imap`s", i.e. those which operate on multiple consecutive characters 
   while allowing those characters to be printed normally. My way of 
   implementing this fires the mapping when one of a small set of 
   triggering characters is typed: `<space>`, `<tab>` or `<cr>` at the 
   moment. This contrasts with `IMAP`'s mapping of every character which 
   terminates some mapped sequence.

### Code

I've jettisoned a few helper functions and restructured some things along 
the way. I may come to regret doing so, but I'd like to see how far I 
simplify things.

#### Naming

-  Moving code under `autoload/tex/` obviates the use of the prefix `Tex_` 
   from the original ftplugin to avoid naming collisions with other 
   plugins. Such a prefix should be retained, however, for all buffer 
   variables and for any functions which for some reason need to be kept at 
   the `ftplugin` level.

   I haven't yet removed that prefix across all the code.

-  I like my variables to begin in lowercase, so the buffer variables 
   holding the ftplugin's settings look like 
   `b:tex_<lowercase_char><rest_of_name>`. As for the rest, I'm very 
   indecisive; what I've got is a mix of camelCase, underscores and stuff 
   crammed into single "words". I really ought to come up with a convention 
   for this.

## TODO

1. This fork is horrifyingly lacking in documentation and code comments, 
   and files have lost their header text (giving info such as authorship, 
   licensing, etc.) in the shuffling.

2. Finish renaming things. (Cf. [Naming](#naming))

2. Pull out the remaining uses of the `IMAP` plugin. Users should be able 
   to enable `IMAP` independently of this ftplugin.

3. Probably all functionality which I don't use has been broken by my 
   changes and I just don't know it yet. These bugs will need to be tested 
   for and fixed.

