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

function! mx#tools#deletelastword(str) "{{{
    let pos = len(a:str)
    let wordfound = 0
    for i in reverse(range(pos))
        let pos -= 1
        if a:str[i] =~ '\w' | let wordfound = 1 | elseif wordfound | break | endif
    endfor
    return pos == 0 ? '' : a:str[:pos]
endfunction "}}}

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

function! mx#tools#specialkeystr(code) "{{{
if a:code == "\<BS>" | return '\<BS>'
elseif a:code == "\<Tab>" | return '\<Tab>'
elseif a:code == "\<CR>" | return '\<CR>'
elseif a:code == "\<Enter>" | return '\<Enter>'
elseif a:code == "\<Return>" | return '\<Return>'
elseif a:code == "\<Esc>" | return '\<Esc>'
elseif a:code == "\<Space>" | return '\<Space>'
elseif a:code == "\<Up>" | return '\<Up>'
elseif a:code == "\<Down>" | return '\<Down>'
elseif a:code == "\<Left>" | return '\<Left>'
elseif a:code == "\<Right>" | return '\<Right>'
elseif a:code == "\<F1>" | return '\<F1>'
elseif a:code == "\<F2>" | return '\<F2>'
elseif a:code == "\<F3>" | return '\<F3>'
elseif a:code == "\<F4>" | return '\<F4>'
elseif a:code == "\<F5>" | return '\<F5>'
elseif a:code == "\<F6>" | return '\<F6>'
elseif a:code == "\<F7>" | return '\<F7>'
elseif a:code == "\<F8>" | return '\<F8>'
elseif a:code == "\<F9>" | return '\<F9>'
elseif a:code == "\<F10>" | return '\<F10>'
elseif a:code == "\<F11>" | return '\<F11>'
elseif a:code == "\<F12>" | return '\<F12>'
elseif a:code == "\<Insert>" | return '\<Insert>'
elseif a:code == "\<Del>" | return '\<Del>'
elseif a:code == "\<Home>" | return '\<Home>'
elseif a:code == "\<End>" | return '\<End>'
elseif a:code == "\<PageUp>" | return '\<PageUp>'
elseif a:code == "\<PageDown>" | return '\<PageDown>'
endif
echoerr 'unknown key ' . a:code
endfunction "}}}

function! mx#tools#setdefault(var, val) abort "{{{
    if !exists(a:var)
        exec 'let '.a:var.' = '.string(a:val)
    endif
endfunction "}}}

function! mx#tools#echoerr(msg) abort "{{{
    redraw
    echohl ErrorMsg
    echomsg a:msg
    echohl None
endfunction "}}}

function! mx#tools#PriorityCompare(i1, i2) "{{{
    return a:i1.priority == a:i2.priority ? 0
    \   : a:i1.priority > a:i2.priority ? -1 : 1
endfunction "}}}

function! mx#tools#WordComparator(i1, i2) "{{{
    return a:i1.word != a:i2.word
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
