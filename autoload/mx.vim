" File: meta-x.vim
" Description: Meta-X plugin backend
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" options "{{{
call mx#tools#setdefault('g:mx#max_lines', 1)
call mx#tools#setdefault('g:mx#max_candidates', 50)
call mx#tools#setdefault('g:mx#autocomplete', 1)
call mx#tools#setdefault('g:mx#welcome_sign', ':')

" favorits {{{
call mx#tools#setdefault('g:mx#favorits', [
    \   {'word': 'so %'},
    \   {'word': 'find'},
    \   {'word': 'write', 'short': 'w'},
    \   {'word': 'qall', 'short': 'qa'},
    \   ])

for fav in g:mx#favorits
    if !get(fav, 'favorit')
        let fav['favorit'] = 1
    endif
endfor
" }}}

" handlers {{{
call mx#tools#setdefault('g:mx#handlers', {})
call mx#tools#setdefault('g:mx#handlers.specialkeys', {
    \   'fn': 's:specialkeyshandler',
    \   'priority': 20,
    \   })
call mx#tools#setdefault('g:mx#handlers.tabkey', {
    \   'fn': 's:tabkeyhandler',
    \   'priority': 20,
    \   })
call mx#tools#setdefault('g:mx#handlers.feedkeys', {
    \   'fn': 's:feedkeyshandler',
    \   'priority': 5,
    \   })
call mx#tools#setdefault('g:mx#handlers.candidates', {
    \   'fn': 's:candidateshandler',
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
" }}}

" sources {{{
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
"}}}

" vars {{{
let s:RESULT_EXIT = 1
let s:RESULT_BREAK = 2
let s:RESULT_NOINPUT = 4
let s:RESULT_NODRAWCMDLINE = 8
let s:RESULT_NOUPDATECURSOR = 16
let s:RESULT_NOAPPLYPATTERN = 32
"}}}

function! mx#loop(ctx) " {{{
    if mx#tools#isdebug()
        call mx#tools#log('mx#start(' . string(a:ctx) . ')')
    endif

    if !get(a:ctx, 'welcome_sign') | let a:ctx.welcome_sign = g:mx#welcome_sign | endif
    if !get(a:ctx, 'char') | let a:ctx.input = '' | endif
    if !get(a:ctx, 'candidates') | let a:ctx.candidates = [] | endif
    if !get(a:ctx, 'candidate_idx') | let a:ctx.candidate_idx = -1 | endif
    if !get(a:ctx, 'complete') | let a:ctx.complete = g:mx#autocomplete | endif
    if !get(a:ctx, 'cursor') | let a:ctx.cursor = 0 | endif

    let besafe = 100
    while besafe > 0
        call mx#tools#log('------ loop -------')
        let besafe += 1

        if empty(a:ctx.input)
            let a:ctx.pattern = a:ctx.cmd
        elseif a:ctx.cursor >= len(a:ctx.cmd)
            let a:ctx.pattern = a:ctx.cmd . nr2char(a:ctx.input)
        else
            let a:ctx.pattern = join(insert(split(a:ctx.cmd, '\zs'), nr2char(a:ctx.input), a:ctx.cursor), '')
        endif

        let result = 0
        for handler in s:handlers
            let result = or(result, call(function(handler.fn), [a:ctx]))
            call mx#tools#log('result ' . result)
            if and(result, s:RESULT_EXIT) == s:RESULT_EXIT
                return
            endif
            if and(result, s:RESULT_BREAK) == s:RESULT_BREAK
                break
            endif
        endfor

        if and(result, s:RESULT_NOAPPLYPATTERN) != s:RESULT_NOAPPLYPATTERN
            call mx#tools#log('apply pattern')
            let a:ctx.cmd = a:ctx.pattern
            let a:ctx.candidate_idx = -1
        endif

        if and(result, s:RESULT_NOUPDATECURSOR) != s:RESULT_NOUPDATECURSOR
            call mx#tools#log('update cursor')
            let a:ctx.cursor = len(a:ctx.cmd)
        endif

        if and(result, s:RESULT_NODRAWCMDLINE) != s:RESULT_NODRAWCMDLINE
            call mx#tools#log('draw cmdline')
            call s:drawcmdline(a:ctx)
        endif

        if and(result, s:RESULT_NOINPUT) != s:RESULT_NOINPUT
            let a:ctx.input = getchar()
        endif
    endwhile
endfunction "}}}

function! s:drawcmdline(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('drawcmdline(' . string(a:ctx) . ')')
    endif

    let chars = 1
    redraw
    echohl MxWelcomeSign
    echon a:ctx.welcome_sign
    let chars += len(a:ctx.welcome_sign)

    echohl MxCommand
    let cmd = a:ctx.cmd . ' '
    for i in range(len(cmd))
        if i == a:ctx.cursor | echohl MxCursor | endif
        echon cmd[i]
        if i == a:ctx.cursor | echohl MxCommand | endif
    endfor
    let chars += len(cmd)

    "sepatator
    echon ' '
    let chars += 1

    "complete
    echohl MxComplete

    echon '{'
    let chars += 1
    let candidate_idx = -1
    for candidate in a:ctx.candidates
        let candidate_idx += 1
        if !get(candidate, 'visible', 1) | continue | endif

        if candidate_idx == a:ctx.candidate_idx
            echohl MxCompleteSel
        endif

        let out = ' ' . candidate.word . ' '

        if (chars + len(out) + 2 + 1) / &columns > g:mx#max_lines - 1
            echon '..'
            let chars += 2
           break
        endif

        echon out
        let chars += len(out)

        if candidate_idx == a:ctx.candidate_idx
            echohl MxComplete
        endif
    endfor

    echon '}'
    let chars += 1

    "empty space
    echohl None
    if chars % &columns != 0
        echon repeat(' ', (&columns - chars % &columns))
    endif
endfunction "}}}

function! s:favoritsource(ctx) abort "{{{
    let candidates = []
    for fav in g:mx#favorits
        if '^' . fav.word =~? escape(a:ctx.pattern, '~')
            call add(candidates, copy(fav))
        endif
    endfor
    return candidates
endfunction "}}}

function! s:feedkeysource(ctx) abort "{{{
    let candidates = []
    if !empty(a:ctx.pattern)
        silent! call feedkeys(":" . a:ctx.pattern . "\<C-A>\<C-t>c\<Esc>", 'x')
        for word in split(g:mx#cmdline, ' ')
            if word !~# '' && a:ctx.pattern !~# escape(word, '~')
                call add(candidates, {'word': word})
            endif
        endfor
    endif
    return candidates
endfunction "}}}

function! s:cabbrevsource(ctx) abort "{{{
    let abbr = maparg(a:ctx.pattern, 'c', 1)
    if !empty(abbr)
        return [{'word': abbr, 'priority': 40}]
    endif
    return []
endfunction "}}}

function! s:candidateshandler(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('candidateshandler(' . string(a:ctx) . ')')
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
endfunction "}}}

function! s:specialkeyshandler(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('specialkeyshandler(' . string(a:ctx) . ')')
    endif

    if a:ctx.input == 27 || a:ctx.input == 3 "Esc, C-c
        redraw
        echon ''
        return s:RESULT_EXIT
    elseif a:ctx.input == 13 "CR
        redraw
        if !empty(a:ctx.cmd)
            call feedkeys(':' . a:ctx.cmd . "\<CR>", '')
        endif
        return s:RESULT_EXIT
    endif
endfunction "}}}

function! s:feedkeyshandler(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('feedkeyshandler(' . string(a:ctx) . ')')
    endif

    if empty(a:ctx.input) | return | endif

    let g:mx#cmdpos = a:ctx.cursor + 1
    let keys = ":" . a:ctx.cmd . "\<C-t>P" .
        \   (type(a:ctx.input) == 0 ? nr2char(a:ctx.input) : a:ctx.input) .
        \   "\<C-t>p\<C-t>c\<Esc>"
    call mx#tools#log('keys=' . keys)

    silent! call feedkeys(keys, 'x')

    call mx#tools#log('pos:' . g:mx#cmdpos)
    let a:ctx.cursor = g:mx#cmdpos - 1
    call mx#tools#log('line:' . g:mx#cmdline)
    let a:ctx.pattern = g:mx#cmdline

    return s:RESULT_NOUPDATECURSOR
endfunction "}}}

function! s:tabkeyhandler(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('tabkeyhandler(' . string(a:ctx) . ')')
    endif

    if a:ctx.input == 9 || a:ctx.input is# "\<S-Tab>" "Tab
        if empty(a:ctx.candidates)
            return s:RESULT_NOAPPLYPATTERN
        endif
        if len(a:ctx.candidates) == 1
            let a:ctx.input = 32
            let a:ctx.pattern = a:ctx.cmd . ' '
            return
        endif
        if a:ctx.candidate_idx == -1
            call insert(a:ctx.candidates, {'word': a:ctx.cmd, 'visible': 0}, 0)
            let a:ctx.candidate_idx = 0
            let a:ctx.complete_pos = max([0, strridx(a:ctx.cmd, ' ', a:ctx.cursor)])
        endif

        " if !a:ctx.complete
        "     let a:ctx.complete = 1
        "     let a:ctx.input = ''
        "     return or(s:RESULT_NODRAWCMDLINE, s:RESULT_NOINPUT)
        " endif

        if a:ctx.input == 9
            let a:ctx.candidate_idx = len(a:ctx.candidates) - 1 <= a:ctx.candidate_idx ?
                \   0 : a:ctx.candidate_idx + 1
        else
            let a:ctx.candidate_idx = a:ctx.candidate_idx == 0 ?
                \   len(a:ctx.candidates) - 1 : a:ctx.candidate_idx - 1
        endif

        let word = a:ctx.candidates[a:ctx.candidate_idx].word
        let a:ctx.cmd = a:ctx.complete_pos == 0 ? word : a:ctx.cmd[:a:ctx.complete_pos] . word
        let a:ctx.cursor = a:ctx.complete_pos
        let a:ctx.input = ''
        return or(s:RESULT_BREAK, s:RESULT_NOAPPLYPATTERN)
    endif
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
