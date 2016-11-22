
" echohl WarningMsg | echo 'help' | echohl None | echon ' hoo' | echon ' fum' | echo ' newline'
" echo getcompletion('', 'command', 0)

function! s:Cpcm()
    let g:mx = getcmdline()
    return ''
endfunction
cnoremap <C-t> <C-\>e(<SID>Cpcm())<CR>

function! Cm(line)
    call feedkeys(a:line . "\<C-A>\<C-t>\<Esc>", 'x')

    redraw
    echohl WarningMsg | echo g:mx | echohl None | echo a:line

    let line = a:line
    let c = getchar()
    if c == 13
        return line
    elseif c == 27 || c == 3 "Esc or c-c
        redraw
        return
    elseif c is# "\<BS>"
        let line = line[:-2]
    elseif c == 21 "C-U
        let line = ''
    else
        let line = line . nr2char(c)
    endif

    return Cm(line)
endfunction
nnoremap <C-j> :call Cm(':h')<cr>
