" File: meta-x.vim
" Description: Meta-X plugin backend
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" options "{{{
call mx#tools#setdefault('g:mx#max_candidates', 10)

call mx#tools#setdefault('g:mx#favorits', [
    \   {'word': 'foo'},
    \   {'word': 'bar', 'short': 'b'},
    \   {'word': 'Far', 'abbr': 'f'},
    \   ])

call mx#tools#setdefault('g:mx#handlers', {})
call mx#tools#setdefault('g:mx#handlers.specialkeys', {
    \   'fn': 's:specialkeyshandler',
    \   'priority': 100,
    \   })
call mx#tools#setdefault('g:mx#handlers.default', {
    \   'fn': 's:defaulthandler',
    \   'priority': 0,
    \   })
call mx#tools#setdefault('g:mx#handlers.favorits', {
    \   'fn': 's:favoritshandler',
    \   'priority': 10,
    \   })

let s:handlers = []
for k in keys(g:mx#handlers)
    let val = copy(g:mx#handlers[k])
    let val['name'] = k
    call add(s:handlers, val)
endfor
let s:handlers = sort(s:handlers, 'mx#tools#PriorityCompare')
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

        call mx#tools#log('candidates: (' . string(a:ctx.candidates) . ')')
        if len(a:ctx.candidates) > g:mx#max_candidates
            let a:ctx.candidates = a:ctx.candidates[:g:mx#max_candidates]
        endif
        let a:ctx.candidates = sort(a:ctx.candidates, 'mx#tools#PriorityCompare')

        call s:drawcxt(a:ctx)

        let a:ctx.char = handled != 2 ? getchar() : ''
    endwhile
endfunction "}}}

function! s:drawcxt(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('drawcxt(' . string(a:ctx) . ')')
    endif

    redraw
    echohl WarningMsg
    for candidate in a:ctx.candidates
        if get(candidate, 'visible', 1)
            echon candidate.word . ' '
        endif
    endfor
    echohl None
    echo a:ctx.welcome_sign . a:ctx.cmd
endfunction "}}}

function! s:defaulthandler(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('defaulthandler(' . string(a:ctx) . ')')
    endif

    let a:ctx.cmd = a:ctx.cmd . nr2char(a:ctx.char)
    silent! call feedkeys(":" . a:ctx.cmd . "\<C-A>\<C-t>\<Esc>", 'x')

    let candidates = []
    for word in split(s:cmdline, ' ')
        let candidate = {'word': word}

        if word == a:ctx.cmd " same word
            let candidate['priority'] = 20
        elseif '^' . word =~# a:ctx.cmd "starts with same case
            let candidate['priority'] = 10
        elseif '^' . word =~? a:ctx.cmd "starts with ignore case
            let candidate['priority'] = 5
        endif

        call add(candidates, candidate)
    endfor

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

function! s:favoritshandler(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('favoritshandler(' . string(a:ctx) . ')')
    endif

    if empty(a:ctx.char) && empty(a:ctx.cmd)
        let a:ctx.candidates = g:mx#favorits
        return 1
    endif
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
