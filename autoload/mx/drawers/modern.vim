" File: cycle.vim
" Description: Meta-X cycle drawer
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! mx#drawers#modern#draw(ctx) abort
    if mx#tools#isdebug()
        call mx#tools#log('mx#drawers#modern#draw(' . string(a:ctx) . ')')
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
        call add(content, '{') | let chars += 1

        let roffset = 0
        if a:ctx.candidate_idx != -1
            let selcandidate = a:ctx.candidates[a:ctx.candidate_idx]
            let selcandidate._selected = 1
            let selout = has_key(selcandidate, 'caption') ? selcandidate.caption : selcandidate.word
            let roffset = strdisplaywidth(selout) + 15
        endif

        let lcandidates = a:ctx.candidate_idx < 1 ? [] : a:ctx.candidates[:(a:ctx.candidate_idx - 1)]
        let candidates = s:cutcandidates(lcandidates, &columns - chars - roffset, 1)
        let rcandidates = a:ctx.candidate_idx < 1 ? a:ctx.candidates : a:ctx.candidates[a:ctx.candidate_idx:]
        call extend(candidates, s:cutcandidates(rcandidates, &columns - chars - s:calcchars(candidates) - 3, 0))

        let easycomplete = get(a:ctx, 'easycomplete')
        let easysynname = easycomplete? (a:ctx.easycomplete == 1 ? 'MxEasyRun' : 'MxEasyComplete') : ''
        for candidate in candidates
            let _chars = strdisplaywidth(candidate._caption)

            if has_key(candidate, '_selected')
                call add(syntaxs, {'name': 'MxSelCandidate', 'range': [chars + 2, chars + _chars - 1]})
                unlet candidate._selected
            endif

            if easycomplete
                let easykey = get(candidate, 'easykey', -1)
                if easykey != -1
                    let pos = chars + easykey + 2
                    call add(syntaxs, {'name': easysynname, 'range': [pos, pos]})
                endif
            endif

            call add(content, candidate._caption)
            let chars += _chars
            unlet candidate._caption
        endfor

        call add(content, '}') | let chars += 1
        call add(syntaxs, {'name': 'MxComplete', 'range': [synbegin + 1, chars]})
    endif

    call add(content, repeat(' ', (&columns - chars % &columns) - 2))
    return [content, syntaxs]
endfunction

function! s:cutcandidates(candidates, maxwidth, reverse)
    let chars = 0
    let candidates = []
    for candidate in (a:reverse ? reverse(a:candidates) : a:candidates)
        let candidate._caption = ' ' . (has_key(candidate, 'caption') ? candidate.caption : candidate.word) . ' '
        let chars += strdisplaywidth(candidate._caption)
        call add(candidates, candidate)

        if chars + 3 >= a:maxwidth
            let cutpos = a:maxwidth - chars - 3
            let candidate._caption = a:reverse ?
                \   ' ..' . candidate._caption[-cutpos:] :
                \    candidate._caption[:cutpos-1] . '.. '
            break
        endif
    endfor
    return a:reverse ? reverse(candidates) : candidates
endfunction

function! s:calcchars(arr)
    let chars = 0
    for item in a:arr
        let chars += strdisplaywidth(item._caption)
    endfor
    return chars
endfunction

