" vimtex - LaTeX plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

function! vimtex#syntax#packages#init() abort " {{{1
  if !exists('b:vimtex') || !exists('b:vimtex_syntax') | return | endif

  " Initialize project cache (used e.g. for the minted package)
  if !has_key(b:vimtex, 'syntax')
    let b:vimtex.syntax = {}
  endif

  try
    call vimtex#syntax#p#{b:vimtex.documentclass}#load()
  catch /E117:/
  endtry

  for l:pkg in map(keys(b:vimtex.packages), "substitute(v:val, '-', '_', 'g')")
    try
      call vimtex#syntax#p#{tolower(l:pkg)}#load()
    catch /E117:/
    endtry
  endfor

  for l:pkg in g:vimtex_syntax_autoload_packages
    try
      call vimtex#syntax#p#{l:pkg}#load()
    catch /E117:/
      call vimtex#log#warning('Syntax package does not exist: ' . l:pkg,
            \ 'Please see :help g:vimtex_syntax_autoload_packages')
    endtry
  endfor
endfunction

" }}}1
