" File: meta-x.vim
" Description: Meta-X plugin utils
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

"logging {{{
let s:debug = exists('g:mx#debug')? g:mx#debug : 1
let s:debugfile = $HOME.'/meta-x.vim.log'

if s:debug
    exec 'redir! > ' . s:debugfile
    silent echon "debug enabled!\n"
    redir END
endif

function! mx#tools#isdebug()
    return s:debug
endfunction

function! mx#tools#log(msg)
    if s:debug
        exec 'redir >> ' . s:debugfile
        silent echon a:msg."\n"
        redir END
    endif
endfunction
"}}}

function! mx#tools#setdefault(var, val) abort "{{{
    if !exists(a:var)
        exec 'let '.a:var.' = '.string(a:val)
    endif
endfunction "}}}

function! mx#tools#PriorityCompare(i1, i2) "{{{
    return get(a:i1, 'priority', 0) == get(a:i2, 'priority', 0) ? 0
    \   : get(a:i1, 'priority', 0) > get(a:i2, 'priority', 0) ? -1 : 1
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
