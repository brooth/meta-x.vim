" File: favorits.vim
" Description: Meta-X favorits source
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

call mx#tools#setdefault('g:mx#favorits', [
    \   {'word': 'find'},
    \   {'word': 'so %'},
    \   {'word': 'write', 'short': 'w'},
    \   {'word': 'qall', 'short': 'qa'},
    \   {'word': 'help', 'short': 'h'},
    \   ])

for fav in g:mx#favorits
    if !get(fav, 'favorit')
        let fav['favorit'] = 1
    endif
endfor

function! mx#sources#favorits#gather(ctx) abort
    let candidates = []
    for fav in g:mx#favorits
        if empty(a:ctx.cmd) || strridx(tolower(fav.word), tolower(a:ctx.cmd)) == 0
            call add(candidates, copy(fav))
        endif
    endfor
    return candidates
endfunction
