" File: meta-x.vim
" Description: Meta-X plugin backend
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" options "{{{
call mx#tools#setdefault('g:mx#max_lines', 1)
call mx#tools#setdefault('g:mx#max_candidates', 50)
call mx#tools#setdefault('g:mx#autocomplete', 0)
call mx#tools#setdefault('g:mx#welcome_sign', ':')

call mx#tools#setdefault('g:mx#favorits', [
    \   {'word': 'find'},
    \   {'word': 'write', 'short': 'w'},
    \   {'word': 'quit', 'short': 'q'},
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
call mx#tools#setdefault('g:mx#handlers.tabkey', {
    \   'fn': 's:tabkeyhandler',
    \   'priority': 25,
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
call mx#tools#setdefault('g:mx#sources.cabbrevs', {
    \   'fn': 's:cabbrevsource',
    \   })

let s:sources = []
for k in keys(g:mx#sources)
    let val = copy(g:mx#sources[k])
    let val.name = k
    call add(s:sources, val)
endfor
"}}}

" vars {{{
let s:RESULT_CANCEL = 0
let s:RESULT_OK = 1
let s:RESULT_BREAK = 2
let s:RESULT_NOGETCHAR = 4
let s:RESULT_NODRAW = 8
"}}}

function! mx#loop(ctx) " {{{
    if mx#tools#isdebug()
        call mx#tools#log('mx#start(' . string(a:ctx) . ')')
    endif

    if !get(a:ctx, 'welcome_sign') | let a:ctx.welcome_sign = g:mx#welcome_sign | endif
    if !get(a:ctx, 'char') | let a:ctx.char = '' | endif
    if !get(a:ctx, 'candidates') | let a:ctx.candidates = [] | endif
    if !get(a:ctx, 'candidate_idx') | let a:ctx.candidate_idx = -1 | endif
    if !get(a:ctx, 'showmenu') | let a:ctx.showmenu = g:mx#autocomplete | endif

    while 1
        let result = s:RESULT_CANCEL
        for handler in s:handlers
            let result = or(result, call(function(handler.fn), [a:ctx]))
            call mx#tools#log('result ' . result)
            if result == s:RESULT_CANCEL || and(result, s:RESULT_BREAK) == s:RESULT_BREAK
                break
            endif
        endfor
        if result == s:RESULT_CANCEL | return | endif

        if and(result, s:RESULT_NODRAW) != s:RESULT_NODRAW
            call s:drawcxt(a:ctx)
        endif

        if and(result, s:RESULT_NOGETCHAR) != s:RESULT_NOGETCHAR
            let a:ctx.char = getchar()
        endif
    endwhile
endfunction "}}}

function! s:drawcxt(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('drawcxt(' . string(a:ctx) . ')')
    endif

    if a:ctx.showmenu
        redraw
        echohl MxCandidates

        let chars = 0
        let candidate_idx = 0
        for candidate in a:ctx.candidates
            let out = candidate.word
            if (chars + len(out) + 2) / &columns > g:mx#max_lines - 1
                echon ' >'
                let chars += 2
                break
            endif

            if !empty(chars)
                echon '  '
                let chars += 2
            endif

            if candidate_idx == a:ctx.candidate_idx
                echohl MxSelCandidate
            endif

            echon out
            let chars += len(out)

            if candidate_idx == a:ctx.candidate_idx
                echohl MxCandidates
            endif
            let candidate_idx += 1
        endfor
        if chars % &columns != 0
            echon repeat(' ', (&columns - chars % &columns))
        endif
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
        for word in split(g:mx#cutcmdline, ' ')
            call add(candidates, {'word': word})
        endfor
    endif
    return candidates
endfunction "}}}

function! s:cabbrevsource(ctx) abort "{{{
    let abbr = maparg(a:ctx.cmd, 'c', 1)
    if !empty(abbr)
        return [{'word': abbr, 'priority': 40}]
    endif
    return []
endfunction "}}}

function! s:defaulthandler(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('defaulthandler(' . string(a:ctx) . ')')
    endif

    if !empty(a:ctx.char)
        if type(nr2char(a:ctx.char)) != 1 | return s:RESULT_OK | endif
        let a:ctx.cmd = a:ctx.cmd . nr2char(a:ctx.char)
        let a:ctx.candidate_idx = -1
    endif

    if !a:ctx.showmenu | return s:RESULT_OK | endif

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
    return s:RESULT_OK
endfunction "}}}

function! s:specialkeyshandler(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('specialkeyshandler(' . string(a:ctx) . ')')
    endif

    if a:ctx.char == 27 || a:ctx.char == 3 "Esc, C-c
        redraw
        return s:RESULT_CANCEL
    elseif a:ctx.char == 13 "CR
        redraw
        if !empty(a:ctx.cmd)
            call feedkeys(':' . a:ctx.cmd . "\<CR>", '')
        endif
        return s:RESULT_CANCEL
    elseif a:ctx.char == 32 "space
        let abbr = maparg(a:ctx.cmd, 'c', 1)
        if !empty(abbr)
            let a:ctx.cmd = abbr
        endif
    elseif a:ctx.char is# "\<BS>" "Backspace
        let a:ctx.cmd = a:ctx.cmd[:-2]
        let a:ctx.char = ''
        return s:RESULT_NOGETCHAR
    elseif a:ctx.char == 21 "C-U
        let a:ctx.cmd = ''
        let a:ctx.char = ''
        return s:RESULT_NOGETCHAR
    endif
    return s:RESULT_OK
endfunction "}}}

function! s:tabkeyhandler(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('tabkeyhandler(' . string(a:ctx) . ')')
    endif

    if a:ctx.char == 9 || a:ctx.char is# "\<S-Tab>" "Tab
        if a:ctx.candidate_idx == -1
            let a:ctx.cmdback = a:ctx.cmd
        endif

        if !a:ctx.showmenu
            let a:ctx.showmenuback = a:ctx.showmenu
            let a:ctx.showmenu = 1
            let a:ctx.candidate_idx = 0
            let a:ctx.char = ''
            return or(s:RESULT_NODRAW, s:RESULT_NOGETCHAR)
        endif

        if a:ctx.char == 9
            let a:ctx.candidate_idx = len(a:ctx.candidates) - 1 <= a:ctx.candidate_idx ?
                \   -1 : a:ctx.candidate_idx + 1
        else
            let a:ctx.candidate_idx = a:ctx.candidate_idx == -1 ?
                \   len(a:ctx.candidates) - 1 : a:ctx.candidate_idx - 1
        endif

        if a:ctx.candidate_idx == -1
            let a:ctx.cmd = a:ctx.cmdback
            let a:ctx.showmenu = get(a:ctx, 'showmenuback', 1)
        else
            let a:ctx.cmd = a:ctx.candidates[a:ctx.candidate_idx].word
        endif

        return s:RESULT_BREAK
    endif
    return s:RESULT_OK
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
