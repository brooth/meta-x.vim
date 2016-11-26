" File: meta-x.vim
" Description: Meta-X plugin backend
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" options "{{{
call mx#tools#setdefault('g:mx#max_lines', 1)
call mx#tools#setdefault('g:mx#max_candidates', 50)
call mx#tools#setdefault('g:mx#show_complete', 1)
call mx#tools#setdefault('g:mx#welcome_sign', ':')
call mx#tools#setdefault('g:mx#drawer', 'cycle')

" call mx#tools#setdefault('g:mx#auto_pairs', [
"     \   {'open': '\(', 'close': '\)'}
"     \   {'open': '(', 'close': ')'}
"     \   {'open': '[', 'close': ']'}
"     \   ])
"}}}

" handlers {{{
call mx#tools#setdefault('g:mx#handlers', {})
call mx#tools#setdefault('g:mx#handlers.specialkeys', {
    \   'fn': 'mx#handlers#specialkeys#handle',
    \   'priority': 20,
    \   })
call mx#tools#setdefault('g:mx#handlers.completion', {
    \   'fn': 'mx#handlers#completion#handle',
    \   'priority': 25,
    \   })
call mx#tools#setdefault('g:mx#handlers.feedkeys', {
    \   'fn': 'mx#handlers#feedkeys#handle',
    \   'priority': 15,
    \   })
call mx#tools#setdefault('g:mx#handlers.candidates', {
    \   'fn': 'mx#handlers#candidates#handle',
    \   'priority': 10,
    \   })
call mx#tools#setdefault('g:mx#handlers.formatter', {
    \   'fn': 's:formathandler',
    \   'priority': 5,
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

" drawers {{{
call mx#tools#setdefault('g:mx#drawers', {})
call mx#tools#setdefault('g:mx#drawers.cycle', {'fn': 'mx#drawers#cycle#draw'})
" }}}

" vars {{{
let g:MX_RES_EXIT = 1
let g:MX_RES_BREAK = 2
let g:MX_RES_NOINPUT = 4
let g:MX_RES_NODRAWCMDLINE = 8
let g:MX_RES_NOUPDATECURSOR = 16
let g:MX_RES_NOAPPLYPATTERN = 32
"}}}

function! mx#loop(ctx) " {{{
    if mx#tools#isdebug()
        call mx#tools#log('mx#start(' . string(a:ctx) . ')')
    endif

    if !get(a:ctx, 'cmd') | let a:ctx.cmd = '' | endif
    if !get(a:ctx, 'welcome_sign') | let a:ctx.welcome_sign = g:mx#welcome_sign | endif
    if !get(a:ctx, 'char') | let a:ctx.input = '' | endif
    if !get(a:ctx, 'candidates') | let a:ctx.candidates = [] | endif
    if !get(a:ctx, 'candidate_idx') | let a:ctx.candidate_idx = -1 | endif
    if !get(a:ctx, 'complete') | let a:ctx.complete = g:mx#show_complete | endif
    if !get(a:ctx, 'cursor') | let a:ctx.cursor = 0 | endif
    if !get(a:ctx, 'drawer') | let a:ctx.drawer = g:mx#drawer | endif

    let besafe = 500
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
            if and(result, g:MX_RES_EXIT) == g:MX_RES_EXIT
                return
            endif
            if and(result, g:MX_RES_BREAK) == g:MX_RES_BREAK
                break
            endif
        endfor

        if and(result, g:MX_RES_NOAPPLYPATTERN) != g:MX_RES_NOAPPLYPATTERN
            call mx#tools#log('apply pattern')
            let a:ctx.cmd = a:ctx.pattern
        endif

        if and(result, g:MX_RES_NOUPDATECURSOR) != g:MX_RES_NOUPDATECURSOR
            call mx#tools#log('update cursor')
            let a:ctx.cursor = len(a:ctx.cmd)
        endif

        if and(result, g:MX_RES_NODRAWCMDLINE) != g:MX_RES_NODRAWCMDLINE
            call mx#tools#log('draw ctx')
            let drawer = get(g:mx#drawers, a:ctx.drawer, '')
            if empty(drawer)
                echoerr 'unknown drawer ' . a:ctx.drawer
                return
            endif
            call call(function(drawer.fn), [a:ctx])
        endif

        if and(result, g:MX_RES_NOINPUT) != g:MX_RES_NOINPUT
            let a:ctx.input = getchar()
        endif
    endwhile
endfunction "}}}

function! s:formathandler(ctx) abort "{{{
    if mx#tools#isdebug()
        call mx#tools#log('formathandler(' . string(a:ctx) . ')')
    endif
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
