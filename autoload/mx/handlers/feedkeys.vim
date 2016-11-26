" File: feedkeys.vim
" Description: Meta-X feedkeys handler
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! mx#handlers#feedkeys#handle(ctx) abort
    if mx#tools#isdebug()
        call mx#tools#log('mx#handlers#feedkeys#handle(' . string(a:ctx) . ')')
    endif

    if empty(a:ctx.input) | return | endif

    let g:mx#cmdpos = a:ctx.cursor + 1
    let keys = ":" . a:ctx.cmd . "\<C-t>P" .
        \   (type(a:ctx.input) == 0 ? nr2char(a:ctx.input) : a:ctx.input) .
        \   "\<C-t>p\<C-t>c\<Esc>"
    call mx#tools#log('keys=' . keys)

    silent! call feedkeys(keys, 'x')

    call mx#tools#log('pos:' . g:mx#cmdpos)
    let a:ctx.cursor = g:mx#cmdpos - 1
    call mx#tools#log('line:' . g:mx#cmdline)
    let a:ctx.pattern = g:mx#cmdline

    return g:MX_RES_NOUPDATECURSOR
endfunction
