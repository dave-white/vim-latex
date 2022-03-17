" tex_usePython {{{
if !exists("b:tex_usePython") && exists("g:tex_usePython")
  let b:tex_usePython = g:tex_usePython
endif
" }}}
" tex_debug {{{
if !exists("b:tex_debug") && exists("g:tex_debug")
  let b:tex_debug = g:tex_debug
endif
" }}}
" tex_debugLog {{{
if !exists("b:tex_debugLog") && exists("g:tex_debugLog")
  let b:tex_debugLog = g:tex_debugLog
endif
" }}}
" tex_useIMAP {{{
if !exists("b:tex_useIMAP") && exists("g:tex_useIMAP")
  let b:tex_useIMAP = g:tex_useIMAP
endif
" }}}
" tex_useRunningImap {{{
if !exists("b:tex_useRunningImap") && exists("g:tex_useRunningImap")
  let b:tex_useRunningImap = g:tex_useRunningImap
endif
" }}}
" tex_targ {{{
if !exists("b:tex_targ") && exists("g:tex_targ")
  let b:tex_targ = g:tex_targ
endif
" }}}
" tex_doMultCompile {{{
if !exists("b:tex_doMultCompile") && exists("g:tex_doMultCompile")
  let b:tex_doMultCompile = g:tex_doMultCompile
endif
" }}}
" tex_multCompileFmts {{{
if !exists("b:tex_multCompileFmts") && exists("g:tex_multCompileFmts")
  let b:tex_multCompileFmts = g:tex_multCompileFmts
endif
" }}}
" tex_fmtDeps_ps {{{
if !exists("b:tex_fmtDeps_ps") && exists("g:tex_fmtDeps_ps")
  let b:tex_fmtDeps_ps = g:tex_fmtDeps_ps
endif
" }}}
" tex_fmtDeps_pdf {{{
if !exists("b:tex_fmtDeps_pdf") && exists("g:tex_fmtDeps_pdf")
  let b:tex_fmtDeps_pdf = g:tex_fmtDeps_pdf
endif
" }}}
" tex_compilePrg_dvi {{{
if !exists("b:tex_compilePrg_dvi") && exists("g:tex_compilePrg_dvi")
  let b:tex_compilePrg_dvi = g:tex_compilePrg_dvi
endif
" }}}
" tex_escChars {{{
if !exists("b:tex_escChars") && exists("g:tex_escChars")
  let b:tex_escChars = g:tex_escChars
endif
" }}}
" tex_compilePrg_ps {{{
if !exists("b:tex_compilePrg_ps") && exists("g:tex_compilePrg_ps")
  let b:tex_compilePrg_ps = g:tex_compilePrg_ps
endif
" }}}
" tex_compilePrg_pdf {{{
if !exists("b:tex_compilePrg_pdf") && exists("g:tex_compilePrg_pdf")
  let b:tex_compilePrg_pdf = g:tex_compilePrg_pdf
endif
" }}}
" tex_outpDir {{{
if !exists("b:tex_outpDir") && exists("g:tex_outpDir")
  let b:tex_outpDir = g:tex_outpDir
endif
" }}}
" tex_useMake {{{
if !exists("b:tex_useMake") && exists("g:tex_useMake")
  let b:tex_useMake = g:tex_useMake
endif
" }}}
" tex_CompilePrg_html {{{
if !exists("b:tex_CompilePrg_html") && exists("g:tex_CompilePrg_html")
  let b:tex_CompilePrg_html = g:tex_CompilePrg_html
endif
" }}}
" tex_viewPrg_ps {{{
if !exists("b:tex_viewPrg_ps") && exists("g:tex_viewPrg_ps")
  let b:tex_viewPrg_ps = g:tex_viewPrg_ps
endif
" }}}
" tex_viewPrg_pdf {{{
if !exists("b:tex_viewPrg_pdf") && exists("g:tex_viewPrg_pdf")
  let b:tex_viewPrg_pdf = g:tex_viewPrg_pdf
endif
" }}}
" tex_viewPrg_dvi {{{
if !exists("b:tex_viewPrg_dvi") && exists("g:tex_viewPrg_dvi")
  let b:tex_viewPrg_dvi = g:tex_viewPrg_dvi
