" File: history.vim
" Description: Meta-X output formatter handler
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

 call mx#tools#setdefault('g:mx#auto_pairs', [
     \   {'open': '\(', 'close': '\)'},
     \   {'open': '(', 'close': ')'},
     \   {'open': '[', 'close': ']'},
     \   ])

function! mx#handlers#formatter#handle(ctx) abort
    if mx#tools#isdebug()
        call mx#tools#log('mx#handlers#formatter#handle(' . string(a:ctx) . ')')
    endif

    if !empty(g:mx#auto_pairs) && a:ctx.cmd != get(a:ctx, '_autopaired', '')
        for autopair in g:mx#auto_pairs
            if len(a:ctx.cmd) >= len(autopair.open) && strridx(a:ctx.cmd, autopair.open)
                    \   == len(a:ctx.cmd) - len(autopair.open)
                let a:ctx._autopaired = a:ctx.cmd
                let a:ctx.cmd = a:ctx.cmd . autopair.close
            endif
        endfor
    endif
endfunction
