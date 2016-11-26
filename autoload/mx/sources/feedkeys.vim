" File: feedkeys.vim
" Description: Meta-X feedkeys source
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! mx#sources#feedkeys#gather(ctx) abort
    let candidates = []
    if !empty(a:ctx.pattern)
        silent! call feedkeys(":" . a:ctx.pattern . "\<C-A>\<C-t>c\<Esc>", 'x')
        for word in split(g:mx#cmdline, ' ')
            if strridx(word, '') == -1 &&
                    \   strridx(tolower(a:ctx.pattern), tolower(word)) == -1
                call add(candidates, {'word': word})
            endif
        endfor
    endif
    return candidates
endfunction
