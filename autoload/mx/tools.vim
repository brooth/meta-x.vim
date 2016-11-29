" File: meta-x.vim
" Description: Meta-X plugin utils
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

"logging {{{
let s:debug = exists('g:mx#debug')? g:mx#debug : 1
let s:debugfile = $HOME.'/insane.vim.log'

if s:debug
    call writefile(['debug enabled!'], s:debugfile)
endif

function! mx#tools#isdebug()
    return s:debug
endfunction

function! mx#tools#log(msg)
    if s:debug
        call writefile(['[' . strftime("%T") . '] ' .a:msg], s:debugfile, "a")
    endif
endfunction
"}}}

function! mx#tools#cutcmdline() "{{{
    let g:mx#cmdline = getcmdline()
    return ''
endfunction "}}}

function! mx#tools#getcmdpos() "{{{
    let g:mx#cmdpos = getcmdpos()
    return getcmdline()
endfunction "}}}

function! mx#tools#setcmdpos() "{{{
    call setcmdpos(g:mx#cmdpos)
    return getcmdline()
endfunction "}}}

function! mx#tools#setdefault(var, val) abort "{{{
    if !exists(a:var)
        exec 'let '.a:var.' = '.string(a:val)
    endif
endfunction "}}}

function! mx#tools#setdictdefault(dict, key, val) abort "{{{
    if !has_key(a:dict, a:key)
        let a:dict[a:key] = a:val
    endif
endfunction "}}}

function! mx#tools#echoerr(msg) abort "{{{
    redraw
    echohl ErrorMsg
    echomsg a:msg
    echohl None
endfunction "}}}

function! mx#tools#PrioritySorter(i1, i2) "{{{
    return a:i1.priority == a:i2.priority ? 0
    \   : a:i1.priority > a:i2.priority ? -1 : 1
endfunction "}}}

function! mx#tools#WordComparator(i1, i2) "{{{
    return a:i1.word != a:i2.word
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
