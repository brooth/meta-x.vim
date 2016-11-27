" File: specialkeys.vim
" Description: Meta-X special keys handler
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! mx#handlers#specialkeys#handle(ctx) abort
    if mx#tools#isdebug()
        call mx#tools#log('mx#handlers#specialkeys#handle(' . string(a:ctx) . ')')
    endif

    if a:ctx.input == 27 || a:ctx.input == 3 "Esc, C-c
        return g:MX_RES_EXIT
    elseif a:ctx.input == 13 || a:ctx.input == 10 "CR, C-j
        redraw
        if !empty(a:ctx.cmd)
            call feedkeys(':' . a:ctx.cmd . "\<CR>", '')
            call histadd('cmd', a:ctx.cmd)
        endif
        return g:MX_RES_EXIT "weird C-Space issue
    elseif a:ctx.input == 4 " <C-d>
        redraw
        call feedkeys(':' . a:ctx.cmd . "\<C-d>", '')
        return g:MX_RES_EXIT
    elseif a:ctx.input == "\<C-@>"
        return g:MX_RES_BREAK
    elseif a:ctx.input == "\<BS>" && empty(a:ctx.cmd) "weird BS behavior if no cmd
        return g:MX_RES_BREAK
    endif
endfunction
