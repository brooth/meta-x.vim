" File: candidates.vim
" Description: Meta-X candidates handler
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

call mx#tools#setdefault('g:mx#sources', {})
call mx#tools#setdefault('g:mx#sources.favorits', {'fn': 'mx#sources#favorits#gather'})
call mx#tools#setdefault('g:mx#sources.feedkeys', {'fn': 'mx#sources#feedkeys#gather'})
call mx#tools#setdefault('g:mx#sources.cabbrevs', {'fn': 'mx#sources#cabbrev#gather'})

let s:sources = []
for k in keys(g:mx#sources)
    let val = copy(g:mx#sources[k])
    let val.name = k
    call add(s:sources, val)
endfor

function! mx#handlers#candidates#handle(ctx) abort
    if mx#tools#isdebug()
        call mx#tools#log('mx#handlers#candidates#handle(' . string(a:ctx) . ')')
    endif

    if !a:ctx.complete || type(nr2char(a:ctx.input)) != 1 | return | endif

    let candidates = []
    for source in s:sources
        let sourcecandidates = call(function(source.fn), [a:ctx])
        if mx#tools#isdebug()
            call mx#tools#log('source: '. source.name .', candidates: '. string(sourcecandidates))
        endif
        call extend(candidates, sourcecandidates)
    endfor

    for candidate in candidates
        if get(candidate, 'priority')
            continue
        endif
        let candidate.priority = 0
        if get(candidate, 'favorit')
            let candidate.priority += 20
        endif
        if stridx(candidate.word, a:ctx.pattern) == 0 "starts with same case
            let candidate.priority += 10
        endif
    endfor

    let candidates = sort(candidates, 'mx#tools#PriorityCompare')
    let candidates = uniq(candidates, 'mx#tools#WordComparator')
    if len(candidates) > g:mx#max_candidates
        let candidates = candidates[:g:mx#max_candidates]
    endif
    let a:ctx.candidates = candidates
endfunction
