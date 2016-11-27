" File: history.vim
" Description: Meta-X history handler
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! mx#handlers#history#handle(ctx) abort
    if mx#tools#isdebug()
        call mx#tools#log('mx#handlers#history#handle(' . string(a:ctx) . ')')
    endif

    let nr = get(a:ctx, 'histnr', -1)

    if a:ctx.input != "\<up>" && a:ctx.input != "\<down>"
        if nr != -1 | unlet a:ctx.histnr | endif
        return
    endif

    let histrange = []
    if a:ctx.input == "\<up>"
        if nr == -1
            let nr = histnr(':')
            let a:ctx.histcmd = a:ctx.cmd
            let a:ctx.candidates = []
        else
            let nr = max([1, nr - 1])
        endif

        let histrange = reverse(range(1, nr))

    elseif nr != -1
        if nr >= histnr(':')
            let a:ctx.cmd = a:ctx.histcmd
            unlet a:ctx.histnr
            unlet a:ctx.histcmd
            return
        endif

        let histrange = range(nr + 1, histnr(':'))
    endif

    for idx in histrange
        let histcmd = histget(':', idx)
        if !empty(histcmd) && stridx(histcmd, a:ctx.histcmd) == 0
            let a:ctx.cmd = histcmd
            let a:ctx.histnr = idx
            break
        endif
    endfor

    return or(g:MX_RES_NOAPPLYPATTERN, g:MX_RES_BREAK)
endfunction
