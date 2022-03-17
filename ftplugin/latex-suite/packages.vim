"===========================================================================
" 	     File: packages.vim
"      Author: Mikolaj Machowski
"     Created: Tue Apr 23 06:00 PM 2002 PST
" 
"  Description: handling packages from within vim
"===========================================================================

" avoid reinclusion.
if !b:tex_pkgMenu || exists('s:doneOnce')
  finish
endif
let s:doneOnce = 1

let s:path = fnameescape(expand("<sfile>:p:h"))

if Tex_GetVarValue('Tex_EnvEndWithCR')
  let s:end_with_cr = "\<CR>"
else
  let s:end_with_cr = ""
endif

let s:menu_div = 20

com! -nargs=0 TPackageUpdate :silent! call Tex_pack_updateall(1)
com! -nargs=0 TPackageUpdateAll :silent! call Tex_pack_updateall(1)

" Custom command-line completion of Tcommands is very useful but this 
" feature is available only in Vim 6.2 and above. Check number of version 
" and choose proper command and function.
if v:version >= 602
  com! -complete=custom,Tex_CompletePackageName -nargs=* TPackage let s:retVal = Tex_pack_one(<f-args>) <bar> normal! i<C-r>=s:retVal<CR>

  " Tex_CompletePackageName: for completing names in TPackage command {{{
  "	Description: get list of package names with globpath(), remove full path
  "	and return list of names separated with newlines.
  "
  func! Tex_CompletePackageName(A,P,L)
	" Get name of packages from all runtimepath directories
	let pkgNms = Tex_FindInRtp('', 'packages')
	let pkgNms = substitute(packnames, '^,', '', 'e')
	" Separate names with \n not ,
	let pkgNms = substitute(packnames,',','\n','g')
	return pkgNms
  endfunc
  " }}}

else 
  com! -nargs=* TPackage let s:retVal = Tex_pack_one(<f-args>) <bar> normal! i<C-r>=s:retVal<CR>

endif

imap <silent> <plug> <Nop>
nmap <silent> <plug> i

let b:tex_pkgSupported = ''
let b:tex_pkgDetected = ''
" Remember the defaults because we want b:tex_promptEnvs to contain
" in addition to the default, \newenvironments, and the \newenvironments 
" might change...
let b:tex_promptEnvsDefault = b:tex_promptEnvs
let b:tex_promptCmdsDefault = b:tex_promptCmds


" Tex_pack_check: creates the package menu and adds to 'dict' setting. {{{
"
func! Tex_pack_check(package)
  " Use Tex_FindInRtp() function to get first name from packages list in all
  " rtp directories conforming with latex-suite directories hierarchy
  " Store names in variables to process functions only once.
  let pkgNm = Tex_FindInRtp(a:pkg, 'packages')
  if pkgNm != ''
	exe 'runtime! ftplugin/latex-suite/packages/' . a:pkg
	if has("gui_running")
	  call Tex_pack(a:pkg)
	endif
	if b:tex_pkgSupported !~ a:pkg
	  let b:tex_pkgSupported = b:tex_pkgSupported.','.a:pkg
	endif
  endif
  " Return full list of dictionaries (separated with ,) for package in &rtp
  call Tex_Debug("Tex_pack_check: searching for ".a:pkg." in dictionaries/ in &rtp", "pack")
  let dictname = Tex_FindInRtp(a:pkg, 'dictionaries', ':p')
  if dictname != ''
	exe 'setlocal dict^=' . dictname
	call Tex_Debug('Tex_pack_check: setlocal dict^=' . dictname, 'pack')
	if b:tex_pkgSupported !~ a:pkg
	  let b:tex_pkgSupported = b:tex_pkgSupported.','.a:pkg
	endif
  endif
  if b:tex_pkgDetected !~ '\<'.a:pkg.'\>'
	let b:tex_pkgDetected = b:tex_pkgDetected.','.a:pkg
  endif
  let b:tex_pkgDetected = substitute(b:tex_pkgDetected, '^,', '', '')
  let b:tex_pkgSupported = substitute(b:tex_pkgSupported, '^,', '', '')