endif
" }}}
" tex_treatMacViewerAsUNIX {{{
if !exists("b:tex_treatMacViewerAsUNIX") && exists("g:tex_treatMacViewerAsUNIX")
  let b:tex_treatMacViewerAsUNIX = g:tex_treatMacViewerAsUNIX
endif
" }}}
" tex_useEditorSettingInDVIViewer {{{
if !exists("b:tex_useEditorSettingInDVIViewer") && exists("g:tex_useEditorSettingInDVIViewer")
  let b:tex_useEditorSettingInDVIViewer = g:tex_useEditorSettingInDVIViewer
endif
" }}}
" tex_execNixViewerInForeground {{{
if !exists("b:tex_execNixViewerInForeground") && exists("g:tex_execNixViewerInForeground")
  let b:tex_execNixViewerInForeground = g:tex_execNixViewerInForeground
endif
" }}}
" tex_viewPrgComplete_dvi {{{
if !exists("b:tex_viewPrgComplete_dvi") && exists("g:tex_viewPrgComplete_dvi")
  let b:tex_viewPrgComplete_dvi = g:tex_viewPrgComplete_dvi
endif
" }}}
" tex_ignWarnPats {{{
if !exists("b:tex_ignWarnPats") && exists("g:tex_ignWarnPats")
  let b:tex_ignWarnPats = g:tex_ignWarnPats
endif
" }}}
" tex_ignLvl {{{
if !exists("b:tex_ignLvl") && exists("g:tex_ignLvl")
  let b:tex_ignLvl = g:tex_ignLvl
endif
" }}}
" tex_flavor {{{
if !exists("b:tex_flavor") && exists("g:tex_flavor")
  let b:tex_flavor = g:tex_flavor
endif
" }}}
" tex_bibPrg {{{
if !exists("b:tex_bibPrg") && exists("g:tex_bibPrg")
  let b:tex_bibPrg = g:tex_bibPrg
endif
" }}}
" tex_mkIdxFlavor {{{
if !exists("b:tex_mkIdxFlavor") && exists("g:tex_mkIdxFlavor")
  let b:tex_mkIdxFlavor = g:tex_mkIdxFlavor
endif
" }}}
" tex_gotoErr {{{
if !exists("b:tex_gotoErr") && exists("g:tex_gotoErr")
  let b:tex_gotoErr = g:tex_gotoErr
endif
" }}}
" tex_showErrCntxt {{{
if !exists("b:tex_showErrCntxt") && exists("g:tex_showErrCntxt")
  let b:tex_showErrCntxt = g:tex_showErrCntxt
endif
" }}}
" tex_rmvTmpFiles {{{
if !exists("b:tex_rmvTmpFiles") && exists("g:tex_rmvTmpFiles")
  let b:tex_rmvTmpFiles = g:tex_rmvTmpFiles
endif
" }}}
" tex_mainFileXpr {{{
if !exists("b:tex_mainFileXpr") && exists("g:tex_mainFileXpr")
  let b:tex_mainFileXpr = g:tex_mainFileXpr
endif
" }}}
" imap_usePlaceHolders {{{
if !exists("b:imap_usePlaceHolders") && exists("g:imap_usePlaceHolders")
  let b:imap_usePlaceHolders = g:imap_usePlaceHolders
endif
" }}}
" imap_placeHolderStart {{{
if !exists("b:imap_placeHolderStart") && exists("g:imap_placeHolderStart")
  let b:imap_placeHolderStart = g:imap_placeHolderStart
endif
" }}}
" imap_placeHolderEnd {{{
if !exists("b:imap_placeHolderEnd") && exists("g:imap_placeHolderEnd")
  let b:imap_placeHolderEnd = g:imap_placeHolderEnd
endif
" }}}
" imap_delEmptyPlaceHolders {{{
if !exists("b:imap_delEmptyPlaceHolders") && exists("g:imap_delEmptyPlaceHolders")
  let b:imap_delEmptyPlaceHolders = g:imap_delEmptyPlaceHolders
