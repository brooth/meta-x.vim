" File: cycle.vim
" Description: Meta-X cycle drawer
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! mx#drawers#cycle#draw(ctx) abort
    if mx#tools#isdebug()
        call mx#tools#log('mx#drawers#cycle#draw(' . string(a:ctx) . ')')
    endif

    let chars = 0
    let content = []
    let syntaxs = []

    call add(content, a:ctx.welcome_sign)
    call add(content, a:ctx.cmd . ' ')
    let chars += strdisplaywidth(a:ctx.welcome_sign) + strdisplaywidth(a:ctx.cmd)
    call add(syntaxs, {'name': 'MxCommand', 'range': [0, chars]})
    call add(syntaxs, {'name': 'MxCursor', 'range': [a:ctx.cursor + 1, a:ctx.cursor + 1]})

    call add(content, ' ') | let chars += 1

    if has_key(a:ctx, 'info')
        let msglen = strdisplaywidth(a:ctx.info)
        call add(content, a:ctx.info)
        call add(syntaxs, {'name': 'MxInfoMsg', 'range': [chars, chars + msglen]})
        let chars += msglen
        call add(content, ' ') | let chars += 1
    endif
    if has_key(a:ctx, 'warn')
        let msglen = strdisplaywidth(a:ctx.warn)
        call add(content, a:ctx.warn)
        call add(syntaxs, {'name': 'MxWarningMsg', 'range': [chars, chars + msglen]})
        let chars += msglen
        call add(content, ' ') | let chars += 1
    endif
    if has_key(a:ctx, 'error')
        let msglen = strdisplaywidth(a:ctx.error)
        call add(content, a:ctx.error)
        call add(syntaxs, {'name': 'MxWarningMsg', 'range': [chars, chars + msglen]})
        let chars += msglen
        call add(content, ' ') | let chars += 1
    endif

    if !empty(a:ctx.candidates)
        let synbegin = chars
        let easycomplete = get(a:ctx, 'easycomplete')
        let easysynname = easycomplete? (a:ctx.easycomplete == 1 ? 'MxEasyRun' : 'MxEasyComplete') : ''
        call add(content, '{') | let chars += 1

        let firstcandidate = 0
        let lastcandidate = len(a:ctx.candidates) - 1
        let candidateshown = 0
        let reachedlimit = 0
        let _chars = chars
        for candidate_idx in range(lastcandidate)
            let candidate = a:ctx.candidates[candidate_idx]
            let caption = has_key(candidate, 'caption') ? candidate.caption : candidate.word
            let _chars += strdisplaywidth(caption) + 2

            if a:ctx.candidate_idx == -1 || candidate_idx > a:ctx.candidate_idx
                let candidateshown = 1
            endif
            if candidateshown
                if (_chars + 3) / &columns <= g:mx#max_lines - 1
                    let firstcandidate += 1
                    continue
                else
                    let reachedlimit = 1
                endif
            else
                if reachedlimit
                    let lastcandidate = candidate_idx
                endif
                break
            endif
        endfor

        for candidate_idx in range(firstcandidate, lastcandidate)
            let candidate = a:ctx.candidates[candidate_idx]
            let out = ' ' . (has_key(candidate, 'caption') ? candidate.caption : candidate.word) . ' '
            let _chars = chars
            let chars += strdisplaywidth(out)
            call add(content, out)

            if candidate_idx == a:ctx.candidate_idx
                call add(syntaxs, {'name': 'MxSelCandidate', 'range': [_chars + 2, chars - 1]})
            endif

            if easycomplete
                let easykey = get(candidate, 'easykey', -1)
                if easykey != -1
                    let pos = chars + easykey + 2
                    call add(syntaxs, {'name': easysynname, 'range': [pos, pos]})
                endif
            endif
        endfor

        if reachedlimit
            call add(content, '.. ') | let chars += 3
        endif

        call add(content, '}') | let chars += 1
        call add(syntaxs, {'name': 'MxComplete', 'range': [synbegin + 1, chars]})
    endif

    call add(content, repeat(' ', (&columns - chars % &columns) - 2))
    return [content, syntaxs]
endfunction