endfunc

" }}}
" Tex_pack_uncheck: removes package from menu and 'dict' settings. {{{
func! Tex_pack_uncheck(package)
  if has("gui_running") && Tex_FindInRtp(a:pkg, 'packages') != ''
	exe 'silent! aunmenu '.b:tex_pkgMenuLoc.'-sep'.a:pkg.'-'
	exe 'silent! aunmenu '.b:tex_pkgMenuLoc.a:pkg.'\ Options'
	exe 'silent! aunmenu '.b:tex_pkgMenuLoc.a:pkg.'\ Commands'
  endif
  if Tex_FindInRtp(a:pkg, 'dictionaries') != ''
	exe 'setlocal dict-='.Tex_FindInRtp(a:pkg, 'dictionaries')
  endif
endfunc

" }}}
" Tex_pack_updateall: updates the TeX-Packages menu {{{
" Description:
" 	This function first calls Tex_pack_all to scan for \usepackage's etc if
" 	necessary. After that, it 'supports' and 'unsupports' packages as needed
" 	in such a way as to not repeat work.
func! Tex_pack_updateall(force)
  call Tex_Debug('+Tex_pack_updateall', 'pack')

  " Find out which file we need to scan.
  let fname = Tex_GetMainFileName(':p')

  " If this is the same as last time, don't repeat.
  if !a:force && exists('s:lastScannedFile') &&
		\ s:lastScannedFile == fname
	return
  endif
  " Remember which file we scanned for next time.
  let s:lastScannedFile = fname

  " Remember which packages we detected last time.
  if exists('b:tex_pkgDetected')
	let oldpackages = b:tex_pkgDetected
  else
	let oldpackages = ''
  endif

  " This sets up a global variable of all detected packages.
  let b:tex_pkgDetected = ''
  " reset the environments and commands.
  let b:tex_promptEnvs = b:tex_promptEnvsDefault
  let b:tex_promptCmds = b:tex_promptCmdsDefault

  if expand('%:p') != fname
	call Tex_Debug(':tex_pack_updateall: sview '.fnameescape(fname), 'pack')
	exe 'sview '.fnameescape(fname)
  else
	call Tex_Debug(':tex_pack_updateall: split', 'pack')
	split
  endif

  call Tex_ScanForPkgs()
  q

  call Tex_Debug(':tex_pack_updateall: detected ['.b:tex_pkgDetected.'] in first run', 'pack')

  " Now for each package find out if this is a custom package and if so,
  " scan that as well. We will use the ':find' command in vim to let vim
  " search through the file paths for us.
  "
  " NOTE: This while loop will also take into account packages included
  "       within packages to any level of recursion as long as
  "       b:tex_pkgDetected is always padded with new package names
  "       from the end.
  "
  " First set the &path setting to the user's TEXINPUTS setting.
  let _path = &path
  let _suffixesadd = &suffixesadd

  let &path = '.,'.b:tex_TEXINPUTS
  let &suffixesadd = '.sty,.tex'

  let scannedPackages = ''

  let i = 1
  let pkgNm = Tex_Strntok(b:tex_pkgDetected, ',', i)
  while pkgNm != ''

	call Tex_Debug(':tex_pack_updateall: scanning package '.pkgNm, 'pack')

	" Scan this package only if we have not scanned it before in this
	" run.
	if scannedPackages =~ '\<'.pkgNm.'\>'
	  let i = i + 1

	  call Tex_Debug(':tex_pack_updateall: '.pkgNm.' already scanned', 'pack')
	  let pkgNm = Tex_Strntok(b:tex_pkgDetected, ',', i)
	  continue
	endif 

	" Split this window in two. The packages/files being found will open
	" in this new window and we also need not bother with files being
	" modified etc.
	split

	let thisbufnum = bufnr('%')
	call Tex_Debug(':tex_pack_updateall: findfile("'.fnameescape(pkgNm).'.sty")', 'pack')
	let package_file = findfile( fnameescape(pkgNm) .'.sty' )

	if package_file != ""
	  call Tex_Debug(':tex_pack_updateall: found "'. package_file .'"', 'pack')
	  exec 'view ' . package_file
	else
	  call Tex_Debug(':tex_pack_updateall: did not find "'. fnameescape(pkgNm) .'.sty' .'" in "' . &path . '"', 'pack')
	endif
	call Tex_Debug(':tex_pack_updateall: present file = '.bufname('%'), 'pack')

	" If this file was not found, assume that it means its not a
	" custom package and mark it "scanned".
	" A package is not found if we stay in the same buffer as before and
	" its not the one where we want to go.
	if bufnr('%') == thisbufnum && bufnr('%') != bufnr(pkgNm.'.sty')
	  let scannedPackages = scannedPackages.','.pkgNm
	  q

	  call Tex_Debug(':tex_pack_updateall: '.pkgNm.' not found anywhere', 'pack')
	  let i = i + 1
	  let pkgNm = Tex_Strntok(b:tex_pkgDetected, ',', i)
	  continue
	endif

	" otherwise we are presently editing a custom package, scan it for
	" more \usepackage lines from the first line to the last.
	let packpath = expand('%:p')
	let &complete = &complete.'s'.packpath

	call Tex_Debug(':tex_pack_updateall: found custom package '.packpath, 'pack')
	call Tex_ScanForPkgs(line('$'), line('$'))
	call Tex_Debug(':tex_pack_updateall: After scanning, b:tex_pkgDetected = '.b:tex_pkgDetected, 'pack')

	let scannedPackages = scannedPackages.','.pkgNm
	" Do not use bwipe, but that leads to excessive buffer number
	" consumption. Besides, its intuitive for a custom package to remain
	" on the buffer list.
	q

	let i = i + 1
	let pkgNm = Tex_Strntok(b:tex_pkgDetected, ',', i)
  endwhile

  let &path = _path
  let &suffixesadd = _suffixesadd

  " Now only support packages we didn't last time.
  " First remove packages which were used last time but are no longer used.
  let i = 1
  let oldpkgNm = Tex_Strntok(oldpackages, ',', i)
  while oldpkgNm != ''
	if b:tex_pkgDetected !~ oldpkgNm
	  call Tex_pack_uncheck(oldpkgNm)
	endif
	let i = i + 1
	let oldpkgNm = Tex_Strntok(oldpackages, ',', i)
  endwhile

  " Then support packages which are used this time but weren't used last
  " time.
  let i = 1
  let newpkgNm = Tex_Strntok(b:tex_pkgDetected, ',', i)
  while newpkgNm != ''
	if oldpackages !~ newpkgNm
	  call Tex_pack_one(newpkgNm)
	endif
	let i = i + 1
	let newpkgNm = Tex_Strntok(b:tex_pkgDetected, ',', i)
  endwhile

  " Throw an event that we are done scanning packages. Some packages might
  " use this to change behavior based on which options have been used etc.
  call Tex_Debug(":tex_pack_updateall: throwing LatexSuiteScannedPackages event", "pack")
  silent! do LatexSuite User LatexSuiteScannedPackages

  call Tex_Debug("-Tex_pack_updateall", "pack")
