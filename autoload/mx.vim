" File: meta-x.vim
" Description: Meta-X plugin backend
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" options "{{{
call mx#tools#setdefault('g:mx#max_lines', 1)
call mx#tools#setdefault('g:mx#max_candidates', 50)

call mx#tools#setdefault('g:mx#favorits', [
    \   {'word': 'find'},
    \   {'word': 'write', 'short': 'w'},
    \   {'word': 'quite', 'short': 'q'},
    \   {'word': 'Far', 'abbr': 'f'},
    \   ])

for fav in g:mx#favorits
    if !get(fav, 'favorit')
        let fav['favorit'] = 1
    endif
endfor

call mx#tools#setdefault('g:mx#handlers', {})
call mx#tools#setdefault('g:mx#handlers.specialkeys', {
    \   'fn': 's:specialkeyshandler',
    \   'priority': 20,
    \   })
call mx#tools#setdefault('g:mx#handlers.default', {
    \   'fn': 's:defaulthandler',
    \   })

let s:handlers = []
for k in keys(g:mx#handlers)
    let val = copy(g:mx#handlers[k])
    let val.name = k
    if !get(val, 'priority')
        let val.priority = 0
    endif
    call add(s:handlers, val)
endfor
let s:handlers = sort(s:handlers, 'mx#tools#PriorityCompare')

call mx#tools#setdefault('g:mx#sources', {})
call mx#tools#setdefault('g:mx#sources.favorits', {
    \   'fn': 's:favoritsource',
    \   })
call mx#tools#setdefault('g:mx#sources.feedkeys', {
    \   'fn': 's:feedkeysource',
    \   })

let s:sources = []
for k in keys(g:mx#sources)
    let val = copy(g:mx#sources[k])
    let val.name = k
    call add(s:sources, val)
endfor
"}}}

function! mx#cutcmdline() "{{{
    let s:cmdline = getcmdline()
    call mx#tools#log('cut cmdline:' . s:cmdline)
    return ''
endfunction "}}}

function! mx#loop(ctx) " {{{
    if mx#tools#isdebug()
        call mx#tools#log('mx#start(' . string(a:ctx) . ')')
    endif

    if !get(a:ctx, 'char')
        let a:ctx.char = ''
    endif

    while 1
        let handled = -1
        for handler in s:handlers
            let handled = call(function(handler.fn), [a:ctx])
            if handled != 0
                break
            endif
        endfor

        if handled == -1
            return
        endif

        call s:drawcxt(a:ctx)
        let a:ctx.char = handled != 2 ? getchar() : ''
    endwhile
endfunction "}}}

function! s:drawcxt(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('drawcxt(' . string(a:ctx) . ')')
    endif

    redraw
    echohl MxCandidates

    let chars = 0
    let candidate_idx = 0
    for candidate in get(a:ctx, 'candidates', [])
        if get(candidate, 'visible', 1)
            let out = candidate.word
            if (chars + len(out) + 2) / &columns > g:mx#max_lines - 1
                echon ' >'
                let chars += 2
                break
            endif

            if !empty(chars)
                echon ' '
                let chars += 1
            endif

            if candidate_idx == a:ctx.candidate_idx
                echohl MxSelCandidate
            endif

            echon out
            let chars += len(out)

            if candidate_idx == a:ctx.candidate_idx
                echohl MxCandidates
            endif
        endif
        let candidate_idx += 1
    endfor
    if chars % &columns != 0
        echon repeat(' ', (&columns - chars % &columns))
    endif

    echohl None
    echon a:ctx.welcome_sign . a:ctx.cmd
endfunction "}}}

function! s:favoritsource(ctx) abort "{{{
    let candidates = []
    for fav in g:mx#favorits
        if '^' . fav.word =~? a:ctx.cmd
            call add(candidates, copy(fav))
        endif
    endfor
    return candidates
endfunction "}}}

function! s:feedkeysource(ctx) abort "{{{
    let candidates = []
    if !empty(a:ctx.cmd)
        silent! call feedkeys(":" . a:ctx.cmd . "\<C-A>\<C-t>\<Esc>", 'x')
        for word in split(s:cmdline, ' ')
            call add(candidates, {'word': word})
        endfor
    endif
    return candidates
endfunction "}}}

function! s:defaulthandler(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('defaulthandler(' . string(a:ctx) . ')')
    endif
    if a:ctx.char != '' && type(a:ctx.char) != 0 " not a number
        return
    endif

    let a:ctx.cmd = a:ctx.cmd . nr2char(a:ctx.char)
    let a:ctx.candidate_idx = -1
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
        if get(candidate, 'abbr', '') ==# a:ctx.cmd
            let candidate.priority += 40
        endif
        if get(candidate, 'favorit')
            let candidate.priority += 20
        endif

        if candidate.word == a:ctx.cmd " same word
            let candidate.priority += 15
        elseif '^' . candidate.word =~# a:ctx.cmd "starts with same case
            let candidate.priority += 10
        elseif '^' . candidate.word =~? a:ctx.cmd "starts with ignore case
            let candidate.priority += 5
        endif
    endfor

    let candidates = sort(candidates, 'mx#tools#PriorityCompare')
    let candidates = uniq(candidates, 'mx#tools#WordComparator')
    if len(candidates) > g:mx#max_candidates
        let candidates = candidates[:g:mx#max_candidates]
    endif
    let a:ctx.candidates = candidates
    return 1
endfunction "}}}

function! s:specialkeyshandler(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('specialkeyshandler(' . string(a:ctx) . ')')
    endif

    if a:ctx.char == 27 || a:ctx.char == 3 "Esc, C-c
        redraw
        return -1
    elseif a:ctx.char == 13 "CR
        redraw
        if !empty(a:ctx.cmd)
            exec a:ctx.cmd
        endif
        return -1
    elseif a:ctx.char == 9 || a:ctx.char is# "\<S-Tab>" "Tab
        if a:ctx.candidate_idx == -1
            let a:ctx.candidate_idx = 0
            call insert(a:ctx.candidates,
            \   {'word': a:ctx.cmd, 'priority': 100, 'visible': 0}, 0)
        endif
        if a:ctx.char == 9
            let a:ctx.candidate_idx = len(a:ctx.candidates)-1 <= a:ctx.candidate_idx?
                \   0 : a:ctx.candidate_idx+1
        else
            let a:ctx.candidate_idx = a:ctx.candidate_idx == 0?
                \   len(a:ctx.candidates)-1 : a:ctx.candidate_idx-1
        endif
        let a:ctx.cmd = a:ctx.candidates[a:ctx.candidate_idx].word
        return 1
    elseif a:ctx.char is# "\<BS>" "Backspace
        let a:ctx.cmd = a:ctx.cmd[:-2]
        return 2
    elseif a:ctx.char == 21 "C-U
        let a:ctx.cmd = ''
        return 2
    endif
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
