" File: cabbrev.vim
" Description: Meta-X cabbrev source
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! mx#sources#cabbrev#gather(ctx) abort
    let abbr = maparg(a:ctx.pattern, 'c', 1)
    if !empty(abbr)
        return [{'word': abbr, 'priority': 40}]
    endif
    return []
endfunction