endfunc

" }}}
" Tex_pack_one: supports each package in the argument list.{{{
" Description:
"   If no arguments are supplied, then the user is asked to choose from the
"   packages found in the packages/ directory
func! Tex_pack_one(...)
  if a:0 == 0 || (a:0 > 0 && a:1 == '')
	let packlist = Tex_FindInRtp('', 'packages')
	let pkgNm = Tex_ChooseFromPrompt(
		  \ "Choose a package: \n" . 
		  \ Tex_CreatePrompt(packlist, '3', ',') .
		  \ "\nEnter number or filename :", 
		  \ packlist, ',')
	if pkgNm != ''
	  return Tex_pack_one(pkgNm)
	else
	  return ''
	endif
  else
	" Support the packages supplied. This function can be called with
	" multiple arguments in which case, support each of them in turn.
	let retVal = ''
	let omega = 1
	while omega <= a:0
	  let pkgNm = a:{omega}
	  if Tex_FindInRtp(pkgNm, 'packages') != ''
		call Tex_pack_check(pkgNm)
		if exists('g:TeX_package_option_'.pkgNm)
			  \ && g:TeX_package_option_{pkgNm} != ''
		  let retVal = retVal.'\usepackage[<++>]{'.pkgNm.'}<++>'
		else
		  let retVal = retVal.'\usepackage{'.pkgNm.'}'."\<CR>"
		endif
	  else
		let retVal = retVal.'\usepackage{'.pkgNm.'}'."\<CR>"
	  endif
	  let omega = omega + 1
	endwhile
	return IMAP_PutTextWithMovement(substitute(retVal, "\<CR>$", '', ''), '<+', '+>')
  endif