endif
" }}}
" imap_stickyPlaceHolders {{{
if !exists("b:imap_stickyPlaceHolders") && exists("g:imap_stickyPlaceHolders")
  let b:imap_stickyPlaceHolders = g:imap_stickyPlaceHolders
endif
" }}}
" tex_useMenuWiz {{{
if !exists("b:tex_useMenuWiz") && exists("g:tex_useMenuWiz")
  let b:tex_useMenuWiz = g:tex_useMenuWiz
endif
" }}}
" tex_catchVisMapErrs {{{
if !exists("b:tex_catchVisMapErrs") && exists("g:tex_catchVisMapErrs")
  let b:tex_catchVisMapErrs = g:tex_catchVisMapErrs
endif
" }}}
" tex_diacritics {{{
if !exists("b:tex_diacritics") && exists("g:tex_diacritics")
  let b:tex_diacritics = g:tex_diacritics
endif
" }}}
" tex_leader {{{
if !exists("b:tex_leader") && exists("g:tex_leader")
  let b:tex_leader = g:tex_leader
endif
" }}}
" tex_leader2 {{{
if !exists("b:tex_leader2") && exists("g:tex_leader2")
  let b:tex_leader2 = g:tex_leader2
endif
" }}}
" tex_envMaps {{{
if !exists("b:tex_envMaps") && exists("g:tex_envMaps")
  let b:tex_envMaps = g:tex_envMaps
endif
" }}}
" tex_envMenus {{{
if !exists("b:tex_envMenus") && exists("g:tex_envMenus")
  let b:tex_envMenus = g:tex_envMenus
endif
" }}}
" tex_envEndWithCR {{{
if !exists("b:tex_envEndWithCR") && exists("g:tex_envEndWithCR")
  let b:tex_envEndWithCR = g:tex_envEndWithCR
endif
" }}}
" tex_labelAfterContent {{{
if !exists("b:tex_labelAfterContent") && exists("g:tex_labelAfterContent")
  let b:tex_labelAfterContent = g:tex_labelAfterContent
endif
" }}}
" tex_itemsWithCR {{{
if !exists("b:tex_itemsWithCR") && exists("g:tex_itemsWithCR")
  let b:tex_itemsWithCR = g:tex_itemsWithCR
endif
" }}}
" tex_envLabelPrefix_tab {{{
if !exists("b:tex_envLabelPrefix_tab") && exists("g:tex_envLabelPrefix_tab")
  let b:tex_envLabelPrefix_tab = g:tex_envLabelPrefix_tab
endif
" }}}
" tex_envLabelPrefix_fig {{{
if !exists("b:tex_envLabelPrefix_fig") && exists("g:tex_envLabelPrefix_fig")
  let b:tex_envLabelPrefix_fig = g:tex_envLabelPrefix_fig
endif
" }}}
" tex_fontMaps {{{
if !exists("b:tex_fontMaps") && exists("g:tex_fontMaps")
  let b:tex_fontMaps = g:tex_fontMaps
endif
" }}}
" tex_fontMenus {{{
if !exists("b:tex_fontMenus") && exists("g:tex_fontMenus")
  let b:tex_fontMenus = g:tex_fontMenus
endif
" }}}
" tex_secMaps {{{
if !exists("b:tex_secMaps") && exists("g:tex_secMaps")
  let b:tex_secMaps = g:tex_secMaps
endif
" }}}
" tex_secMenus {{{
if !exists("b:tex_secMenus") && exists("g:tex_secMenus")
  let b:tex_secMenus = g:tex_secMenus
endif
" }}}
" tex_promptEnvs {{{
if !exists("b:tex_promptEnvs") && exists("g:tex_promptEnvs")
  let b:tex_promptEnvs = g:tex_promptEnvs
endif
" }}}
" tex_hotkeyMaps {{{
if !exists("b:tex_hotkeyMaps") && exists("g:tex_hotkeyMaps")
  let b:tex_hotkeyMaps = g:tex_hotkeyMaps
endif
" }}}
" tex_promptCmds {{{
if !exists("b:tex_promptCmds") && exists("g:tex_promptCmds")
  let b:tex_promptCmds = g:tex_promptCmds
endif
" }}}
" tex_smartKeyBS {{{
if !exists("b:tex_smartKeyBS") && exists("g:tex_smartKeyBS")
  let b:tex_smartKeyBS = g:tex_smartKeyBS
