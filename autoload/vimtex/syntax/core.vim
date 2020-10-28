" vimtex - LaTeX plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

function! vimtex#syntax#core#init() abort " {{{1
  " Syntax may be loaded without the main vimtex functionality, thus we need to
  " ensure that the options are loaded!
  call vimtex#options#init()

  syntax spell toplevel

  syntax sync maxlines=500
  syntax sync minlines=50

  let l:cfg = deepcopy(g:vimtex_syntax_config)
  let l:cfg.ext = expand('%:e')
  let l:cfg.is_style_document =
        \ index(['sty', 'cls', 'clo', 'dtx', 'ltx'], l:cfg.ext) >= 0

  " {{{2 Primitives

  " Delimiters
  syntax region texMatcher matchgroup=Delimiter start="{" skip="\\\\\|\\}" end="}" contains=TOP

  " Flag mismatching ending brace delimiter
  syntax match texError "}"

  " Comments
  if l:cfg.ext ==# 'dtx'
    " Documented TeX Format: Only leading "^^A" and "%"
    syntax match texComment "\^\^A.*$"
    syntax match texComment "^%\+"
  else
    syntax match texComment "%.*$" contains=@Spell
  endif

  " Do not check URLs and acronyms in comments
  " Source: https://github.com/lervag/vimtex/issues/562
  syntax match texCommentURL "\w\+:\/\/[^[:space:]]\+"
        \ containedin=texComment contained contains=@NoSpell
  syntax match texCommentAcronym '\v<(\u|\d){3,}s?>'
        \ containedin=texComment contained contains=@NoSpell

  " Todo and similar within comments
  syntax case ignore
  syntax keyword texCommentTodo combak fixme todo xxx
        \ containedin=texComment contained
  syntax case match

  " TeX Lengths
  syntax match texLength "\<\d\+\([.,]\d\+\)\?\s*\(true\)\?\s*\(bp\|cc\|cm\|dd\|em\|ex\|in\|mm\|pc\|pt\|sp\)\>"

  " }}}2
  " {{{2 Commands

  " Most general version first
  syntax match texCmd "\\\a\+"
  syntax match texCmdError "\\\a*@\a*"

  " Add some standard contained stuff
  syntax match texOptEqual contained "="
  syntax match texOptSep contained ",\s*"

  " Accents and ligatures
  syntax match texCmdAccent "\\[bcdvuH]$"
  syntax match texCmdAccent "\\[bcdvuH]\ze\A"
  syntax match texCmdAccent /\\[=^.\~"`']/
  syntax match texCmdAccent /\\['=t'.c^ud"vb~Hr]{\a}/
  syntax match texCmdLigature "\v\\%([ijolL]|ae|oe|ss|AA|AE|OE)$"
  syntax match texCmdLigature "\v\\%([ijolL]|ae|oe|ss|AA|AE|OE)\ze\A"

  if l:cfg.is_style_document
    syntax match texCmd "\\[a-zA-Z@]\+"
    syntax match texCmdAccent "\\[bcdvuH]\ze[^a-zA-Z@]"
    syntax match texCmdLigature "\v\\%([ijolL]|ae|oe|ss|AA|AE|OE)\ze[^a-zA-Z@]"
  endif

  " Spacecodes (TeX'isms)
  " * See e.g. https://en.wikibooks.org/wiki/TeX/catcode
  " * \mathcode`\^^@ = "2201
  " * \delcode`\( = "028300
  " * \sfcode`\) = 0
  " * \uccode`X = `X
  " * \lccode`x = `x
  syntax match texCmdSpaceCode "\v\\%(math|cat|del|lc|sf|uc)code`"me=e-1
        \ nextgroup=texCmdSpaceCodeChar
  syntax match texCmdSpaceCodeChar "\v`\\?.%(\^.)?\?%(\d|\"\x{1,6}|`.)" contained

  " Todo commands
  syntax match texCmdTodo '\\todo\w*'

  " TODO: Special for author and title type of commands?
  " \author
  " \title

  " Various commands that take a file argument (or similar)
  syntax match texCmd nextgroup=texFileArg              skipwhite skipnl "\\input\>"
  syntax match texCmd nextgroup=texFileArg              skipwhite skipnl "\\include\>"
  syntax match texCmd nextgroup=texFileArgs             skipwhite skipnl "\\includeonly\>"
  syntax match texCmd nextgroup=texFileOpt,texFileArg   skipwhite skipnl "\\includegraphics\>"
  syntax match texCmd nextgroup=texFileArgs             skipwhite skipnl "\\bibliography\>"
  syntax match texCmd nextgroup=texFileArg              skipwhite skipnl "\\bibliographystyle\>"
  syntax match texCmd nextgroup=texFileOpt,texFileArg   skipwhite skipnl "\\document\%(class\|style\)\>"
  syntax match texCmd nextgroup=texFileOpts,texFileArgs skipwhite skipnl "\\usepackage\>"
  syntax match texCmd nextgroup=texFileOpts,texFileArgs skipwhite skipnl "\\RequirePackage\>"
  call vimtex#syntax#core#new_cmd_opt('texFileOpt', 'texFileArg')
  call vimtex#syntax#core#new_cmd_opt('texFileOpts', 'texFileArgs')
  call vimtex#syntax#core#new_cmd_arg('texFileArg', '', 'texCmd,texComment,@NoSpell')
  call vimtex#syntax#core#new_cmd_arg('texFileArgs', '', 'texOptSep,texCmd,texComment,@NoSpell')

  " LaTeX 2.09 type styles
  syntax match texCmdStyle "\\rm\>"
  syntax match texCmdStyle "\\em\>"
  syntax match texCmdStyle "\\bf\>"
  syntax match texCmdStyle "\\it\>"
  syntax match texCmdStyle "\\sl\>"
  syntax match texCmdStyle "\\sf\>"
  syntax match texCmdStyle "\\sc\>"
  syntax match texCmdStyle "\\tt\>"

  " LaTeX2E type styles
  syntax match texCmdStyle "\\textbf\>"
  syntax match texCmdStyle "\\textit\>"
  syntax match texCmdStyle "\\textmd\>"
  syntax match texCmdStyle "\\textrm\>"
  syntax match texCmdStyle "\\texts[cfl]\>"
  syntax match texCmdStyle "\\texttt\>"
  syntax match texCmdStyle "\\textup\>"
  syntax match texCmdStyle "\\emph\>"

  syntax match texCmdStyle "\\mathbb\>"
  syntax match texCmdStyle "\\mathbf\>"
  syntax match texCmdStyle "\\mathcal\>"
  syntax match texCmdStyle "\\mathfrak\>"
  syntax match texCmdStyle "\\mathit\>"
  syntax match texCmdStyle "\\mathnormal\>"
  syntax match texCmdStyle "\\mathrm\>"
  syntax match texCmdStyle "\\mathsf\>"
  syntax match texCmdStyle "\\mathtt\>"

  syntax match texCmdStyle "\\rmfamily\>"
  syntax match texCmdStyle "\\sffamily\>"
  syntax match texCmdStyle "\\ttfamily\>"

  syntax match texCmdStyle "\\itshape\>"
  syntax match texCmdStyle "\\scshape\>"
  syntax match texCmdStyle "\\slshape\>"
  syntax match texCmdStyle "\\upshape\>"

  syntax match texCmdStyle "\\bfseries\>"
  syntax match texCmdStyle "\\mdseries\>"

  " Bold and italic commands
  call s:match_bold_italic(l:cfg)

  " Type sizes
  syntax match texCmdSize "\\tiny\>"
  syntax match texCmdSize "\\scriptsize\>"
  syntax match texCmdSize "\\footnotesize\>"
  syntax match texCmdSize "\\small\>"
  syntax match texCmdSize "\\normalsize\>"
  syntax match texCmdSize "\\large\>"
  syntax match texCmdSize "\\Large\>"
  syntax match texCmdSize "\\LARGE\>"
  syntax match texCmdSize "\\huge\>"
  syntax match texCmdSize "\\Huge\>"

  " \newcommand
  syntax match texCmdNewcmd nextgroup=texNewcmdName skipwhite skipnl "\\\%(re\)\?newcommand\>"
  call vimtex#syntax#core#new_cmd_arg('texNewcmdName', 'texNewcmdOpt,texNewcmdBody')
  call vimtex#syntax#core#new_cmd_opt('texNewcmdOpt', 'texNewcmdOpt,texNewcmdBody', '', 'oneline')
  call vimtex#syntax#core#new_cmd_arg('texNewcmdBody', '', 'TOP')
  syntax match texNewcmdParm contained "#\d\+" containedin=texNewcmdBody

  " \newenvironment
  syntax match texCmdNewenv nextgroup=texNewenvName skipwhite skipnl "\\\%(re\)\?newenvironment\>"
  call vimtex#syntax#core#new_cmd_arg('texNewenvName', 'texNewenvBgn,texNewenvOpt')
  call vimtex#syntax#core#new_cmd_opt('texNewenvOpt', 'texNewenvBgn,texNewenvOpt', '', 'oneline')
  call vimtex#syntax#core#new_cmd_arg('texNewenvBgn', 'texNewenvEnd', 'TOP')
  call vimtex#syntax#core#new_cmd_arg('texNewenvEnd', '', 'TOP')
  syntax match texNewenvParm contained "#\d\+" containedin=texNewenvBgn,texNewenvEnd

  " Definitions/Commands
  " E.g. \def \foo #1#2 {foo #1 bar #2 baz}
  syntax match texCmdDef "\\def\>" nextgroup=texDefName skipwhite skipnl
  if l:cfg.is_style_document
    syntax match texDefName contained nextgroup=texDefParmPre,texDefBody skipwhite skipnl "\\[a-zA-Z@]\+"
    syntax match texDefName contained nextgroup=texDefParmPre,texDefBody skipwhite skipnl "\\[^a-zA-Z@]"
  else
    syntax match texDefName contained nextgroup=texDefParmPre,texDefBody skipwhite skipnl "\\\a\+"
    syntax match texDefName contained nextgroup=texDefParmPre,texDefBody skipwhite skipnl "\\\A"
  endif
  syntax match texDefParmPre contained nextgroup=texDefBody skipwhite skipnl "#[^{]*"
  syntax match texDefParm contained "#\d\+" containedin=texDefParmPre,texDefBody
  call vimtex#syntax#core#new_cmd_arg('texDefBody', '', 'TOP')

  " Reference and cite commands
  syntax match texCmdRef nextgroup=texRef           skipwhite skipnl "\\nocite\>"
  syntax match texCmdRef nextgroup=texRef           skipwhite skipnl "\\label\>"
  syntax match texCmdRef nextgroup=texRef           skipwhite skipnl "\\\(page\|eq\)ref\>"
  syntax match texCmdRef nextgroup=texRef           skipwhite skipnl "\\v\?ref\>"
  syntax match texCmdRef nextgroup=texRefOpt,texRef skipwhite skipnl "\\cite\>"
  syntax match texCmdRef nextgroup=texRefOpt,texRef skipwhite skipnl "\\cite[tp]\>\*\?"
  call vimtex#syntax#core#new_cmd_arg('texRef', '', 'texComment,@NoSpell')
  call vimtex#syntax#core#new_cmd_opt('texRefOpt', 'texRefOpt,texRef')

  " \makeatletter ... \makeatother sections
  " https://tex.stackexchange.com/questions/8351/what-do-makeatletter-and-makeatother-do
  " In short: allow @ in multicharacter macro name
  syntax region texRegionSty matchgroup=texCmd start='\\makeatletter' end='\\makeatother' contains=TOP
  syntax match texCmdSty "\\[a-zA-Z@]\+" contained containedin=texRegionSty

  " Add @NoSpell for commands per configuration
  for l:macro in g:vimtex_syntax_nospell_commands
    execute 'syntax match texCmd skipwhite skipnl "\\' . l:macro . '"'
          \ 'nextgroup=texVimtexNoSpell'
  endfor
  call vimtex#syntax#core#new_cmd_arg('texVimtexNoSpell', '', '@NoSpell')

  " Sections and parts
  syntax match texCmdParts "\\\(front\|main\|back\)matter\>"
  syntax match texCmdParts nextgroup=texPartTitle "\\part\>"
  syntax match texCmdParts nextgroup=texPartTitle "\\chapter\>"
  syntax match texCmdParts nextgroup=texPartTitle "\\\(sub\)*section\>"
  syntax match texCmdParts nextgroup=texPartTitle "\\\(sub\)\?paragraph\>"
  call vimtex#syntax#core#new_cmd_arg('texPartTitle', '', 'TOP')

  " }}}2
  " {{{2 Environments

  syntax match texCmdEnv "\v\\%(begin|end)>" nextgroup=texEnvName
  call vimtex#syntax#core#new_cmd_arg('texEnvName', 'texEnvModifier')
  call vimtex#syntax#core#new_cmd_opt('texEnvModifier', '', 'texComment,@NoSpell')

  syntax match texCmdEnvMath "\v\\%(begin|end)>" contained nextgroup=texEnvMathName
  call vimtex#syntax#core#new_cmd_arg('texEnvMathName', '')

  " }}}2
  " {{{2 Verbatim

  " Verbatim environment
  syntax region texRegionVerb
        \ start="\\begin{[vV]erbatim}" end="\\end{[vV]erbatim}"
        \ keepend contains=texCmdEnv,texEnvName

  " Verbatim inline
  syntax match texCmd "\\verb\>\*\?" nextgroup=texRegionVerbInline
  if l:cfg.is_style_document
    syntax region texRegionVerbInline matchgroup=Delimiter
          \ start="\z([^\ta-zA-Z@]\)" end="\z1" contained
  else
    syntax region texRegionVerbInline matchgroup=Delimiter
          \ start="\z([^\ta-zA-Z]\)" end="\z1" contained
  endif

  " }}}2
  " {{{2 Various TeX symbols

  syntax match texSymbolString "\v%(``|''|,,)"
  syntax match texSymbolDash "--"
  syntax match texSymbolDash "---"
  syntax match texSymbolAmp "&"

  " E.g.:  \$ \& \% \# \{ \} \_ \S \P
  syntax match texSpecialChar "\\[$&%#{}_]"
  if l:cfg.is_style_document
    syntax match texSpecialChar "\\[SP@]\ze[^a-zA-Z@]"
  else
    syntax match texSpecialChar "\\[SP@]\ze\A"
  endif
  syntax match texSpecialChar "\\\\"
  syntax match texSpecialChar "\^\^\%(\S\|[0-9a-f]\{2}\)"

  " }}}2
  " {{{2 Math

  syntax match texOnlyMath "[_^]" contained

  syntax cluster texClusterMath contains=texCmdEnvMath,texEnvMathName,texComment,texSymbolAmp,texGreek,texLength,texMatcherMath,texMathDelim,texMathOper,texMathSymbol,texMathSymbol,texMathText,texCmdRef,texSpecialChar,texCmd,texSubscript,texSuperscript,texCmdSize,texCmdStyle,@NoSpell
  syntax cluster texClusterMathMatch contains=texComment,texCmdDef,texSymbolAmp,texGreek,texLength,texCmdLigature,texSymbolDash,texMatcherMath,texMathDelim,texMathOper,texMathSymbol,texCmdNewcmd,texCmdNewenv,texRegion,texCmdRef,texSpecialChar,texCmd,texSymbolString,texSubscript,texSuperscript,texCmdSize,texCmdStyle
  syntax region texMatcherMath matchgroup=Delimiter start="{"  skip="\\\\\|\\}" end="}" contained   contains=@texClusterMathMatch

  " Bad/Mismatched math
  syntax match texErrorMath "\\end\s*{\s*\(array\|[bBpvV]matrix\|split\|smallmatrix\)\s*}"
  syntax match texErrorMath "\\[\])]"

  " Operators and similar
  syntax match texMathOper "[_^=]" contained

  " Text Inside Math regions
  syntax region texMathText matchgroup=texCmd start="\\\(\(inter\)\?text\|mbox\)\s*{" end="}" contains=TOP,@Spell

  " Math environments
  call vimtex#syntax#core#new_math_region('displaymath', 1)
  call vimtex#syntax#core#new_math_region('eqnarray', 1)
  call vimtex#syntax#core#new_math_region('equation', 1)
  call vimtex#syntax#core#new_math_region('math', 1)

  " Inline Math Zones
  if l:cfg.conceal.math_bounds && &encoding ==# 'utf-8'
    syntax region texRegionMath matchgroup=Delimiter start="\\("                      matchgroup=Delimiter end="\\)"  concealends contains=@texClusterMath keepend
    syntax region texRegionMath matchgroup=Delimiter start="\\\["                     matchgroup=Delimiter end="\\]"  concealends contains=@texClusterMath keepend
    syntax region texRegionMathX matchgroup=Delimiter start="\$" skip="\\\\\|\\\$"     matchgroup=Delimiter end="\$"   concealends contains=@texClusterMath
    syntax region texRegionMathXX matchgroup=Delimiter start="\$\$"                     matchgroup=Delimiter end="\$\$" concealends contains=@texClusterMath keepend
  else
    syntax region texRegionMath matchgroup=Delimiter start="\\("                      matchgroup=Delimiter end="\\)"  contains=@texClusterMath keepend
    syntax region texRegionMath matchgroup=Delimiter start="\\\["                     matchgroup=Delimiter end="\\]"  contains=@texClusterMath keepend
    syntax region texRegionMathX matchgroup=Delimiter start="\$" skip="\\\\\|\\\$" matchgroup=Delimiter end="\$"   contains=@texClusterMath
    syntax region texRegionMathXX matchgroup=Delimiter start="\$\$"                     matchgroup=Delimiter end="\$\$" contains=@texClusterMath keepend
  endif

  syntax match texCmd "\\ensuremath\>" nextgroup=texRegionMathEnsured
  syntax region texRegionMathEnsured matchgroup=Delimiter
        \ start="{" end="}"
        \ contained
        \ contains=@texClusterMath

  " Math delimiters: \left... and \right...
  syntax match texMathDelimBad contained "\S"
  if l:cfg.conceal.math_delimiters && &encoding ==# 'utf-8'
    syntax match texMathDelim "\\left\["        contained
    syntax match texMathDelim "\\left\\{"       contained skipwhite nextgroup=texMathDelimSet1,texMathDelimSet2,texMathDelimBad contains=texMathSymbol cchar={
    syntax match texMathDelim "\\right\\}"      contained skipwhite nextgroup=texMathDelimSet1,texMathDelimSet2,texMathDelimBad contains=texMathSymbol cchar=}
    syntax match texMathDelim '\\[bB]igg\?[lr]' contained           nextgroup=texMathDelimBad
    call s:match_conceal_math_delims()
  else
    syntax match   texMathDelim      "\\\(left\|right\)\>"   contained skipwhite nextgroup=texMathDelimSet1,texMathDelimSet2,texMathDelimBad
    syntax match   texMathDelim      "\\[bB]igg\?[lr]\?\>"   contained skipwhite nextgroup=texMathDelimSet1,texMathDelimSet2,texMathDelimBad
    syntax match   texMathDelimSet2  "\\"                    contained           nextgroup=texMathDelimKey,texMathDelimBad
    syntax match   texMathDelimSet1  "[<>()[\]|/.]\|\\[{}|]" contained
    syntax keyword texMathDelimKey contained backslash lceil      lVert  rgroup     uparrow
    syntax keyword texMathDelimKey contained downarrow lfloor     rangle rmoustache Uparrow
    syntax keyword texMathDelimKey contained Downarrow lgroup     rbrace rvert      updownarrow
    syntax keyword texMathDelimKey contained langle    lmoustache rceil  rVert      Updownarrow
    syntax keyword texMathDelimKey contained lbrace    lvert      rfloor
  endif
  syntax match texMathDelim contained "\\\(left\|right\)arrow\>\|\<\([aA]rrow\|brace\)\?vert\>"
  syntax match texMathDelim contained "\\lefteqn\>"

  " }}}2
  " {{{2 Conceal mode support

  " Add support for conceal with custom replacement (conceallevel = 2)

  if &encoding ==# 'utf-8'
    if l:cfg.conceal.special_chars
      syntax match texSpecialChar '\\glq\>'  contained conceal cchar=‚
      syntax match texSpecialChar '\\grq\>'  contained conceal cchar=‘
      syntax match texSpecialChar '\\glqq\>' contained conceal cchar=„
      syntax match texSpecialChar '\\grqq\>' contained conceal cchar=“
      syntax match texSpecialChar '\\hyp\>'  contained conceal cchar=-
    endif

    " Many of these symbols were contributed by Björn Winckler
    if l:cfg.conceal.math_delimiters
      call s:match_conceal_math_symbols()
    endif

    " Conceal replace greek letters
    if l:cfg.conceal.greek
      call s:match_conceal_greek()
    endif

    " Conceal replace superscripts and subscripts
    if l:cfg.conceal.super_sub
      call s:match_conceal_super_sub(l:cfg)
    endif

    " Conceal replace accented characters and ligatures
    if l:cfg.conceal.accents && !l:cfg.is_style_document
      call s:match_conceal_accents()
    endif
  endif

  " }}}2

  call s:init_highlights(l:cfg)

  let b:current_syntax = 'tex'
endfunction

" }}}1

function! vimtex#syntax#core#new_cmd_arg(grp, next, ...) abort " {{{1
  let l:contains = a:0 >= 1 ? a:1 : 'texComment'
  let l:options = a:0 >= 2 ? a:2 : ''

  execute 'syntax region' a:grp
        \ 'contained matchgroup=Delimiter start="{" skip="\\\\\|\\}" end="}"'
        \ (empty(l:contains) ? '' : 'contains=' . l:contains)
        \ (empty(a:next) ? '' : 'nextgroup=' . a:next . ' skipwhite skipnl')
        \ l:options
endfunction

" }}}1
function! vimtex#syntax#core#new_cmd_opt(grp, next, ...) abort " {{{1
  let l:contains = a:0 > 0 ? a:1 : 'texComment,texCmd,texLength,texOptSep,texOptEqual'
  let l:options = a:0 >= 2 ? a:2 : ''

  execute 'syntax region' a:grp
        \ 'contained matchgroup=Delimiter start="\[" skip="\\\\\|\\\]" end="\]"'
        \ (empty(l:contains) ? '' : 'contains=' . l:contains)
        \ (empty(a:next) ? '' : 'nextgroup=' . a:next . ' skipwhite skipnl')
        \ l:options
endfunction

" }}}1
function! vimtex#syntax#core#new_math_region(mathzone, starred) abort " {{{1
  execute 'syntax match texErrorMath /\\end\s*{\s*' . a:mathzone . '\*\?\s*}/'

  execute 'syntax region texRegionMathEnv'
        \ . ' start=''\\begin\s*{\s*' . a:mathzone . '\s*}'''
        \ . ' end=''\\end\s*{\s*' . a:mathzone . '\s*}'''
        \ . ' keepend contains=@texClusterMath'

  if !a:starred | return | endif

  execute 'syntax region texRegionMathEnvStarred'
        \ . ' start=''\\begin\s*{\s*' . a:mathzone . '\*\s*}'''
        \ . ' end=''\\end\s*{\s*' . a:mathzone . '\*\s*}'''
        \ . ' keepend contains=@texClusterMath'
endfunction

" }}}1


function! s:init_highlights(cfg) abort " {{{1
  " See :help group-names for list of conventional group names

  " Basic TeX highlighting groups
  highlight def link texCmd              Statement
  highlight def link texCmdSpaceCodeChar Special
  highlight def link texCmdTodo          Todo
  highlight def link texComment          Comment
  highlight def link texCommentTodo      Todo
  highlight def link texEnvName          PreCondit
  highlight def link texEnvMathName      Delimiter
  highlight def link texError            Error
  highlight def link texGenericArg       Include
  highlight def link texGenericOpt       Identifier
  highlight def link texGenericParm      Special
  highlight def link texGenericSep       NormalNC
  highlight def link texLength           Number
  highlight def link texMath             Special
  highlight def link texMathDelim        Statement
  highlight def link texMathOper         Operator
  highlight def link texRef              Special
  highlight def link texRegion           PreCondit
  highlight def link texSpecialChar      SpecialChar
  highlight def link texSymbol           SpecialChar
  highlight def link texSymbolString     String
  highlight def link texTitle            String
  highlight def link texType             Type

  highlight def texStyleBold gui=bold        cterm=bold
  highlight def texStyleItal gui=italic      cterm=italic
  highlight def texStyleBoth gui=bold,italic cterm=bold,italic

  " Inherited groups
  highlight def link texCmdAccent            texCmd
  highlight def link texCmdDef               texCmd
  highlight def link texCmdEnv               texCmd
  highlight def link texCmdEnvMath           texCmdEnv
  highlight def link texCmdError             texError
  highlight def link texCmdLigature          texSpecialChar
  highlight def link texCmdNewcmd            texCmd
  highlight def link texCmdNewenv            texCmd
  highlight def link texCmdParts             texCmd
  highlight def link texCmdRef               texCmd
  highlight def link texCmdSize              texType
  highlight def link texCmdSpaceCode         texCmd
  highlight def link texCmdSty               texCmd
  highlight def link texCmdStyle             texCmd
  highlight def link texCmdStyle             texType
  highlight def link texCmdStyleBold         texCmd
  highlight def link texCmdStyleBoldItal     texCmd
  highlight def link texCmdStyleItal         texCmd
  highlight def link texCmdStyleItalBold     texCmd
  highlight def link texCommentAcronym       texComment
  highlight def link texCommentURL           texComment
  highlight def link texDefName              texCmd
  highlight def link texErrorMath            texError
  highlight def link texFileArg              texGenericArg
  highlight def link texFileArgs             texGenericArg
  highlight def link texFileOpt              texGenericOpt
  highlight def link texFileOpts             texGenericOpt
  highlight def link texGreek                texCmd
  highlight def link texMatcherMath          texMath
  highlight def link texMathDelimBad         texError
  highlight def link texMathDelimKey         texMathDelim
  highlight def link texMathDelimSet1        texMathDelim
  highlight def link texMathDelimSet2        texMathDelim
  highlight def link texMathSymbol           texCmd
  highlight def link texNewcmdName           texCmd
  highlight def link texNewcmdOpt            texGenericOpt
  highlight def link texNewcmdParm           texGenericParm
  highlight def link texNewenvName           texEnvName
  highlight def link texNewenvOpt            texGenericOpt
  highlight def link texNewenvParm           texGenericParm
  highlight def link texOptEqual             texSymbol
  highlight def link texOptSep               texGenericSep
  highlight def link texOnlyMath             texError
  highlight def link texPartTitle            texTitle
  highlight def link texRefCite              texRegionRef
  highlight def link texRefOpt               texGenericOpt
  highlight def link texRegionMath           texMath
  highlight def link texRegionMathEnsured    texMath
  highlight def link texRegionMathEnv        texMath
  highlight def link texRegionMathEnvStarred texMath
  highlight def link texRegionMathX          texMath
  highlight def link texRegionMathXX         texMath
  highlight def link texRegionVerb           texRegion
  highlight def link texRegionVerbInline     texRegionVerb
  highlight def link texSubscript            texCmd
  highlight def link texSubscripts           texSubscript
  highlight def link texSuperscript          texCmd
  highlight def link texSuperscripts         texSuperscript
  highlight def link texSymbolAmp            texSymbol
  highlight def link texSymbolDash           texSymbol
endfunction

" }}}1

function! s:match_bold_italic(cfg) abort " {{{1
  let [l:conceal, l:concealends] =
        \ (a:cfg.conceal.styles ? ['conceal', 'concealends'] : ['', ''])

  syntax cluster texClusterBold contains=TOP,texCmdStyleItal,texCmdStyleBold,texCmdStyleItalBold
  syntax cluster texClusterItal contains=TOP,texCmdStyleItal,texCmdStyleBold,texCmdStyleBoldItal
  syntax cluster texClusterItalBold contains=TOP,texCmdStyleItal,texCmdStyleBold,texCmdStyleItalBold,texCmdStyleBoldItal

  let l:map = {
        \ 'texCmdStyleBold': 'texStyleBold',
        \ 'texCmdStyleBoldItal': 'texStyleBoth',
        \ 'texCmdStyleItal': 'texStyleItal',
        \ 'texCmdStyleItalBold': 'texStyleBoth',
        \}

  for [l:group, l:pattern] in [
        \ ['texCmdStyleBoldItal', 'emph'],
        \ ['texCmdStyleBoldItal', 'textit'],
        \ ['texCmdStyleBoldItal', 'texts[cfl]'],
        \ ['texCmdStyleBoldItal', 'texttt'],
        \ ['texCmdStyleBoldItal', 'textup'],
        \ ['texCmdStyleItalBold', 'textbf'],
        \ ['texCmdStyleBold', 'textbf'],
        \ ['texCmdStyleItal', 'emph'],
        \ ['texCmdStyleItal', 'textit'],
        \ ['texCmdStyleItal', 'texts[cfl]'],
        \ ['texCmdStyleItal', 'texttt'],
        \ ['texCmdStyleItal', 'textup'],
        \]
    execute 'syntax match' l:group '"\\' . l:pattern . '\>\s*"'
          \ 'nextgroup=' . l:map[l:group] l:conceal
  endfor

  execute 'syntax region texStyleBold matchgroup=Delimiter start=/{/ end=/}/'
        \ 'contained contains=@texClusterBold' l:concealends
  execute 'syntax region texStyleItal matchgroup=Delimiter start=/{/ end=/}/'
        \ 'contained contains=@texClusterItal' l:concealends
  execute 'syntax region texStyleBoth matchgroup=Delimiter start=/{/ end=/}/'
        \ 'contained contains=@texClusterItalBold' l:concealends
endfunction

" }}}1

function! s:match_conceal_math_delims() abort " {{{1
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?<"             contained conceal cchar=<
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?>"             contained conceal cchar=>
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?("             contained conceal cchar=(
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?)"             contained conceal cchar=)
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\["            contained conceal cchar=[
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?]"             contained conceal cchar=]
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\{"           contained conceal cchar={
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\}"           contained conceal cchar=}
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?|"             contained conceal cchar=|
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\|"           contained conceal cchar=‖
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\downarrow"   contained conceal cchar=↓
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\Downarrow"   contained conceal cchar=⇓
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\lbrace"      contained conceal cchar=[
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\lceil"       contained conceal cchar=⌈
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\lfloor"      contained conceal cchar=⌊
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\lgroup"      contained conceal cchar=⌊
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\lmoustache"  contained conceal cchar=⎛
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\rbrace"      contained conceal cchar=]
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\rceil"       contained conceal cchar=⌉
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\rfloor"      contained conceal cchar=⌋
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\rgroup"      contained conceal cchar=⌋
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\rmoustache"  contained conceal cchar=⎞
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\uparrow"     contained conceal cchar=↑
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\Uparrow"     contained conceal cchar=↑
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\updownarrow" contained conceal cchar=↕
  syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\Updownarrow" contained conceal cchar=⇕

  if &ambiwidth ==# 'double'
    syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\langle" contained conceal cchar=〈
    syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\rangle" contained conceal cchar=〉
  else
    syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\langle" contained conceal cchar=<
    syntax match texMathSymbol "\\[bB]igg\?[lr]\?\\rangle" contained conceal cchar=>
  endif
endfunction

" }}}1
function! s:match_conceal_math_symbols() abort " {{{1
  syntax match texMathSymbol "\\|"                   contained conceal cchar=‖
  syntax match texMathSymbol "\\aleph\>"             contained conceal cchar=ℵ
  syntax match texMathSymbol "\\amalg\>"             contained conceal cchar=∐
  syntax match texMathSymbol "\\angle\>"             contained conceal cchar=∠
  syntax match texMathSymbol "\\approx\>"            contained conceal cchar=≈
  syntax match texMathSymbol "\\ast\>"               contained conceal cchar=∗
  syntax match texMathSymbol "\\asymp\>"             contained conceal cchar=≍
  syntax match texMathSymbol "\\backslash\>"         contained conceal cchar=∖
  syntax match texMathSymbol "\\bigcap\>"            contained conceal cchar=∩
  syntax match texMathSymbol "\\bigcirc\>"           contained conceal cchar=○
  syntax match texMathSymbol "\\bigcup\>"            contained conceal cchar=∪
  syntax match texMathSymbol "\\bigodot\>"           contained conceal cchar=⊙
  syntax match texMathSymbol "\\bigoplus\>"          contained conceal cchar=⊕
  syntax match texMathSymbol "\\bigotimes\>"         contained conceal cchar=⊗
  syntax match texMathSymbol "\\bigsqcup\>"          contained conceal cchar=⊔
  syntax match texMathSymbol "\\bigtriangledown\>"   contained conceal cchar=∇
  syntax match texMathSymbol "\\bigtriangleup\>"     contained conceal cchar=∆
  syntax match texMathSymbol "\\bigvee\>"            contained conceal cchar=⋁
  syntax match texMathSymbol "\\bigwedge\>"          contained conceal cchar=⋀
  syntax match texMathSymbol "\\bot\>"               contained conceal cchar=⊥
  syntax match texMathSymbol "\\bowtie\>"            contained conceal cchar=⋈
  syntax match texMathSymbol "\\bullet\>"            contained conceal cchar=•
  syntax match texMathSymbol "\\cap\>"               contained conceal cchar=∩
  syntax match texMathSymbol "\\cdot\>"              contained conceal cchar=·
  syntax match texMathSymbol "\\cdots\>"             contained conceal cchar=⋯
  syntax match texMathSymbol "\\circ\>"              contained conceal cchar=∘
  syntax match texMathSymbol "\\clubsuit\>"          contained conceal cchar=♣
  syntax match texMathSymbol "\\cong\>"              contained conceal cchar=≅
  syntax match texMathSymbol "\\coprod\>"            contained conceal cchar=∐
  syntax match texMathSymbol "\\copyright\>"         contained conceal cchar=©
  syntax match texMathSymbol "\\cup\>"               contained conceal cchar=∪
  syntax match texMathSymbol "\\dagger\>"            contained conceal cchar=†
  syntax match texMathSymbol "\\dashv\>"             contained conceal cchar=⊣
  syntax match texMathSymbol "\\ddagger\>"           contained conceal cchar=‡
  syntax match texMathSymbol "\\ddots\>"             contained conceal cchar=⋱
  syntax match texMathSymbol "\\diamond\>"           contained conceal cchar=⋄
  syntax match texMathSymbol "\\diamondsuit\>"       contained conceal cchar=♢
  syntax match texMathSymbol "\\div\>"               contained conceal cchar=÷
  syntax match texMathSymbol "\\doteq\>"             contained conceal cchar=≐
  syntax match texMathSymbol "\\dots\>"              contained conceal cchar=…
  syntax match texMathSymbol "\\downarrow\>"         contained conceal cchar=↓
  syntax match texMathSymbol "\\Downarrow\>"         contained conceal cchar=⇓
  syntax match texMathSymbol "\\ell\>"               contained conceal cchar=ℓ
  syntax match texMathSymbol "\\emptyset\>"          contained conceal cchar=∅
  syntax match texMathSymbol "\\equiv\>"             contained conceal cchar=≡
  syntax match texMathSymbol "\\exists\>"            contained conceal cchar=∃
  syntax match texMathSymbol "\\flat\>"              contained conceal cchar=♭
  syntax match texMathSymbol "\\forall\>"            contained conceal cchar=∀
  syntax match texMathSymbol "\\frown\>"             contained conceal cchar=⁔
  syntax match texMathSymbol "\\ge\>"                contained conceal cchar=≥
  syntax match texMathSymbol "\\geq\>"               contained conceal cchar=≥
  syntax match texMathSymbol "\\gets\>"              contained conceal cchar=←
  syntax match texMathSymbol "\\gg\>"                contained conceal cchar=⟫
  syntax match texMathSymbol "\\hbar\>"              contained conceal cchar=ℏ
  syntax match texMathSymbol "\\heartsuit\>"         contained conceal cchar=♡
  syntax match texMathSymbol "\\hookleftarrow\>"     contained conceal cchar=↩
  syntax match texMathSymbol "\\hookrightarrow\>"    contained conceal cchar=↪
  syntax match texMathSymbol "\\iff\>"               contained conceal cchar=⇔
  syntax match texMathSymbol "\\Im\>"                contained conceal cchar=ℑ
  syntax match texMathSymbol "\\imath\>"             contained conceal cchar=ɩ
  syntax match texMathSymbol "\\in\>"                contained conceal cchar=∈
  syntax match texMathSymbol "\\infty\>"             contained conceal cchar=∞
  syntax match texMathSymbol "\\int\>"               contained conceal cchar=∫
  syntax match texMathSymbol "\\jmath\>"             contained conceal cchar=𝚥
  syntax match texMathSymbol "\\land\>"              contained conceal cchar=∧
  syntax match texMathSymbol "\\lceil\>"             contained conceal cchar=⌈
  syntax match texMathSymbol "\\ldots\>"             contained conceal cchar=…
  syntax match texMathSymbol "\\le\>"                contained conceal cchar=≤
  syntax match texMathSymbol "\\left|"               contained conceal cchar=|
  syntax match texMathSymbol "\\left\\|"             contained conceal cchar=‖
  syntax match texMathSymbol "\\left("               contained conceal cchar=(
  syntax match texMathSymbol "\\left\["              contained conceal cchar=[
  syntax match texMathSymbol "\\left\\{"             contained conceal cchar={
  syntax match texMathSymbol "\\leftarrow\>"         contained conceal cchar=←
  syntax match texMathSymbol "\\Leftarrow\>"         contained conceal cchar=⇐
  syntax match texMathSymbol "\\leftharpoondown\>"   contained conceal cchar=↽
  syntax match texMathSymbol "\\leftharpoonup\>"     contained conceal cchar=↼
  syntax match texMathSymbol "\\leftrightarrow\>"    contained conceal cchar=↔
  syntax match texMathSymbol "\\Leftrightarrow\>"    contained conceal cchar=⇔
  syntax match texMathSymbol "\\leq\>"               contained conceal cchar=≤
  syntax match texMathSymbol "\\leq\>"               contained conceal cchar=≤
  syntax match texMathSymbol "\\lfloor\>"            contained conceal cchar=⌊
  syntax match texMathSymbol "\\ll\>"                contained conceal cchar=≪
  syntax match texMathSymbol "\\lmoustache\>"        contained conceal cchar=╭
  syntax match texMathSymbol "\\lor\>"               contained conceal cchar=∨
  syntax match texMathSymbol "\\mapsto\>"            contained conceal cchar=↦
  syntax match texMathSymbol "\\mid\>"               contained conceal cchar=∣
  syntax match texMathSymbol "\\models\>"            contained conceal cchar=╞
  syntax match texMathSymbol "\\mp\>"                contained conceal cchar=∓
  syntax match texMathSymbol "\\nabla\>"             contained conceal cchar=∇
  syntax match texMathSymbol "\\natural\>"           contained conceal cchar=♮
  syntax match texMathSymbol "\\ne\>"                contained conceal cchar=≠
  syntax match texMathSymbol "\\nearrow\>"           contained conceal cchar=↗
  syntax match texMathSymbol "\\neg\>"               contained conceal cchar=¬
  syntax match texMathSymbol "\\neq\>"               contained conceal cchar=≠
  syntax match texMathSymbol "\\ni\>"                contained conceal cchar=∋
  syntax match texMathSymbol "\\notin\>"             contained conceal cchar=∉
  syntax match texMathSymbol "\\nwarrow\>"           contained conceal cchar=↖
  syntax match texMathSymbol "\\odot\>"              contained conceal cchar=⊙
  syntax match texMathSymbol "\\oint\>"              contained conceal cchar=∮
  syntax match texMathSymbol "\\ominus\>"            contained conceal cchar=⊖
  syntax match texMathSymbol "\\oplus\>"             contained conceal cchar=⊕
  syntax match texMathSymbol "\\oslash\>"            contained conceal cchar=⊘
  syntax match texMathSymbol "\\otimes\>"            contained conceal cchar=⊗
  syntax match texMathSymbol "\\owns\>"              contained conceal cchar=∋
  syntax match texMathSymbol "\\P\>"                 contained conceal cchar=¶
  syntax match texMathSymbol "\\parallel\>"          contained conceal cchar=║
  syntax match texMathSymbol "\\partial\>"           contained conceal cchar=∂
  syntax match texMathSymbol "\\perp\>"              contained conceal cchar=⊥
  syntax match texMathSymbol "\\pm\>"                contained conceal cchar=±
  syntax match texMathSymbol "\\prec\>"              contained conceal cchar=≺
  syntax match texMathSymbol "\\preceq\>"            contained conceal cchar=⪯
  syntax match texMathSymbol "\\prime\>"             contained conceal cchar=′
  syntax match texMathSymbol "\\prod\>"              contained conceal cchar=∏
  syntax match texMathSymbol "\\propto\>"            contained conceal cchar=∝
  syntax match texMathSymbol "\\rceil\>"             contained conceal cchar=⌉
  syntax match texMathSymbol "\\Re\>"                contained conceal cchar=ℜ
  syntax match texMathSymbol "\\quad\>"              contained conceal cchar= 
  syntax match texMathSymbol "\\qquad\>"             contained conceal cchar= 
  syntax match texMathSymbol "\\rfloor\>"            contained conceal cchar=⌋
  syntax match texMathSymbol "\\right|"              contained conceal cchar=|
  syntax match texMathSymbol "\\right\\|"            contained conceal cchar=‖
  syntax match texMathSymbol "\\right)"              contained conceal cchar=)
  syntax match texMathSymbol "\\right]"              contained conceal cchar=]
  syntax match texMathSymbol "\\right\\}"            contained conceal cchar=}
  syntax match texMathSymbol "\\rightarrow\>"        contained conceal cchar=→
  syntax match texMathSymbol "\\Rightarrow\>"        contained conceal cchar=⇒
  syntax match texMathSymbol "\\rightleftharpoons\>" contained conceal cchar=⇌
  syntax match texMathSymbol "\\rmoustache\>"        contained conceal cchar=╮
  syntax match texMathSymbol "\\S\>"                 contained conceal cchar=§
  syntax match texMathSymbol "\\searrow\>"           contained conceal cchar=↘
  syntax match texMathSymbol "\\setminus\>"          contained conceal cchar=∖
  syntax match texMathSymbol "\\sharp\>"             contained conceal cchar=♯
  syntax match texMathSymbol "\\sim\>"               contained conceal cchar=∼
  syntax match texMathSymbol "\\simeq\>"             contained conceal cchar=⋍
  syntax match texMathSymbol "\\smile\>"             contained conceal cchar=‿
  syntax match texMathSymbol "\\spadesuit\>"         contained conceal cchar=♠
  syntax match texMathSymbol "\\sqcap\>"             contained conceal cchar=⊓
  syntax match texMathSymbol "\\sqcup\>"             contained conceal cchar=⊔
  syntax match texMathSymbol "\\sqsubset\>"          contained conceal cchar=⊏
  syntax match texMathSymbol "\\sqsubseteq\>"        contained conceal cchar=⊑
  syntax match texMathSymbol "\\sqsupset\>"          contained conceal cchar=⊐
  syntax match texMathSymbol "\\sqsupseteq\>"        contained conceal cchar=⊒
  syntax match texMathSymbol "\\star\>"              contained conceal cchar=✫
  syntax match texMathSymbol "\\subset\>"            contained conceal cchar=⊂
  syntax match texMathSymbol "\\subseteq\>"          contained conceal cchar=⊆
  syntax match texMathSymbol "\\succ\>"              contained conceal cchar=≻
  syntax match texMathSymbol "\\succeq\>"            contained conceal cchar=⪰
  syntax match texMathSymbol "\\sum\>"               contained conceal cchar=∑
  syntax match texMathSymbol "\\supset\>"            contained conceal cchar=⊃
  syntax match texMathSymbol "\\supseteq\>"          contained conceal cchar=⊇
  syntax match texMathSymbol "\\surd\>"              contained conceal cchar=√
  syntax match texMathSymbol "\\swarrow\>"           contained conceal cchar=↙
  syntax match texMathSymbol "\\times\>"             contained conceal cchar=×
  syntax match texMathSymbol "\\to\>"                contained conceal cchar=→
  syntax match texMathSymbol "\\top\>"               contained conceal cchar=⊤
  syntax match texMathSymbol "\\triangle\>"          contained conceal cchar=∆
  syntax match texMathSymbol "\\triangleleft\>"      contained conceal cchar=⊲
  syntax match texMathSymbol "\\triangleright\>"     contained conceal cchar=⊳
  syntax match texMathSymbol "\\uparrow\>"           contained conceal cchar=↑
  syntax match texMathSymbol "\\Uparrow\>"           contained conceal cchar=⇑
  syntax match texMathSymbol "\\updownarrow\>"       contained conceal cchar=↕
  syntax match texMathSymbol "\\Updownarrow\>"       contained conceal cchar=⇕
  syntax match texMathSymbol "\\vdash\>"             contained conceal cchar=⊢
  syntax match texMathSymbol "\\vdots\>"             contained conceal cchar=⋮
  syntax match texMathSymbol "\\vee\>"               contained conceal cchar=∨
  syntax match texMathSymbol "\\wedge\>"             contained conceal cchar=∧
  syntax match texMathSymbol "\\wp\>"                contained conceal cchar=℘
  syntax match texMathSymbol "\\wr\>"                contained conceal cchar=≀

  if &ambiwidth ==# 'double'
    syntax match texMathSymbol "right\\rangle\>" contained conceal cchar=〉
    syntax match texMathSymbol "left\\langle\>"  contained conceal cchar=〈
    syntax match texMathSymbol '\\gg\>'          contained conceal cchar=≫
    syntax match texMathSymbol '\\ll\>'          contained conceal cchar=≪
  else
    syntax match texMathSymbol "right\\rangle\>" contained conceal cchar=>
    syntax match texMathSymbol "left\\langle\>"  contained conceal cchar=<
    syntax match texMathSymbol '\\gg\>'          contained conceal cchar=⟫
    syntax match texMathSymbol '\\ll\>'          contained conceal cchar=⟪
  endif

  syntax match texMathSymbol '\\bar{a}' contained conceal cchar=a̅

  syntax match texMathSymbol '\\dot{A}' contained conceal cchar=Ȧ
  syntax match texMathSymbol '\\dot{a}' contained conceal cchar=ȧ
  syntax match texMathSymbol '\\dot{B}' contained conceal cchar=Ḃ
  syntax match texMathSymbol '\\dot{b}' contained conceal cchar=ḃ
  syntax match texMathSymbol '\\dot{C}' contained conceal cchar=Ċ
  syntax match texMathSymbol '\\dot{c}' contained conceal cchar=ċ
  syntax match texMathSymbol '\\dot{D}' contained conceal cchar=Ḋ
  syntax match texMathSymbol '\\dot{d}' contained conceal cchar=ḋ
  syntax match texMathSymbol '\\dot{E}' contained conceal cchar=Ė
  syntax match texMathSymbol '\\dot{e}' contained conceal cchar=ė
  syntax match texMathSymbol '\\dot{F}' contained conceal cchar=Ḟ
  syntax match texMathSymbol '\\dot{f}' contained conceal cchar=ḟ
  syntax match texMathSymbol '\\dot{G}' contained conceal cchar=Ġ
  syntax match texMathSymbol '\\dot{g}' contained conceal cchar=ġ
  syntax match texMathSymbol '\\dot{H}' contained conceal cchar=Ḣ
  syntax match texMathSymbol '\\dot{h}' contained conceal cchar=ḣ
  syntax match texMathSymbol '\\dot{I}' contained conceal cchar=İ
  syntax match texMathSymbol '\\dot{M}' contained conceal cchar=Ṁ
  syntax match texMathSymbol '\\dot{m}' contained conceal cchar=ṁ
  syntax match texMathSymbol '\\dot{N}' contained conceal cchar=Ṅ
  syntax match texMathSymbol '\\dot{n}' contained conceal cchar=ṅ
  syntax match texMathSymbol '\\dot{O}' contained conceal cchar=Ȯ
  syntax match texMathSymbol '\\dot{o}' contained conceal cchar=ȯ
  syntax match texMathSymbol '\\dot{P}' contained conceal cchar=Ṗ
  syntax match texMathSymbol '\\dot{p}' contained conceal cchar=ṗ
  syntax match texMathSymbol '\\dot{R}' contained conceal cchar=Ṙ
  syntax match texMathSymbol '\\dot{r}' contained conceal cchar=ṙ
  syntax match texMathSymbol '\\dot{S}' contained conceal cchar=Ṡ
  syntax match texMathSymbol '\\dot{s}' contained conceal cchar=ṡ
  syntax match texMathSymbol '\\dot{T}' contained conceal cchar=Ṫ
  syntax match texMathSymbol '\\dot{t}' contained conceal cchar=ṫ
  syntax match texMathSymbol '\\dot{W}' contained conceal cchar=Ẇ
  syntax match texMathSymbol '\\dot{w}' contained conceal cchar=ẇ
  syntax match texMathSymbol '\\dot{X}' contained conceal cchar=Ẋ
  syntax match texMathSymbol '\\dot{x}' contained conceal cchar=ẋ
  syntax match texMathSymbol '\\dot{Y}' contained conceal cchar=Ẏ
  syntax match texMathSymbol '\\dot{y}' contained conceal cchar=ẏ
  syntax match texMathSymbol '\\dot{Z}' contained conceal cchar=Ż
  syntax match texMathSymbol '\\dot{z}' contained conceal cchar=ż

  syntax match texMathSymbol '\\hat{a}' contained conceal cchar=â
  syntax match texMathSymbol '\\hat{A}' contained conceal cchar=Â
  syntax match texMathSymbol '\\hat{c}' contained conceal cchar=ĉ
  syntax match texMathSymbol '\\hat{C}' contained conceal cchar=Ĉ
  syntax match texMathSymbol '\\hat{e}' contained conceal cchar=ê
  syntax match texMathSymbol '\\hat{E}' contained conceal cchar=Ê
  syntax match texMathSymbol '\\hat{g}' contained conceal cchar=ĝ
  syntax match texMathSymbol '\\hat{G}' contained conceal cchar=Ĝ
  syntax match texMathSymbol '\\hat{i}' contained conceal cchar=î
  syntax match texMathSymbol '\\hat{I}' contained conceal cchar=Î
  syntax match texMathSymbol '\\hat{o}' contained conceal cchar=ô
  syntax match texMathSymbol '\\hat{O}' contained conceal cchar=Ô
  syntax match texMathSymbol '\\hat{s}' contained conceal cchar=ŝ
  syntax match texMathSymbol '\\hat{S}' contained conceal cchar=Ŝ
  syntax match texMathSymbol '\\hat{u}' contained conceal cchar=û
  syntax match texMathSymbol '\\hat{U}' contained conceal cchar=Û
  syntax match texMathSymbol '\\hat{w}' contained conceal cchar=ŵ
  syntax match texMathSymbol '\\hat{W}' contained conceal cchar=Ŵ
  syntax match texMathSymbol '\\hat{y}' contained conceal cchar=ŷ
  syntax match texMathSymbol '\\hat{Y}' contained conceal cchar=Ŷ
endfunction

" }}}1
function! s:match_conceal_accents() " {{{1
  for [l:chr; l:targets] in s:map_accents
    for i in range(13)
      if empty(l:targets[i]) | continue | endif
        let l:accent = s:key_accents[i]
        let l:target = l:targets[i]
        if l:accent =~# '\a'
          execute 'syntax match texCmdAccent /' . l:accent . '\%(\s*{' . l:chr . '}\|\s\+' . l:chr . '\)' . '/ conceal cchar=' . l:target
        else
          execute 'syntax match texCmdAccent /' . l:accent . '\s*\%({' . l:chr . '}\|' . l:chr . '\)' . '/ conceal cchar=' . l:target
        endif
    endfor
  endfor

  syntax match texCmdAccent   '\\aa\>' conceal cchar=å
  syntax match texCmdAccent   '\\AA\>' conceal cchar=Å
  syntax match texCmdAccent   '\\o\>'  conceal cchar=ø
  syntax match texCmdAccent   '\\O\>'  conceal cchar=Ø
  syntax match texCmdLigature '\\AE\>' conceal cchar=Æ
  syntax match texCmdLigature '\\ae\>' conceal cchar=æ
  syntax match texCmdLigature '\\oe\>' conceal cchar=œ
  syntax match texCmdLigature '\\OE\>' conceal cchar=Œ
  syntax match texCmdLigature '\\ss\>' conceal cchar=ß
  syntax match texSymbolDash  '--'     conceal cchar=–
  syntax match texSymbolDash  '---'    conceal cchar=—
endfunction

let s:key_accents = [
      \ '\\`',
      \ '\\''',
      \ '\\^',
      \ '\\"',
      \ '\\\~',
      \ '\\\.',
      \ '\\=',
      \ '\\c',
      \ '\\H',
      \ '\\k',
      \ '\\r',
      \ '\\u',
      \ '\\v'
      \]

let s:map_accents = [
      \ ['a',  'à','á','â','ä','ã','ȧ','ā','' ,'' ,'ą','å','ă','ǎ'],
      \ ['A',  'À','Á','Â','Ä','Ã','Ȧ','Ā','' ,'' ,'Ą','Å','Ă','Ǎ'],
      \ ['c',  '' ,'ć','ĉ','' ,'' ,'ċ','' ,'ç','' ,'' ,'' ,'' ,'č'],
      \ ['C',  '' ,'Ć','Ĉ','' ,'' ,'Ċ','' ,'Ç','' ,'' ,'' ,'' ,'Č'],
      \ ['d',  '' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'ď'],
      \ ['D',  '' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'Ď'],
      \ ['e',  'è','é','ê','ë','ẽ','ė','ē','ȩ','' ,'ę','' ,'ĕ','ě'],
      \ ['E',  'È','É','Ê','Ë','Ẽ','Ė','Ē','Ȩ','' ,'Ę','' ,'Ĕ','Ě'],
      \ ['g',  '' ,'ǵ','ĝ','' ,'' ,'ġ','' ,'ģ','' ,'' ,'' ,'ğ','ǧ'],
      \ ['G',  '' ,'Ǵ','Ĝ','' ,'' ,'Ġ','' ,'Ģ','' ,'' ,'' ,'Ğ','Ǧ'],
      \ ['h',  '' ,'' ,'ĥ','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'ȟ'],
      \ ['H',  '' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'Ȟ'],
      \ ['i',  'ì','í','î','ï','ĩ','į','ī','' ,'' ,'į','' ,'ĭ','ǐ'],
      \ ['I',  'Ì','Í','Î','Ï','Ĩ','İ','Ī','' ,'' ,'Į','' ,'Ĭ','Ǐ'],
      \ ['J',  '' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'ǰ'],
      \ ['k',  '' ,'' ,'' ,'' ,'' ,'' ,'' ,'ķ','' ,'' ,'' ,'' ,'ǩ'],
      \ ['K',  '' ,'' ,'' ,'' ,'' ,'' ,'' ,'Ķ','' ,'' ,'' ,'' ,'Ǩ'],
      \ ['l',  '' ,'ĺ','ľ','' ,'' ,'' ,'' ,'ļ','' ,'' ,'' ,'' ,'ľ'],
      \ ['L',  '' ,'Ĺ','Ľ','' ,'' ,'' ,'' ,'Ļ','' ,'' ,'' ,'' ,'Ľ'],
      \ ['n',  '' ,'ń','' ,'' ,'ñ','' ,'' ,'ņ','' ,'' ,'' ,'' ,'ň'],
      \ ['N',  '' ,'Ń','' ,'' ,'Ñ','' ,'' ,'Ņ','' ,'' ,'' ,'' ,'Ň'],
      \ ['o',  'ò','ó','ô','ö','õ','ȯ','ō','' ,'ő','ǫ','' ,'ŏ','ǒ'],
      \ ['O',  'Ò','Ó','Ô','Ö','Õ','Ȯ','Ō','' ,'Ő','Ǫ','' ,'Ŏ','Ǒ'],
      \ ['r',  '' ,'ŕ','' ,'' ,'' ,'' ,'' ,'ŗ','' ,'' ,'' ,'' ,'ř'],
      \ ['R',  '' ,'Ŕ','' ,'' ,'' ,'' ,'' ,'Ŗ','' ,'' ,'' ,'' ,'Ř'],
      \ ['s',  '' ,'ś','ŝ','' ,'' ,'' ,'' ,'ş','' ,'ȿ','' ,'' ,'š'],
      \ ['S',  '' ,'Ś','Ŝ','' ,'' ,'' ,'' ,'Ş','' ,'' ,'' ,'' ,'Š'],
      \ ['t',  '' ,'' ,'' ,'' ,'' ,'' ,'' ,'ţ','' ,'' ,'' ,'' ,'ť'],
      \ ['T',  '' ,'' ,'' ,'' ,'' ,'' ,'' ,'Ţ','' ,'' ,'' ,'' ,'Ť'],
      \ ['u',  'ù','ú','û','ü','ũ','' ,'ū','' ,'ű','ų','ů','ŭ','ǔ'],
      \ ['U',  'Ù','Ú','Û','Ü','Ũ','' ,'Ū','' ,'Ű','Ų','Ů','Ŭ','Ǔ'],
      \ ['w',  '' ,'' ,'ŵ','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,''],
      \ ['W',  '' ,'' ,'Ŵ','' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,''],
      \ ['y',  'ỳ','ý','ŷ','ÿ','ỹ','' ,'' ,'' ,'' ,'' ,'' ,'' ,''],
      \ ['Y',  'Ỳ','Ý','Ŷ','Ÿ','Ỹ','' ,'' ,'' ,'' ,'' ,'' ,'' ,''],
      \ ['z',  '' ,'ź','' ,'' ,'' ,'ż','' ,'' ,'' ,'' ,'' ,'' ,'ž'],
      \ ['Z',  '' ,'Ź','' ,'' ,'' ,'Ż','' ,'' ,'' ,'' ,'' ,'' ,'Ž'],
      \ ['\\i','ì','í','î','ï','ĩ','į','' ,'' ,'' ,'' ,'' ,'ĭ',''],
      \]

" }}}1
function! s:match_conceal_greek() " {{{1
  syntax match texGreek "\\alpha\>"      contained conceal cchar=α
  syntax match texGreek "\\beta\>"       contained conceal cchar=β
  syntax match texGreek "\\gamma\>"      contained conceal cchar=γ
  syntax match texGreek "\\delta\>"      contained conceal cchar=δ
  syntax match texGreek "\\epsilon\>"    contained conceal cchar=ϵ
  syntax match texGreek "\\varepsilon\>" contained conceal cchar=ε
  syntax match texGreek "\\zeta\>"       contained conceal cchar=ζ
  syntax match texGreek "\\eta\>"        contained conceal cchar=η
  syntax match texGreek "\\theta\>"      contained conceal cchar=θ
  syntax match texGreek "\\vartheta\>"   contained conceal cchar=ϑ
  syntax match texGreek "\\iota\>"       contained conceal cchar=ι
  syntax match texGreek "\\kappa\>"      contained conceal cchar=κ
  syntax match texGreek "\\lambda\>"     contained conceal cchar=λ
  syntax match texGreek "\\mu\>"         contained conceal cchar=μ
  syntax match texGreek "\\nu\>"         contained conceal cchar=ν
  syntax match texGreek "\\xi\>"         contained conceal cchar=ξ
  syntax match texGreek "\\pi\>"         contained conceal cchar=π
  syntax match texGreek "\\varpi\>"      contained conceal cchar=ϖ
  syntax match texGreek "\\rho\>"        contained conceal cchar=ρ
  syntax match texGreek "\\varrho\>"     contained conceal cchar=ϱ
  syntax match texGreek "\\sigma\>"      contained conceal cchar=σ
  syntax match texGreek "\\varsigma\>"   contained conceal cchar=ς
  syntax match texGreek "\\tau\>"        contained conceal cchar=τ
  syntax match texGreek "\\upsilon\>"    contained conceal cchar=υ
  syntax match texGreek "\\phi\>"        contained conceal cchar=ϕ
  syntax match texGreek "\\varphi\>"     contained conceal cchar=φ
  syntax match texGreek "\\chi\>"        contained conceal cchar=χ
  syntax match texGreek "\\psi\>"        contained conceal cchar=ψ
  syntax match texGreek "\\omega\>"      contained conceal cchar=ω
  syntax match texGreek "\\Gamma\>"      contained conceal cchar=Γ
  syntax match texGreek "\\Delta\>"      contained conceal cchar=Δ
  syntax match texGreek "\\Theta\>"      contained conceal cchar=Θ
  syntax match texGreek "\\Lambda\>"     contained conceal cchar=Λ
  syntax match texGreek "\\Xi\>"         contained conceal cchar=Ξ
  syntax match texGreek "\\Pi\>"         contained conceal cchar=Π
  syntax match texGreek "\\Sigma\>"      contained conceal cchar=Σ
  syntax match texGreek "\\Upsilon\>"    contained conceal cchar=Υ
  syntax match texGreek "\\Phi\>"        contained conceal cchar=Φ
  syntax match texGreek "\\Chi\>"        contained conceal cchar=Χ
  syntax match texGreek "\\Psi\>"        contained conceal cchar=Ψ
  syntax match texGreek "\\Omega\>"      contained conceal cchar=Ω
endfunction

" }}}1
function! s:match_conceal_super_sub(cfg) " {{{1
  syntax region texSuperscript matchgroup=Delimiter start='\^{' skip="\\\\\|\\}" end='}' contained concealends contains=texSpecialChar,texSuperscripts,texCmd,texSubscript,texSuperscript,texMatcherMath
  syntax region texSubscript   matchgroup=Delimiter start='_{'  skip="\\\\\|\\}" end='}' contained concealends contains=texSpecialChar,texSubscripts,texCmd,texSubscript,texSuperscript,texMatcherMath

  for [l:from, l:to] in filter(copy(s:map_super),
        \ {_, x -> x[0][0] ==# '\' || x[0] =~# '[0-9a-zA-W.,:;+-<>/()=]'})
    execute 'syntax match texSuperscript /\^' . l:from . '/ contained conceal cchar=' . l:to
    execute 'syntax match texSuperscripts /'  . l:from . '/ contained conceal cchar=' . l:to 'nextgroup=texSuperscripts'
  endfor

  for [l:from, l:to] in filter(copy(s:map_sub),
        \ {_, x -> x[0][0] ==# '\' || x[0] =~# '[0-9aehijklmnoprstuvx,+-/().]'})
    execute 'syntax match texSubscript /_' . l:from . '/ contained conceal cchar=' . l:to
    execute 'syntax match texSubscripts /' . l:from . '/ contained conceal cchar=' . l:to . ' nextgroup=texSubscripts'
  endfor
endfunction

let s:map_sub = [
      \ ['0',         '₀'],
      \ ['1',         '₁'],
      \ ['2',         '₂'],
      \ ['3',         '₃'],
      \ ['4',         '₄'],
      \ ['5',         '₅'],
      \ ['6',         '₆'],
      \ ['7',         '₇'],
      \ ['8',         '₈'],
      \ ['9',         '₉'],
      \ ['a',         'ₐ'],
      \ ['e',         'ₑ'],
      \ ['h',         'ₕ'],
      \ ['i',         'ᵢ'],
      \ ['j',         'ⱼ'],
      \ ['k',         'ₖ'],
      \ ['l',         'ₗ'],
      \ ['m',         'ₘ'],
      \ ['n',         'ₙ'],
      \ ['o',         'ₒ'],
      \ ['p',         'ₚ'],
      \ ['r',         'ᵣ'],
      \ ['s',         'ₛ'],
      \ ['t',         'ₜ'],
      \ ['u',         'ᵤ'],
      \ ['v',         'ᵥ'],
      \ ['x',         'ₓ'],
      \ [',',         '︐'],
      \ ['+',         '₊'],
      \ ['-',         '₋'],
      \ ['\/',         'ˏ'],
      \ ['(',         '₍'],
      \ [')',         '₎'],
      \ ['\.',        '‸'],
      \ ['r',         'ᵣ'],
      \ ['v',         'ᵥ'],
      \ ['x',         'ₓ'],
      \ ['\\beta\>',  'ᵦ'],
      \ ['\\delta\>', 'ᵨ'],
      \ ['\\phi\>',   'ᵩ'],
      \ ['\\gamma\>', 'ᵧ'],
      \ ['\\chi\>',   'ᵪ'],
      \]

let s:map_super = [
      \ ['0',  '⁰'],
      \ ['1',  '¹'],
      \ ['2',  '²'],
      \ ['3',  '³'],
      \ ['4',  '⁴'],
      \ ['5',  '⁵'],
      \ ['6',  '⁶'],
      \ ['7',  '⁷'],
      \ ['8',  '⁸'],
      \ ['9',  '⁹'],
      \ ['a',  'ᵃ'],
      \ ['b',  'ᵇ'],
      \ ['c',  'ᶜ'],
      \ ['d',  'ᵈ'],
      \ ['e',  'ᵉ'],
      \ ['f',  'ᶠ'],
      \ ['g',  'ᵍ'],
      \ ['h',  'ʰ'],
      \ ['i',  'ⁱ'],
      \ ['j',  'ʲ'],
      \ ['k',  'ᵏ'],
      \ ['l',  'ˡ'],
      \ ['m',  'ᵐ'],
      \ ['n',  'ⁿ'],
      \ ['o',  'ᵒ'],
      \ ['p',  'ᵖ'],
      \ ['r',  'ʳ'],
      \ ['s',  'ˢ'],
      \ ['t',  'ᵗ'],
      \ ['u',  'ᵘ'],
      \ ['v',  'ᵛ'],
      \ ['w',  'ʷ'],
      \ ['x',  'ˣ'],
      \ ['y',  'ʸ'],
      \ ['z',  'ᶻ'],
      \ ['A',  'ᴬ'],
      \ ['B',  'ᴮ'],
      \ ['D',  'ᴰ'],
      \ ['E',  'ᴱ'],
      \ ['G',  'ᴳ'],
      \ ['H',  'ᴴ'],
      \ ['I',  'ᴵ'],
      \ ['J',  'ᴶ'],
      \ ['K',  'ᴷ'],
      \ ['L',  'ᴸ'],
      \ ['M',  'ᴹ'],
      \ ['N',  'ᴺ'],
      \ ['O',  'ᴼ'],
      \ ['P',  'ᴾ'],
      \ ['R',  'ᴿ'],
      \ ['T',  'ᵀ'],
      \ ['U',  'ᵁ'],
      \ ['V',  'ⱽ'],
      \ ['W',  'ᵂ'],
      \ [',',  '︐'],
      \ [':',  '︓'],
      \ [';',  '︔'],
      \ ['+',  '⁺'],
      \ ['-',  '⁻'],
      \ ['<',  '˂'],
      \ ['>',  '˃'],
      \ ['\/',  'ˊ'],
      \ ['(',  '⁽'],
      \ [')',  '⁾'],
      \ ['\.', '˙'],
      \ ['=',  '˭'],
      \]

" }}}1
