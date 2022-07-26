scriptencoding utf-8

if exists('g:loaded_to_gopr')
    finish
endif
let g:loaded_to_gopr = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=? Gopr lua require('gopr').open_git_pull_request({ remote = <q-args> })
command! -nargs=? Gocd lua require('gopr').open_git_commit_diff({ remote = <q-args> })

let &cpo = s:save_cpo
unlet s:save_cpo
