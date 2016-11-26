" File: cycle.vim
" Description: Meta-X cycle drawer
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! mx#drawers#cycle#draw(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('mx#drawers#cycle#draw(' . string(a:ctx) . ')')
    endif

    let chars = 1
    redraw

    " command {{{
    echohl MxWelcomeSign
    echon a:ctx.welcome_sign
    let chars += len(a:ctx.welcome_sign)

    echohl MxCommand
    let cmd = a:ctx.cmd . ' '
    for i in range(len(cmd))
        if i == a:ctx.cursor | echohl MxCursor | endif
        echon cmd[i]
        if i == a:ctx.cursor | echohl MxCommand | endif
    endfor
    let chars += len(cmd)
    " }}}

    "sepatator {{{
    echon ' '
    let chars += 1
    " }}}

    if !empty(a:ctx.candidates) "complete {{{
        echohl MxComplete
        echon '{'
        let chars += 1
        let shift = a:ctx.candidate_idx + 1
        let len = len(a:ctx.candidates)
        for idx in range(len)
            if idx + shift >= len | let shift = -(len - a:ctx.candidate_idx - 1) | endif
            let candidate = a:ctx.candidates[idx + shift]
            let out = ' ' . candidate.word . ' '

            if (chars + len(out) + 2 + 1) / &columns > g:mx#max_lines - 1
                echon '..'
                let chars += 2
                break
            endif

            echon out
            let chars += len(out)
        endfor
        echon '}'
        let chars += 1
    endif " }}}

    "empty space
    echohl None
    echon repeat(' ', (&columns - chars % &columns))
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
