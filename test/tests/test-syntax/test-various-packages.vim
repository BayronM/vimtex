source common.vim

silent edit test-various-packages.tex

if empty($INMAKE) | finish | endif

call vimtex#test#assert_equal(12, len(keys(b:vimtex_syntax)))

quit!