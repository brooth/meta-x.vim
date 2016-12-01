" File: easycomplete.vim
" Description: Meta-X easyhistory handler
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! mx#handlers#easycomplete#handle(ctx) abort
    if mx#tools#isdebug()
        call mx#tools#log('mx#handlers#easycomplete(' . string(a:ctx) . ')')
    endif

    if get(a:ctx, 'easycomplete')
        if a:ctx.input == 25 "C-y - switch mode
            let a:ctx.easycomplete = a:ctx.easycomplete == 1 ? 2 : 1
            return g:MX_RES_BREAK
        endif

        let key = nr2char(a:ctx.input)
        let keycandidate = {}
        for candidate in a:ctx.candidates
            let easykey = get(candidate, 'easykey', -1)
            if easykey == -1 | continue | endif
            if empty(keycandidate) && key == get(candidate, 'caption', candidate.word)[easykey]
                let keycandidate = candidate
            endif
            unlet candidate.easykey
        endfor
        if !empty(keycandidate)
            let a:ctx.cmd = a:ctx.easycompletepos == 0 ?
                        \   keycandidate.word :
                        \   a:ctx.cmd[:a:ctx.easycompletepos] . keycandidate.word
            let a:ctx.input = a:ctx.easycomplete == 1 ? 13 : 0
            let a:ctx.cursor = get(keycandidate, 'cursor', len(a:ctx.cmd))
        endif

        if a:ctx.input == 27 "Esc
            let a:ctx.input = 0
        endif

        unlet a:ctx.easycomplete
        return
    endif

    if a:ctx.input == 25 "C-y
        if !empty(a:ctx.candidates)
            let a:ctx.easycomplete = 1
            let a:ctx.easycompletepos = max([0, strridx(a:ctx.cmd, ' ', a:ctx.cursor)])

            let taken = []
            for candidate in a:ctx.candidates
                let caption = get(candidate, 'caption', candidate.word)
                for i in range(len(caption))
                    if index(taken, caption[i]) == -1
                        call add(taken, caption[i])
                        let candidate.easykey = i
                        break
                    endif
                endfor
            endfor
        endif
        return g:MX_RES_BREAK
    endif
endfunction