endfunc
" }}}
" Tex_ScanForPkgs: scans the current file for \usepackage{} lines {{{
"   and if supported, loads the options and commands found in the
"   corresponding package file. Also scans for \newenvironment and
"   \newcommand lines and adds names to b:tex_prompted variables, they can be
"   easy available through <F5> and <F7> shortcuts 
func! Tex_ScanForPkgs(...)
  call Tex_Debug("+Tex_ScanForPkgs", "pack")

  let pos = Tex_GetPos()

  " For package files without \begin and \end{document}, we might be told to
  " search from beginning to end.
  if a:0 < 2
	0
	let beginline = search('\\begin{document}', 'W')
	let endline = search('\\end{document}', 'W')
	0
  else
	let beginline = a:1
	let endline = a:2
  endif

  call Tex_Debug("s:Tex_ScanForPkgs: Begining scans in [".bufname('%')."], beginline = ".beginline, "pack")


  " Scan the file. First open up all the folds, because the command
  " /somepattern
  " issued in a closed fold _always_ goes to the first match.
  let erm = v:errmsg
  silent! normal! ggVGzO
  let v:errmsg = erm

  call Tex_Debug("s:Tex_ScanForPkgs: beginning scan for \\usepackage lines", "pack")
  " The wrap trick enables us to match \usepackage on the first line as
  " well.
  let wrap = 'w'
  while search('^\s*\\usepackage\_.\{-}{\_.\+}', wrap)
	let wrap = 'W'

	if line('.') > beginline 
	  break
	endif

	let saveUnnamed = @"
	let saveA = @a

	" If there are options, then find those.
	if getline('.') =~ '\\usepackage\[.\{-}\]'
	  let options = matchstr(getline('.'), '\\usepackage\[\zs.\{-}\ze\]')
	elseif getline('.') =~ '\\usepackage\['
	  " Entering here means that the user has split the \usepackage
	  " across newlines. Therefore, use yank.
	  exec "normal! /{\<CR>\"ayi}"
	  let options = @a
	else
	  let options = ''
	endif

	" The following statement puts the stuff between the { }'s of a
	" \usepackage{stuff,foo} into @a. Do not use matchstr() and the like
	" because we can have things split across lines and such.
	exec "normal! /{\<CR>\"ay/}\<CR>"

	" now remove all whitespace from @a. We need to remove \n and \r
	" because we can encounter stuff like
	" \usepackage{pack1,
	"             newpackonanotherline}
	let @a = substitute(@a, "[ \t\n\r]", '', 'g')

	" Now we have something like pack1,pack2,pack3 with possibly commas
	" and stuff before the first package and after the last package name.
	" Remove those.
	let @a = substitute(@a, '\(^\W*\|\W*$\)', '', 'g')

	" This gets us a string like 'pack1,pack2,pack3'
	" TODO: This will contain duplicates if the user has duplicates.
	"       Should we bother taking care of this?
	let b:tex_pkgDetected = b:tex_pkgDetected.','.@a

	" For each package found, form a global variable of the form
	" g:Tex_{packagename}_options 
	" which contains a list of the options.
	let j = 1
	while Tex_Strntok(@a, ',', j) != ''
	  let g:Tex_{Tex_Strntok(@a, ',', j)}_options = options
	  let j = j + 1
	endwhile

	" Finally convert @a into something like '"pack1","pack2"'
	let @a = substitute(@a, '^\|$', '"', 'g')
	let @a = substitute(@a, ',', '","', 'g')

	call Tex_Debug("s:Tex_ScanForPkgs: found package(s) [".@a."] on line ".line('.'), "pack")

	" restore @a
	call setreg("a", saveA, "c")
	call setreg("\"", saveUnnamed, "c")
  endwhile
  call Tex_Debug("s:Tex_ScanForPkgs: End scan \\usepackage, detected packages = ".b:tex_pkgDetected, "pack")

  " TODO: This needs to be changed. In the future, we might have
  " functionality to remember the fold-state before opening up all the folds
  " and then re-creating them. Use mkview.vim.
  let erm = v:errmsg
  silent! normal! ggVGzC
  let v:errmsg = erm

  " Because creating list of detected packages gives string
  " ',pack1,pack2,pack3' remove leading ,
  let b:tex_pkgDetected = substitute(b:tex_pkgDetected, '^,', '', '')

  call Tex_Debug("s:Tex_ScanForPkgs: Beginning scan for \\newcommand's", "pack")
  " Scans whole file (up to \end{document}) for \newcommand and adds this
  " commands to b:tex_promptCmds variable, it is easily available
  " through <F7>
  0 
  while search('^\s*\\newcommand\*\?{.\{-}}', 'W')

	if line('.') > endline 
	  break
	endif

	let newcommand = matchstr(getline('.'), '\\newcommand\*\?{\\\zs.\{-}\ze}')
	call add(b:tex_promptCmds, newcommand)

  endwhile

  " Scans whole file (up to \end{document}) for \newenvironment and adds this
  " environments to b:tex_promptEnvs variable, it is easily available
  " through <F5>
  0
  call Tex_Debug("s:Tex_ScanForPkgs: Beginning scan for \\newenvironment's", 'pack')

  while search('^\s*\\newenvironment\*\?{.\{-}}', 'W')
	call Tex_Debug('found newenvironment on '.line('.'), 'pack')

	if line('.') > endline 
	  break
	endif

	let newenvironment = matchstr(getline('.'), '\\newenvironment\*\?{\zs.\{-}\ze}')
	call add(b:tex_promptEnvs, newenvironment)

  endwhile

  call Tex_SetPos(pos)
  " first make a random search so that we push at least one item onto the
  " search history. Since vim puts only one item in the history per function
  " call, this way we make sure that one and only item is put into the
  " search history.
  normal! /^<CR>
  " now delete it...
  call histdel('/', -1)

  call Tex_Debug("-Tex_ScanForPkgs", "pack")
endfunc

" }}}
" Tex_pack_supp_menu: sets up a menu for package files {{{
"   found in the packages directory groups the packages thus found into groups
"   of 20...
func! Tex_pack_supp_menu()
  let suplist = Tex_FindInRtp('', 'packages')

  call Tex_MakeSubmenu(suplist, b:tex_pkgMenuLoc.'Supported.', 
		\ '<plug><C-r>=Tex_pack_one("', '")<CR>')
endfunc 

" }}}
" Tex_pack: loads the options (and commands) for the given package {{{
func! Tex_pack(pack)
  if exists('g:TeX_package_'.a:pack)

	let optionList = g:TeX_package_option_{a:pack}.','
	let commandList = g:TeX_package_{a:pack}.','

	" Don't create separator if in package file are only Vim commands. 
	" Rare but possible.
	if !(commandList == ',' && optionList == ',')
	  exec 'amenu '.b:tex_pkgMenuLoc.'-sep'.a:pack.'- <Nop>'
	endif

	if optionList != ''

	  let mainMenuName = b:tex_pkgMenuLoc.a:pack.'\ Options.'
	  call s:GroupPackageMenuItems(optionList, mainMenuName, 
			\ '<plug><C-r>=IMAP_PutTextWithMovement("', ',")<CR>')

	endif

	if commandList != ''

	  let mainMenuName = b:tex_pkgMenuLoc.a:pack.'\ Commands.'
	  call s:GroupPackageMenuItems(commandList, mainMenuName, 
			\ '<plug><C-r>=Tex_ProcessPackageCommand("', '")<CR>',
			\ '<SID>FilterPackageMenuLHS')
	endif
  endif
