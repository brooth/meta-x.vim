" File: cycle.vim
" Description: Meta-X cycle drawer
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! s:drawcandidates(ctx, candidates, maxwidth, charsoffset, reverse)
    call mx#tools#log('charsoffset:' . string(a:charsoffset))
    let chars = 0
    let content = []
    let syntaxs = []
    let brk = 0
    let easycomplete = get(a:ctx, 'easycomplete')
    let easysynname = easycomplete? (a:ctx.easycomplete == 1 ? 'MxEasyRun' : 'MxEasyComplete') : ''
    for candidate in (a:reverse ? reverse(a:candidates) : a:candidates)
        let out = ' ' . (has_key(candidate, 'caption') ? candidate.caption : candidate.word) . ' '
        let outlen = strdisplaywidth(out)

        if chars + outlen + 3 >= a:maxwidth
            let cutpos = a:maxwidth - chars - 3
            let out = a:reverse ? ' ..' . out[-cutpos:] : out[:cutpos-1] . '.. '
            let outlen = strdisplaywidth(out)
            let brk = 1
        endif

        if easycomplete
            let easykey = get(candidate, 'easykey', -1)
            if easykey != -1
                let pos = chars + a:charsoffset + easykey + 2
                call add(syntaxs, {'name': easysynname, 'range': [pos, pos]})
            endif
        endif

        call add(content, out)
        let chars += outlen
        if brk | break | endif

    endfor
    return [a:reverse ? reverse(content) : content, syntaxs, chars]
endfunction

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
        call add(content, '{') | let chars += 1

        let roffset = 0
        let selout = ''
        if a:ctx.candidate_idx != -1
            let selcandidate = a:ctx.candidates[a:ctx.candidate_idx]
            let selout = has_key(selcandidate, 'caption') ? selcandidate.caption : selcandidate.word
            let roffset = strdisplaywidth(selout) + 10
        endif

        let lcandidates = a:ctx.candidate_idx < 1 ? [] : a:ctx.candidates[:(a:ctx.candidate_idx - 1)]
        let lresult = s:drawcandidates(a:ctx, lcandidates, &columns - chars - roffset, chars, 1)
        call extend(content, lresult[0])
        call extend(syntaxs, lresult[1])
        let chars += lresult[2]

        if selout != ''
            let seloffset = chars + 1
            call add(syntaxs, {'name': 'MxSelCandidate', 'range': [seloffset + 1, seloffset + strdisplaywidth(selout)]})
        endif

        let rcandidates = a:ctx.candidate_idx < 1 ? a:ctx.candidates : a:ctx.candidates[a:ctx.candidate_idx:]
        let rresult = s:drawcandidates(a:ctx, rcandidates, &columns - chars - 4, chars, 0)
        call extend(content, rresult[0])
        call extend(syntaxs, rresult[1])
        let chars += rresult[2]

        call add(content, '}') | let chars += 1
        call add(syntaxs, {'name': 'MxComplete', 'range': [synbegin + 1, chars]})
    endif

    call add(content, repeat(' ', (&columns - chars % &columns) - 2))
    return [content, syntaxs]
endfunction
