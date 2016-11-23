" File: meta-x.vim
" Description: Meta-X plugin backend
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" options "{{{
call mx#tools#setdefault('g:mx#favorits', ['foo', 'b[ar]'])
call mx#tools#setdefault('g:mx#max_candidates', 10)
"}}}

function! mx#cutcmdline() "{{{
    let s:cmdline = getcmdline()
    call mx#tools#log('cut cmdline:' . s:cmdline)
    return ''
endfunction "}}}

function! mx#start(ctx) " {{{
    if mx#tools#isdebug()
        call mx#tools#log('mx#start(' . string(a:ctx) . ')')
    endif

    if get(a:ctx, 'skip_cand', 0)
        unlet a:ctx.skip_cand
    else
        if empty(a:ctx.cmd)
            let a:ctx.candidates = g:mx#favorits
        else
            silent! call feedkeys(":" . a:ctx.cmd . "\<C-A>\<C-t>\<Esc>", 'x')
            let a:ctx.candidates = split(s:cmdline, ' ')
        endif

        call mx#tools#log('candidates: (' . string(a:ctx.candidates) . ')')
        if len(a:ctx.candidates) > g:mx#max_candidates
            let a:ctx.candidates = a:ctx.candidates[:g:mx#max_candidates]
        endif
    endif

    redraw
    echohl WarningMsg
    for candidate in a:ctx.candidates
        echon candidate . ' '
    endfor
    echohl None
    echo a:ctx.welc_sign . a:ctx.cmd

    let c = getchar()
    if c == 13 "CR
        exec a:ctx.cmd
        redraw
        return
    elseif c == 9 "tab
        let a:ctx.cand_idx = len(a:ctx.candidates)-1 <= a:ctx.cand_idx? 0 : a:ctx.cand_idx + 1
        let a:ctx['skip_cand'] = 1
        let a:ctx.cmd = a:ctx.candidates[a:ctx.cand_idx]
    elseif c == 27 || c == 3 "Esc, c-c
        redraw
        return
    elseif c is# "\<BS>"
        let a:ctx.cmd = a:ctx.cmd[:-2]
    elseif c == 21 "C-U
        let a:ctx.cmd = ''
    else
        let a:ctx.cmd = a:ctx.cmd . nr2char(c)
    endif

    call mx#start(a:ctx)
endfunction "}}}

" vim: set et fdm=marker sts=4 sw=4:
