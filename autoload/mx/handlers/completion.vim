" File: completion.vim
" Description: Meta-X completion handler
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" options "{{{
call mx#tools#setdefault('g:mx#max_candidates', 50)
call mx#tools#setdefault('g:mx#show_candidates', 1)
"}}}
"
" sources {{{
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
" }}}

function! mx#handlers#completion#handle(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('mx#handlers#completion#handle(' . string(a:ctx) . ')')
    endif

    if !has_key(a:ctx, 'completemode')
        call mx#tools#setdictdefault(a:ctx, 'completemode', g:mx#show_candidates)
        call mx#tools#setdictdefault(a:ctx, 'candidates', [])
        call mx#tools#setdictdefault(a:ctx, 'candidate_idx', -1)
    endif

    if a:ctx.input == 4 "C-d (switch complete mode)
        let a:ctx.completemode = a:ctx.completemode ? 0 : 1
        return
    endif

    if a:ctx.input == 14 "C-n -> Tab
       let a:ctx.input = 9
    elseif a:ctx.input == 16 "C-p -> S-Tab
       let a:ctx.input = "\<S-Tab>"
    endif

    if a:ctx.input == 9 || a:ctx.input is# "\<S-Tab>"
        if a:ctx.completemode == 2
            if a:ctx.input == 9
                let a:ctx.candidate_idx = len(a:ctx.candidates) - 1 <= a:ctx.candidate_idx ?
                    \   0 : a:ctx.candidate_idx + 1
            else
                let a:ctx.candidate_idx = a:ctx.candidate_idx == 0 ?
                    \   len(a:ctx.candidates) - 1 : a:ctx.candidate_idx - 1
            endif
        else
            let a:ctx.candidate_idx = a:ctx.completemode == 0 ? -1 : 0
            let a:ctx.completemodeback = a:ctx.completemode
            let a:ctx.completemode = 2
            let a:ctx.cmdback = a:ctx.cmd
        endif
        let a:ctx.input = ''
        return
    endif

    if a:ctx.completemode == 2 "cycling candidates?
        if a:ctx.input == 27 "Esc
            let a:ctx.cmd = a:ctx.cmdback
            let a:ctx.input = ''
        endif

        let a:ctx.candidate_idx = -1
        let a:ctx.completemode = a:ctx.completemodeback
        unlet a:ctx.cmdback
        unlet a:ctx.completemodeback
    endif
endfunction "}}}

function! mx#handlers#completion#gather(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('mx#handlers#completion#gather(' . string(a:ctx) . ')')
    endif

    if a:ctx.completemode != 2
        let a:ctx.candidates = a:ctx.completemode == 0 ? [] : s:gathercandidates(a:ctx)
        if has_key(a:ctx, 'completepos')
            unlet a:ctx.completepos
        endif
    else
        if !has_key(a:ctx, 'completepos')
            let a:ctx.completepos = max([0, strridx(a:ctx.cmd, ' ', a:ctx.cursor)])
            if a:ctx.candidate_idx == -1 && len(a:ctx.candidates) == 1
                let a:ctx.candidate_idx = 0
            endif
        endif

        if len(a:ctx.candidates) > a:ctx.candidate_idx
            let word = a:ctx.candidates[a:ctx.candidate_idx].word
            let a:ctx.cmd = a:ctx.completepos == 0 ? word : a:ctx.cmd[:a:ctx.completepos] . word
            if len(a:ctx.candidates) == 1
                let a:ctx.candidates = []
            endif
        else
            let a:ctx.candidate_idx = -1
        endif
    endif
endfunction "}}}

function! s:gathercandidates(ctx) abort "{{{
    call mx#tools#log('gathercandidates()')

    let completepos = max([0, strridx(a:ctx.cmd, ' ', a:ctx.cursor)])
    let a:ctx.pattern = a:ctx.cmd[completepos:]
    call mx#tools#log('pattern to complete: "' . a:ctx.pattern . '"')

    let candidates = []
    for src in s:sources
        let sourcecandidates = call(function(src.fn), [a:ctx])
        if mx#tools#isdebug()
            call mx#tools#log('source: '. src.name .', candidates: '. string(sourcecandidates))
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
        if stridx(candidate.word, a:ctx.cmd) == 0 "starts with same case
            let candidate.priority += 10
        endif
    endfor

    let candidates = sort(candidates, 'mx#tools#PriorityCompare')
    let candidates = uniq(candidates, 'mx#tools#WordComparator')
    if len(candidates) > g:mx#max_candidates
        let candidates = candidates[:g:mx#max_candidates]
    endif

    unlet a:ctx.pattern
    return candidates
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