endif
" }}}
" tex_smartBSPattern {{{
if !exists("b:tex_smartBSPattern") && exists("g:tex_smartBSPattern")
  let b:tex_smartBSPattern = g:tex_smartBSPattern
endif
" }}}
" tex_smartKeyQuote {{{
if !exists("b:tex_smartKeyQuote") && exists("g:tex_smartKeyQuote")
  let b:tex_smartKeyQuote = g:tex_smartKeyQuote
endif
" }}}
" tex_smartQuoteOpen {{{
if !exists("b:tex_smartQuoteOpen") && exists("g:tex_smartQuoteOpen")
  let b:tex_smartQuoteOpen = g:tex_smartQuoteOpen
endif
" }}}
" tex_smartQuoteClose {{{
if !exists("b:tex_smartQuoteClose") && exists("g:tex_smartQuoteClose")
  let b:tex_smartQuoteClose = g:tex_smartQuoteClose
endif
" }}}
" tex_smartKeySpace {{{
if !exists("b:tex_smartKeySpace") && exists("g:tex_smartKeySpace")
  let b:tex_smartKeySpace = g:tex_smartKeySpace
endif
" }}}
" tex_smartKeyDot {{{
if !exists("b:tex_smartKeyDot") && exists("g:tex_smartKeyDot")
  let b:tex_smartKeyDot = g:tex_smartKeyDot
endif
" }}}
" tex_advMath {{{
if !exists("b:tex_advMath") && exists("g:tex_advMath")
  let b:tex_advMath = g:tex_advMath
endif
" }}}
" tex_outlineWinHeight {{{
if !exists("b:tex_outlineWinHeight") && exists("g:tex_outlineWinHeight")
  let b:tex_outlineWinHeight = g:tex_outlineWinHeight
endif
" }}}
" tex_viewerCwinHeight {{{
if !exists("b:tex_viewerCwinHeight") && exists("g:tex_viewerCwinHeight")
  let b:tex_viewerCwinHeight = g:tex_viewerCwinHeight
endif
" }}}
" tex_viewerPreviewHeight {{{
if !exists("b:tex_viewerPreviewHeight") && exists("g:tex_viewerPreviewHeight")
  let b:tex_viewerPreviewHeight = g:tex_viewerPreviewHeight
endif
" }}}
" tex_ExplorerHeight {{{
if !exists("b:tex_ExplorerHeight") && exists("g:tex_ExplorerHeight")
  let b:tex_ExplorerHeight = g:tex_ExplorerHeight
endif
" }}}
" tex_imgDir {{{
if !exists("b:tex_imgDir") && exists("g:tex_imgDir")
  let b:tex_imgDir = g:tex_imgDir
endif
" }}}
" tex_useOutlineCompletion {{{
if !exists("b:tex_useOutlineCompletion") && exists("g:tex_useOutlineCompletion")
  let b:tex_useOutlineCompletion = g:tex_useOutlineCompletion
endif
" }}}
" tex_projSrcFiles {{{
if !exists("b:tex_projSrcFiles") && exists("g:tex_projSrcFiles")
  let b:tex_projSrcFiles = g:tex_projSrcFiles
endif
" }}}
" tex_useSimpleLabelSearch {{{
if !exists("b:tex_useSimpleLabelSearch") && exists("g:tex_useSimpleLabelSearch")
  let b:tex_useSimpleLabelSearch = g:tex_useSimpleLabelSearch
endif
" }}}
" tex_useCiteCompletionVer2 {{{
if !exists("b:tex_useCiteCompletionVer2") && exists("g:tex_useCiteCompletionVer2")
  let b:tex_useCiteCompletionVer2 = g:tex_useCiteCompletionVer2
endif
" }}}
" tex_bibFieldPrompt {{{
if !exists("b:tex_bibFieldPrompt") && exists("g:tex_bibFieldPrompt")
  let b:tex_bibFieldPrompt = g:tex_bibFieldPrompt
endif
" }}}
" tex_echoBibFields {{{
if !exists("b:tex_echoBibFields") && exists("g:tex_echoBibFields")
  let b:tex_echoBibFields = g:tex_echoBibFields
