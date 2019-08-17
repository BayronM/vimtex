" vimtex - LaTeX plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

function! vimtex#text_obj#targets#enabled() abort " {{{1
  return exists('g:loaded_targets')
        \ && (   (type(g:loaded_targets) == type(0)  && g:loaded_targets)
        \     || (type(g:loaded_targets) == type('') && !empty(g:loaded_targets)))
        \ && (   g:vimtex_text_obj_variant ==# 'auto'
        \     || g:vimtex_text_obj_variant ==# 'targets')
endfunction

" }}}1
function! vimtex#text_obj#targets#init() abort " {{{1
  let g:vimtex_text_obj_variant = 'targets'

  augroup vimtex_targets
    autocmd!
    autocmd User targets#sources         call s:init_sources()
    autocmd User targets#mappings#plugin call s:init_mappings()
    autocmd BufWinEnter <buffer> ++once  call s:clean_gitgutter_maps()
  augroup END
endfunction

" }}}1

function! s:init_mappings() abort " {{{1
  call targets#mappings#extend({'e': {'tex_env': [{}]}})
  call targets#mappings#extend({'c': {'tex_cmd': [{}]}})
endfunction

" }}}1
function! s:init_sources() abort " {{{1
  call targets#sources#register('tex_env', function('vimtex#text_obj#envtargets#new'))
  call targets#sources#register('tex_cmd', function('vimtex#text_obj#cmdtargets#new'))
endfunction

" }}}1
function! s:clean_gitgutter_maps() abort " {{{1
  xunmap <buffer> ic
  ounmap <buffer> ic
  xunmap <buffer> ac
  ounmap <buffer> ac
endfunction

" }}}1
