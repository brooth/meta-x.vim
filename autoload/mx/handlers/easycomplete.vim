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
            return or(g:MX_RES_BREAK, g:MX_RES_NOAPPLYPATTERN)
        endif

        if type(a:ctx.input) == 0
            let key = nr2char(a:ctx.input)
            let keycandidate = {}
            for candidate in a:ctx.candidates
                let easykey = get(candidate, 'easykey', -1)
                if easykey == -1 | continue | endif
                if empty(keycandidate) && key == candidate.word[easykey]
                    let keycandidate = candidate
                endif
                unlet candidate.easykey
            endfor
        endif

        if !empty(keycandidate)
            let a:ctx.cmd = a:ctx.easycompletepos == 0 ?
                        \   keycandidate.word :
                        \   a:ctx.cmd[:a:ctx.easycompletepos] . keycandidate.word
            let a:ctx.input = a:ctx.easycomplete == 1 ? 13 : 32
            let a:ctx.cursor = len(a:ctx.cmd)
            let a:ctx.pattern = a:ctx.cmd
            unlet a:ctx.easycomplete
            return
        endif

        unlet a:ctx.easycomplete
        return or(g:MX_RES_BREAK, g:MX_RES_NOAPPLYPATTERN)
    endif

    if a:ctx.input == 25 "C-y
        if !empty(a:ctx.candidates)
            let a:ctx.easycomplete = 1
            let a:ctx.easycompletepos = max([0, strridx(a:ctx.cmd, ' ', a:ctx.cursor)])

            let taken = []
            for candidate in a:ctx.candidates
                for i in range(len(candidate.word))
                    if index(taken, candidate.word[i]) == -1
                        call add(taken, candidate.word[i])
                        let candidate.easykey = i
                        break
                    endif
                endfor
            endfor
        endif
        return or(g:MX_RES_BREAK, g:MX_RES_NOAPPLYPATTERN)
    endif
endfunction
