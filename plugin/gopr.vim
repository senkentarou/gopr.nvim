scriptencoding utf-8

if exists('g:loaded_to_gopr')
    finish
endif
let g:loaded_to_gopr = 1

let s:save_cpo = &cpo
set cpo&vim

command! Gopr lua require('gopr').gopr()

let &cpo = s:save_cpo
unlet s:save_cpo
