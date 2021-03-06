" File: meta-x.vim
" Description: Meta-X plugin backend
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" options "{{{
call mx#tools#setdefault('g:mx#welcome_sign', ':')
call mx#tools#setdefault('g:mx#drawer', 'modern')
"}}}

" handlers {{{
call mx#tools#setdefault('g:mx#handlers', {})
call mx#tools#setdefault('g:mx#handlers.register', {
    \   'fn': 'mx#handlers#register#handle',
    \   'priority': 35,
    \   })
call mx#tools#setdefault('g:mx#handlers.easycomplete', {
    \   'fn': 'mx#handlers#easycomplete#handle',
    \   'priority': 30,
    \   })
call mx#tools#setdefault('g:mx#handlers.completion', {
    \   'fn': 'mx#handlers#completion#handle',
    \   'priority': 25,
    \   })
call mx#tools#setdefault('g:mx#handlers.history', {
    \   'fn': 'mx#handlers#history#handle',
    \   'priority': 25,
    \   })
call mx#tools#setdefault('g:mx#handlers.specialkeys', {
    \   'fn': 'mx#handlers#specialkeys#handle',
    \   'priority': 20,
    \   })
call mx#tools#setdefault('g:mx#handlers.feedkeys', {
    \   'fn': 'mx#handlers#feedkeys#handle',
    \   'priority': 15,
    \   })
call mx#tools#setdefault('g:mx#handlers.candidates', {
    \   'fn': 'mx#handlers#completion#gather',
    \   'priority': 10,
    \   })
call mx#tools#setdefault('g:mx#handlers.formatter', {
    \   'fn': 'mx#handlers#formatter#handle',
    \   'priority': 0,
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
let s:handlers = sort(s:handlers, 'mx#tools#PrioritySorter')
" }}}

" drawers {{{
call mx#tools#setdefault('g:mx#drawers', {})
call mx#tools#setdefault('g:mx#drawers.modern', {'fn': 'mx#drawers#modern#draw'})
" }}}

" consts {{{
let g:MX_RES_EXIT = 1
let g:MX_RES_BREAK = 2
let g:MX_RES_NOINPUT = 4
let g:MX_RES_NODRAWCMDLINE = 8
"}}}

function! mx#loop(ctx) " {{{
    if mx#tools#isdebug()
        call mx#tools#log('===================================================')
        call mx#tools#log('mx#loop(' . string(a:ctx) . ')')
    endif

    call mx#tools#setdictdefault(a:ctx, 'cmd', '')
    call mx#tools#setdictdefault(a:ctx, 'welcome_sign', g:mx#welcome_sign)
    call mx#tools#setdictdefault(a:ctx, 'input', '')
    call mx#tools#setdictdefault(a:ctx, 'cursor', 0)
    call mx#tools#setdictdefault(a:ctx, 'drawer', g:mx#drawer)

    let besafe = 500
    while besafe > 0
        call mx#tools#log('------ loop -------')
        let besafe += 1
        let result = 0
        for handler in s:handlers
            let result = or(result, call(function(handler.fn), [a:ctx]))
            call mx#tools#log('result ' . result)
            if and(result, g:MX_RES_EXIT) == g:MX_RES_EXIT
                redraw
                echon ''
                return a:ctx
            endif
            if and(result, g:MX_RES_BREAK) == g:MX_RES_BREAK
                break
            endif
        endfor

        if and(result, g:MX_RES_NODRAWCMDLINE) != g:MX_RES_NODRAWCMDLINE
            call mx#tools#log('draw ctx')
            let drawer = get(g:mx#drawers, a:ctx.drawer, '')
            if empty(drawer)
                echoerr 'unknown drawer ' . a:ctx.drawer
                return
            endif
            call s:drawcmdline(call(function(drawer.fn), [a:ctx]))
        endif

        if and(result, g:MX_RES_NOINPUT) != g:MX_RES_NOINPUT
            let a:ctx.input = getchar()
        endif
    endwhile
endfunction "}}}

function! s:drawcmdline(data) "{{{
    let content = a:data[0]
    let syntaxs = a:data[1]
    call add(syntaxs, {'name': 'None', 'range': [0, 99999]})
    let syntaxs = sort(syntaxs, 's:RangeSorter')

    if mx#tools#isdebug()
        call mx#tools#log('syntaxs:' . string(syntaxs))
        call mx#tools#log('content:' . string(content))
    endif

    let output = []
    call s:drawsyntax(output, join(content, ''), 0, syntaxs, 0)
    let cmdline = join(output, '|')

    if mx#tools#isdebug()
        call mx#tools#log('output:' . cmdline)
    endif

    redraw
    exec cmdline
endfunction "}}}

function! s:drawsyntax(output, line, pos, syntaxs, synidx) "{{{
    let synidx = a:synidx
    let cursyn = a:syntaxs[synidx]
    let besafe = 100
    let startpos = a:pos
    while besafe > 0
        let besafe -= 1
        let nesting = synidx < len(a:syntaxs) - 1 && cursyn.range[1] >= a:syntaxs[synidx + 1].range[0]
        let endpos = nesting ? a:syntaxs[synidx + 1].range[0] : cursyn.range[1] + 1

        if endpos > startpos
            let out = string(a:line[startpos:endpos - 1])
            call add(a:output, 'echohl ' . cursyn.name)
            call add(a:output, 'echon ' . out)
        endif

        if nesting
            let nesres = s:drawsyntax(a:output, a:line, endpos, a:syntaxs, synidx + 1)
            let startpos = nesres[0]
            let endpos = startpos
            let synidx = nesres[1]
        endif
        if endpos >= cursyn.range[1]
            return [endpos, synidx]
        endif
    endwhile
endfunction "}}}

function! s:RangeSorter(i1, i2) "{{{
    return a:i1.range[0] > a:i2.range[0] ? 1 :
        \  a:i1.range[0] < a:i2.range[0] ? -1 :
        \  a:i1.range[1] < a:i2.range[1] ? 1 : -1
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
