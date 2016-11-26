" File: specialkeys.vim
" Description: Meta-X special keys handler
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! mx#handlers#specialkeys#handle(ctx) abort
    if mx#tools#isdebug()
        call mx#tools#log('mx#handlers#specialkeys#handle(' . string(a:ctx) . ')')
    endif

    if a:ctx.input == 27 || a:ctx.input == 3 "Esc, C-c, C-j
        redraw
        echon ''
        return g:MX_RES_EXIT
    elseif a:ctx.input == 13 || a:ctx.input == 10 "CR, C-j
        redraw
        if !empty(a:ctx.cmd)
            call feedkeys(':' . a:ctx.cmd . "\<CR>", '')
        endif
        return g:MX_RES_EXIT
    endif
endfunction
