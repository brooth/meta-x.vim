" File: feedkeys.vim
" Description: Meta-X feedkeys source
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

call mx#tools#setdefault('g:mx#feedkeys_source_whilelist', [])
call mx#tools#setdefault('g:mx#feedkeys_source_blacklist', [
    \   '^.\?$',
    \   '[-+*=!]$',
    \   ])
call add(g:mx#feedkeys_source_blacklist, '\n')

function! mx#sources#feedkeys#gather(ctx) abort
    call mx#tools#log('mx#sources#feedkeys#gather()')

    let candidates = []
    for white in g:mx#feedkeys_source_whilelist
        if a:ctx.cmd !~# white
            call mx#tools#log('"' . a:ctx.cmd . '" not matches white ' . white)
            return candidates
        endif
    endfor
    for black in g:mx#feedkeys_source_blacklist
        if a:ctx.cmd =~# black
            call mx#tools#log('"' . a:ctx.cmd . '" matches black ' . black)
            return candidates
        endif
    endfor

    silent! call feedkeys(":" . a:ctx.cmd . "\<C-A>\<C-t>c\<Esc>", 'x')
    for word in split(g:mx#cmdline, ' ')
        if strridx(word, '') == -1
                    \   && stridx(tolower(a:ctx.cmd), tolower(word)) == -1 "not fully in cmd
                    \   && stridx(tolower(word), tolower(a:ctx.pattern)) >= 0 "contains the pattern
            call add(candidates, {'word': word})
        endif
    endfor
    return candidates
endfunction