endfunc 

" }}}

" ==========================================================================
" Menu Functions
" Creating menu items for the all the package files found in the packages/ 
" directory as well as creating menus for each supported package found in 
" the preamble.
" ==========================================================================
" Tex_MakeSubmenu: makes a submenu given a list of items {{{
" Description: 
"   This function takes a comma seperated list of menu items and creates a
"   'grouped' menu. i.e, it groups the items into s:menu_div items each and
"   puts them in submenus of the given mainMenu.
"   Each menu item is linked to the HandlerFunc.
"   If an additional argument is supplied, then it is used to filter each of
"   the menu items to generate better names for the menu display.
"
func! Tex_MakeSubmenu(menuList, mainMenuName, 
	  \ handlerFuncLHS, handlerFuncRHS, ...)

  let extractFunc = (a:0 > 0 ? a:1 : '' )
  let menuList = substitute(a:menuList, '[^,]$', ',', '')

  let doneMenuSubmenu = 0

  while menuList != ''

	" Extract upto s:menu_div menus at once.
	let menuBunch = matchstr(menuList, '\v(.{-},){,'.s:menu_div.'}')

	" The remaining menus go into the list.
	let menuList = strpart(menuList, strlen(menuBunch))

	let submenu = ''
	" If there is something remaining, then we got s:menu_div items.
	" therefore put these menu items into a submenu.
	if strlen(menuList) || doneMenuSubmenu
	  exec 'let firstMenu = '.extractFunc."(matchstr(menuBunch, '\\v^.{-}\\ze,'))"
	  exec 'let lastMenu = '.extractFunc."(matchstr(menuBunch, '\\v[^,]{-}\\ze,$'))"

	  let submenu = firstMenu.'\ \-\ '.lastMenu.'.'

	  let doneMenuSubmenu = 1
	endif

	" Now for each menu create a menu under the submenu
	let i = 1
	let menuName = Tex_Strntok(menuBunch, ',', i)
	while menuName != ''
	  exec 'let menuItem = '.extractFunc.'(menuName)'
	  execute 'amenu '.a:mainMenuName.submenu.menuItem
			\ '       '.a:handlerFuncLHS.menuName.a:handlerFuncRHS

	  let i = i + 1
	  let menuName = Tex_Strntok(menuBunch, ',', i)
	endwhile
  endwhile
endfunc 

" }}}
" GroupPackageMenuItems: uses the sbr: to split menus into groups {{{
" Description: 
"   This function first splits up the menuList into groups based on the
"   special sbr: tag and then calls Tex_MakeSubmenu 
" 
func! <SID>GroupPackageMenuItems(menuList, menuName, 
	  \ handlerFuncLHS, handlerFuncRHS,...)

  if a:0 > 0
	let extractFunc = a:1
  else
	let extractFunc = ''
  endif
  let menuList = a:menuList

  while matchstr(menuList, 'sbr:') != ''
	let groupName = matchstr(menuList, '\v^sbr:\zs.{-}\ze,')
	let menuList = strpart(menuList, strlen('sbr:'.groupName.','))
	if matchstr(menuList, 'sbr:') != ''
	  let menuGroup = matchstr(menuList, '\v^.{-},\zesbr:')
	else
	  let menuGroup = menuList
	endif

	call Tex_MakeSubmenu(menuGroup, a:menuName.groupName.'.', 
		  \ a:handlerFuncLHS, a:handlerFuncRHS, extractFunc)

	let menuList = strpart(menuList, strlen(menuGroup))
  endwhile

  call Tex_MakeSubmenu(menuList, a:menuName,
		\ a:handlerFuncLHS, a:handlerFuncRHS, extractFunc)

