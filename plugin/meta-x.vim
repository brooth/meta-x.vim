" File: meta-x.vim
" Description: Insane menu.
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" todos {{{
" fixme: c-w
" handle 'already running' case
" sub favorits. related to part. commands
" up/down - history, shortcut for history complete as well
" sources. favorits and feedkeys first
" abbr support. convert to command on <sps> and <cr>.
" paste from registers
" while/black list for autocompletion. '!^' black by default
" substitude complete from current buff
" candidates list type: flow, list, table
" hl line if no candidates
" '$' prefix for shell commands
" auto cancel cmd entering by timeout. ability to continue cancelled cmd
" }}}

" syntax {{{
hi def link MxCommand Macro
hi def link MxWelcomeSign MxCommand
hi def link MxComplete Comment
hi def link MxCompleteSel Normal
hi def link MxCursor Cursor
" }}}

function! MetaX(line) "{{{
    call mx#tools#log('============== META-X (' . a:line . ') ===============')
    let ctx = {'cmd' : a:line}
    call mx#loop(ctx)
endfunction "}}}

" mapping {{{
cnoremap <C-t>c <C-\>e(mx#tools#cutcmdline())<CR>
cnoremap <C-t>p <C-\>e(mx#tools#getcmdpos())<CR>
cnoremap <C-t>P <C-\>e(mx#tools#setcmdpos())<CR>
nnoremap <c-j> :call MetaX('')<cr>
"}}}

" vim: set et fdm=marker sts=4 sw=4:
