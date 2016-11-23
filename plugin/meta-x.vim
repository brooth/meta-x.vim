" File: meta-x.vim
" Description: Progressive cmdline. Inspired by desire to kick ass Helm-M-x.
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" todos {{{
" sources. favorits and feedkeys first
" convert handler.fn to handler.fnrf (function(fn)) and order by priority
" paste from registers
" hl line if no candidates
" '$' prefix for shell commands
" auto cancel cmd entering by timeout. ability to continue cancelled cmd
" }}}

function! MetaX(line) "{{{
    call mx#tools#log('MetaX(' . a:line . ')')

    let ctx = {
        \   'cmd' : a:line,
        \   'candidate_idx': -1,
        \   'welcome_sign': ':',
        \   }
    call mx#loop(ctx)
endfunction "}}}

cnoremap <C-t> <C-\>e(mx#cutcmdline())<CR>
nnoremap <M-x> :call MetaX('')<cr>

" vim: set et fdm=marker sts=4 sw=4:
