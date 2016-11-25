" File: meta-x.vim
" Description: Insane menu mode.
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" todos {{{
" fixme: c-w
" handle 'already running' case
" up/down - history, shortcut for history complete as well
" sources. favorits and feedkeys first
" abbr support. convert to command on <sps> and <cr>.
" paste from registers
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
cnoremap <C-t> <C-\>e(mx#tools#cutcmdline())<CR>
nnoremap <c-j> :call MetaX('')<cr>
"}}}

" vim: set et fdm=marker sts=4 sw=4:
