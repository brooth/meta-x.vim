" File: meta-x.vim
" Description: Progressive cmdline. Inspired by desire to kick ass Helm-M-x.
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" todos {{{
" paste from registers
" hl line if no candidates
" '$' prefix for shell commands
" }}}

function! MetaX(line) "{{{
    call mx#tools#log('MetaX(' . a:line . ')')

    let ctx = {
        \   'cmd' : a:line,
        \   'cand_idx': -1,
        \   'welc_sign': ':',
        \   }
    call mx#start(ctx)
endfunction "}}}

cnoremap <C-t> <C-\>e(mx#cutcmdline())<CR>
nnoremap <M-x> :call MetaX('')<cr>

" vim: set et fdm=marker sts=4 sw=4:
