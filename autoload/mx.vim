" File: meta-x.vim
" Description: Meta-X plugin backend
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" options "{{{
call mx#tools#setdefault('g:mx#favorits', ['foo', 'b[ar]'])
call mx#tools#setdefault('g:mx#max_candidates', 10)

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

    if get(a:ctx, 'char', '') == ''
        let a:ctx.char = ''
    endif

    while 1
        let handled = 0
        for k in keys(g:mx#handlers)
            let handler = g:mx#handlers[k]
            let handled = call(function(handler.fn), [a:ctx])
            if handled == -1
                return
            elseif handled
                break
            endif
        endfor

        call mx#tools#log('candidates: (' . string(a:ctx.candidates) . ')')
        if len(a:ctx.candidates) > g:mx#max_candidates
            let a:ctx.candidates = a:ctx.candidates[:g:mx#max_candidates]
        endif

        redraw
        echohl WarningMsg
        for candidate in a:ctx.candidates
            echon candidate . ' '
        endfor
        echohl None
        echo a:ctx.welcome_sign . a:ctx.cmd

        if handled != 2
        else
            let a:ctx.char = ''
        endif
            let a:ctx.char = getchar()
    endwhile
endfunction "}}}

function! s:defaulthandler(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('defaulthandler(' . string(a:ctx) . ')')
    endif

    let a:ctx.cmd = a:ctx.cmd . nr2char(a:ctx.char)
    silent! call feedkeys(":" . a:ctx.cmd . "\<C-A>\<C-t>\<Esc>", 'x')
    let a:ctx.candidates = split(s:cmdline, ' ')
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
        exec a:ctx.cmd
        redraw
        return -1
    elseif a:ctx.char == 9 "Tab
        let a:ctx.candidate_idx = len(a:ctx.candidates)-1 <= a:ctx.candidate_idx? 0 : a:ctx.candidate_idx + 1
        let a:ctx.cmd = a:ctx.candidates[a:ctx.candidate_idx]
        return 1
    elseif a:ctx.char is# "\<BS>" "Backspace
        let a:ctx.cmd = a:ctx.cmd[:-2]
        return 2
    elseif a:ctx.char == 21 "C-U
        let a:ctx.cmd = ''
        return 2
    endif
    return 0
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
