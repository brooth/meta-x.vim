" File: completion.vim
" Description: Meta-X completion handler
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! mx#handlers#completion#handle(ctx) abort
    if mx#tools#isdebug()
        call mx#tools#log('mx#handlers#completion(' . string(a:ctx) . ')')
    endif

    if a:ctx.input == 14 "C-n -> Tab
       let a:ctx.input = 9
    elseif a:ctx.input == 16 "C-p -> S-Tab
       let a:ctx.input = "\<S-Tab>"
    endif

    if a:ctx.input == 9 || a:ctx.input is# "\<S-Tab>"
        if empty(a:ctx.candidates)
            let a:ctx.input = ''
            let a:ctx.pattern = ''
            return g:MX_RES_NOAPPLYPATTERN
        endif

        " if !a:ctx.complete
        "     let a:ctx.complete = 1
        "     let a:ctx.input = ''
        "     return or(g:MX_RES_NODRAWCMDLINE, g:MX_RES_NOINPUT)
        " endif

        if a:ctx.candidate_idx == -1
            let a:ctx.candidate_idx = 0
            let a:ctx.cmdback = a:ctx.cmd
            let a:ctx.completeback = a:ctx.complete
            let a:ctx.complete = 0
            let a:ctx.completepos = max([0, strridx(a:ctx.cmd, ' ', a:ctx.cursor)])
        else
            if a:ctx.input == 9
                let a:ctx.candidate_idx = len(a:ctx.candidates) - 1 <= a:ctx.candidate_idx ?
                    \   0 : a:ctx.candidate_idx + 1
            else
                let a:ctx.candidate_idx = a:ctx.candidate_idx == 0 ?
                    \   len(a:ctx.candidates) - 1 : a:ctx.candidate_idx - 1
            endif
        endif

        let word = a:ctx.candidates[a:ctx.candidate_idx].word
        let a:ctx.cmd = a:ctx.completepos == 0 ? word : a:ctx.cmd[:a:ctx.completepos] . word
        let a:ctx.input = ''
        let a:ctx.pattern = ''

        if len(a:ctx.candidates) == 1
            let a:ctx.candidates = []
        endif

        return g:MX_RES_NOAPPLYPATTERN
    endif

    if a:ctx.candidate_idx != -1
        if a:ctx.input == 27 "Esc
            let a:ctx.cmd = a:ctx.cmdback
            let a:ctx.pattern = a:ctx.cmd
            let a:ctx.input = ''
        endif

        let a:ctx.complete = a:ctx.completeback
        let a:ctx.candidate_idx = -1
        unlet a:ctx.cmdback
        unlet a:ctx.completeback
        unlet a:ctx.completepos
        return 0
    endif
endfunction
