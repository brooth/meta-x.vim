" File: cycle.vim
" Description: Meta-X cycle drawer
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! mx#drawers#cycle#draw(ctx) abort
    if mx#tools#isdebug()
        call mx#tools#log('mx#drawers#cycle#draw(' . string(a:ctx) . ')')
    endif

    let chars = 1
    redraw

    echohl MxCommand
    echon a:ctx.welcome_sign
    let chars += strdisplaywidth(a:ctx.welcome_sign)
    let cmd = a:ctx.cmd . ' '
    for i in range(len(cmd))
        if i == a:ctx.cursor | echohl MxCursor | endif
        echon cmd[i]
        if i == a:ctx.cursor | echohl MxCommand | endif
    endfor
    let chars += strdisplaywidth(cmd)

    echon ' ' | let chars += 1

    let info = get(a:ctx, 'info', '')
    if !empty(info)
        echohl MxInfoMsg
        echon info | let chars += strdisplaywidth(info)
        echohl None
        echon ' ' | let chars += 1
    endif

    let warn = get(a:ctx, 'warn', '')
    if !empty(warn)
        echohl MxWarnMsg
        echon warn | let chars += strdisplaywidth(warn)
        echohl None
        echon ' ' | let chars += 1
    endif

    let error = get(a:ctx, 'error', '')
    if !empty(error)
        echohl MxErrorMsg
        echon error | let chars += strdisplaywidth(error)
        echohl None
        echon ' ' | let chars += 1
    endif

    if !empty(a:ctx.candidates)
        echohl MxComplete
        echon '{' | let chars += 1

        let shift = a:ctx.candidate_idx + 1
        let len = len(a:ctx.candidates)
        let easycomplete = get(a:ctx, 'easycomplete')
        for idx in range(len)
            if idx + shift >= len | let shift = -(len - a:ctx.candidate_idx - 1) | endif
            let candidate = a:ctx.candidates[idx + shift]
            let easykey = get(candidate, 'easykey', -1)

            let out = ' ' . candidate.word . ' '

            if (chars + strdisplaywidth(out) + 1) / &columns > g:mx#max_lines - 1
                let out =  out[:&columns * g:mx#max_lines - chars - 5] . '..'
                echon out | let chars += strdisplaywidth(out)
                break
            endif

            if easykey == -1
                echon out
            else
                echon out[:easykey]
                if easycomplete == 1 | echohl MxEasyRun | else | echohl MxEasyComplete | endif
                echon out[easykey + 1]
                echohl MxComplete
                echon out[easykey + 2:]
            endif
            let chars += strdisplaywidth(out)
        endfor

        echon '}' | let chars += 1
    endif

    echohl None
    echon repeat(' ', (&columns - chars % &columns))
endfunction