endif
" }}}
" tex_useJabref {{{
if !exists("b:tex_useJabref") && exists("g:tex_useJabref")
  let b:tex_useJabref = g:tex_useJabref
endif
" }}}
" tex_rememberCiteSearch {{{
if !exists("b:tex_rememberCiteSearch") && exists("g:tex_rememberCiteSearch")
  let b:tex_rememberCiteSearch = g:tex_rememberCiteSearch
endif
" }}}
" tex_BIBINPUTS {{{
if !exists("b:tex_BIBINPUTS") && exists("g:tex_BIBINPUTS")
  let b:tex_BIBINPUTS = g:tex_BIBINPUTS
endif
" }}}
" tex_TEXINPUTS {{{
if !exists("b:tex_TEXINPUTS") && exists("g:tex_TEXINPUTS")
  let b:tex_TEXINPUTS = g:tex_TEXINPUTS
endif
" }}}
" tex_menus {{{
if !exists("b:tex_menus") && exists("g:tex_menus")
  let b:tex_menus = g:tex_menus
endif
" }}}
" tex_mainMenuLoc {{{
if !exists("b:tex_mainMenuLoc") && exists("g:tex_mainMenuLoc")
  let b:tex_mainMenuLoc = g:tex_mainMenuLoc
endif
" }}}
" tex_mathMenus {{{
if !exists("b:tex_mathMenus") && exists("g:tex_mathMenus")
  let b:tex_mathMenus = g:tex_mathMenus
endif
" }}}
" tex_nestEltMenus {{{
if !exists("b:tex_nestEltMenus") && exists("g:tex_nestEltMenus")
  let b:tex_nestEltMenus = g:tex_nestEltMenus
endif
" }}}
" tex_pkgMenu {{{
if !exists("b:tex_pkgMenu") && exists("g:tex_pkgMenu")
  let b:tex_pkgMenu = g:tex_pkgMenu
endif
" }}}
" tex_nestPkgMenu {{{
if !exists("b:tex_nestPkgMenu") && exists("g:tex_nestPkgMenu")
  let b:tex_nestPkgMenu = g:tex_nestPkgMenu
endif
" }}}
" tex_menuPrefix {{{
if !exists("b:tex_menuPrefix") && exists("g:tex_menuPrefix")
  let b:tex_menuPrefix = g:tex_menuPrefix
endif
" }}}
" tex_useUtfMenus {{{
if !exists("b:tex_useUtfMenus") && exists("g:tex_useUtfMenus")
  let b:tex_useUtfMenus = g:tex_useUtfMenus
endif
" }}}
" tex_folding {{{
if !exists("b:tex_folding") && exists("g:tex_folding")
  let b:tex_folding = g:tex_folding
endif
" }}}
" tex_autoFolding {{{
if !exists("b:tex_autoFolding") && exists("g:tex_autoFolding")
  let b:tex_autoFolding = g:tex_autoFolding
endif
" }}}
" tex_tagListSupport {{{
if !exists("b:tex_tagListSupport") && exists("g:tex_tagListSupport")
  let b:tex_tagListSupport = g:tex_tagListSupport
endif
" }}}
" tex_internalTagDfns {{{
if !exists("b:tex_internalTagDfns") && exists("g:tex_internalTagDfns")
  let b:tex_internalTagDfns = g:tex_internalTagDfns
endif
" }}}
" tex_compilePrgOptDict {{{
if !exists("b:tex_compilePrgOptDict_pdf")
  let b:tex_compilePrgOptDict_pdf = {}
endif
if exists("g:tex_compilePrgOptDict_pdf")
  call extend(b:tex_compilePrgOptDict_pdf, g:tex_compilePrgOptDict_pdf,
	\ "keep")
endif
" }}}
" tex_bibPrgOptDict {{{
if !exists("b:tex_bibPrgOptDict")
  let b:tex_bibPrgOptDict = {}
endif
if exists("g:tex_bibPrgOptDict")
  call extend(b:tex_bibPrgOptDict, g:tex_bibPrgOptDict, "keep")
endif
" }}}
" vim:ft=vim:fdm=marker
