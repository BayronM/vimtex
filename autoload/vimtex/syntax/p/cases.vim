" vimtex - LaTeX plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

scriptencoding utf-8

function! vimtex#syntax#p#cases#load() abort " {{{1
  if has_key(b:vimtex_syntax, 'cases') | return | endif
  let b:vimtex_syntax.cases = 1

  call vimtex#syntax#core#new_region_math('\(sub\)\?numcases', {'starred': 0})
endfunction

" }}}1