endfunc " }}}
" Definition of what to do for various package commands {{{
let s:CommandSpec_brs = '\<+replace+><++>'
let s:CommandSpec_bra = '\<+replace+>{<++>}<++>'
let s:CommandSpec_brd = '\<+replace+>{<++>}{<++>}<++>'

let s:CommandSpec_nor = '\<+replace+>'
let s:CommandSpec_noo = '\<+replace+>[<++>]'
let s:CommandSpec_nob = '\<+replace+>[<++>]{<++>}{<++>}<++>'

let s:CommandSpec_env = '\begin{<+replace+>}'."\<CR><++>\<CR>".'\end{<+replace+>}'.s:end_with_cr.'<++>'
let s:CommandSpec_ens = '\begin{<+replace+>}<+extra+>'."\<CR><++>\<CR>".'\end{<+replace+>}'.s:end_with_cr.'<++>'
let s:CommandSpec_eno = '\begin[<++>]{<+replace+>}'."\<CR><++>\<CR>".'\end{<+replace+>}'.s:end_with_cr.'<++>'

let s:CommandSpec_spe = '<+replace+>'
let s:CommandSpec_    = '\<+replace+>'

let s:MenuLHS_bra = '\\&<+replace+>{}'
let s:MenuLHS_brs = '\\&<+replace+>{}'
let s:MenuLHS_brd = '\\&<+replace+>{}{}'
let s:MenuLHS_env = '&<+replace+>\ (E)'
let s:MenuLHS_ens = '&<+replace+>\ (E)'
let s:MenuLHS_eno = '&<+replace+>\ (E)'
let s:MenuLHS_nor = '\\&<+replace+>'
let s:MenuLHS_noo = '\\&<+replace+>[]'
let s:MenuLHS_nob = '\\&<+replace+>[]{}{}'
let s:MenuLHS_spe = '&<+replace+>'
let s:MenuLHS_sep = '-sep<+replace+>-'
let s:MenuLHS_    = '\\&<+replace+>'
" }}}
" Tex_ProcessPackageCommand: processes a command from the package menu {{{
" Description: 
func! Tex_ProcessPackageCommand(command)
  if a:command =~ ':'
	let commandType = matchstr(a:command, '^\w\+\ze:')
	let commandName = matchstr(a:command, '^\w\+:\zs[^:]\+\ze:\?')
	let extrapart = strpart(a:command, strlen(commandType.':'.commandName.':'))
  else
	let commandType = ''
	let commandName = a:command
	let extrapart = ''
  endif

  let command = s:CommandSpec_{commandType}
  let command = substitute(command, '<+replace+>', commandName, 'g')
  let command = substitute(command, '<+extra+>', extrapart, 'g')
  return IMAP_PutTextWithMovement(command)
endfunc 
" }}}
" FilterPackageMenuLHS: filters the command description to provide a better menu item {{{
" Description: 
func! <SID>FilterPackageMenuLHS(command)
  let commandType = matchstr(a:command, '^\w\+\ze:')
  if commandType != ''
	let commandName = strpart(a:command, strlen(commandType.':'))
  else
	let commandName = a:command
  endif

  return substitute(s:MenuLHS_{commandType}, '<+replace+>', commandName, 'g')
endfunc " }}}

if b:tex_menus
  exe 'amenu '.b:tex_pkgMenuLoc.'&UpdatePackage :call Tex_pack(expand("<cword>"))<cr>'
  exe 'amenu '.b:tex_pkgMenuLoc.'&UpdateAll :call Tex_pack_updateall(1)<cr>'

  call Tex_pack_supp_menu()
endif

let s:save_clipboard = &clipboard |
set clipboard= |
call Tex_pack_updateall(0) |
let &clipboard=s:save_clipboard
" vim:fdm=marker:noet:ff=unix
